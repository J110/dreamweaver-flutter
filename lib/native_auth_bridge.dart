/// Native auth bridge — durable identity storage for the WebView session.
///
/// Stores the family session token (32-byte hex opaque, 365d sliding, minted
/// by the backend's mint_device_token) in platform-native secure storage:
///   iOS:      Keychain item (kSecClassGenericPassword)
///             accessibility: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
///             (survives backgrounding; uninstall wipes — restore is the
///              recovery path, NOT persistence)
///   Android:  EncryptedSharedPreferences (AES256_GCM, AndroidX Security)
///             backed by the Android Keystore.
///
/// JS contract — exposed on every WebView page load (only present in native):
///   window.DreamValleyAuth = {
///     isAvailable: true,
///     storeToken(token: string)  → Promise<boolean>   // write-back-verified
///     readToken()                → Promise<string|null>
///     clearToken()                → Promise<boolean>
///     _selfTest()                → Promise<{ok, step?, detail?}>   // on-device probe
///   }
///
/// Write-back-verify invariant: storeToken resolves true ONLY if the native
/// write succeeded AND the immediate read-back returned an identical token.
/// A silent Keychain/Keystore write failure that left the user "signed in"
/// in JS but with no actual token on disk is exactly the invisible native
/// bug we cannot afford. Native enforces the read-back; Dart only forwards.
///
/// Web feature detection (for (D) restore UI):
///   const native = typeof window.DreamValleyAuth !== 'undefined'
///                  && window.DreamValleyAuth.isAvailable === true;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NativeAuthBridge {
  static const _methodChannelName = 'com.vervetogether.dreamvalley/auth';
  static const _jsChannelName = 'DreamValleyAuthRequest';

  final MethodChannel _channel = const MethodChannel(_methodChannelName);
  WebViewController? _controller;

  /// Wire the bridge to a WebViewController. Call once in initState BEFORE
  /// loadRequest so the JS channel is registered before the first page load.
  void attach(WebViewController controller) {
    _controller = controller;
    controller.addJavaScriptChannel(
      _jsChannelName,
      onMessageReceived: _onJsRequest,
    );
  }

  /// Inject the window.DreamValleyAuth shim into the current page.
  /// Call from onPageFinished — must run on EVERY navigation, not just first
  /// load (full-page reloads + cross-origin pushes drop window state).
  Future<void> injectShim() async {
    final c = _controller;
    if (c == null) return;
    await c.runJavaScript(_jsShim);
  }

  // ── JS → Dart → native ──────────────────────────────────────

  Future<void> _onJsRequest(JavaScriptMessage msg) async {
    String? requestId;
    bool success = false;
    String? value;
    String? error;
    try {
      final data = jsonDecode(msg.message) as Map<String, dynamic>;
      requestId = data['requestId'] as String?;
      final type = data['type'] as String?;
      if (requestId == null || type == null) return;

      switch (type) {
        case 'store':
          final token = (data['token'] as String?) ?? '';
          if (token.isEmpty) {
            error = 'empty_token';
            break;
          }
          success = await _channel.invokeMethod<bool>('store', {'token': token}) ?? false;
          break;
        case 'read':
          value = await _channel.invokeMethod<String?>('read');
          success = value != null && value.isNotEmpty;
          break;
        case 'clear':
          success = await _channel.invokeMethod<bool>('clear') ?? false;
          break;
        default:
          error = 'unknown_type';
      }
    } catch (e) {
      error = e.toString();
      debugPrint('[DVAuth] bridge invoke failed: $e');
    }

    if (requestId != null) {
      _resolveJs(requestId, success, value, error);
    }
  }

  void _resolveJs(String requestId, bool success, String? value, String? error) {
    final c = _controller;
    if (c == null) return;
    String safeStr(String? s) =>
        s == null ? 'null' : '"${s.replaceAll(r'\', r'\\').replaceAll('"', r'\"')}"';
    final js = 'window.__dvAuthResolve && window.__dvAuthResolve('
        '"$requestId", $success, ${safeStr(value)}, ${safeStr(error)});';
    c.runJavaScript(js);
  }
}

// ── JS shim — injected on every page finish ──────────────────

const _jsShim = r'''
(function() {
  if (window.DreamValleyAuth && window.DreamValleyAuth.isAvailable === true) return;

  var _counter = 0;
  var _pending = new Map();

  // Native (Dart) calls this to resolve a pending request.
  window.__dvAuthResolve = function(requestId, success, value, error) {
    var entry = _pending.get(requestId);
    if (!entry) return;
    _pending.delete(requestId);
    clearTimeout(entry.timer);
    entry.resolve({ success: !!success, value: value, error: error });
  };

  function send(type, payload) {
    var requestId = 'dv-auth-' + (++_counter) + '-' + Date.now();
    return new Promise(function (resolve) {
      var timer = setTimeout(function () {
        if (_pending.has(requestId)) {
          _pending.delete(requestId);
          resolve({ success: false, value: null, error: 'timeout' });
        }
      }, 5000);
      _pending.set(requestId, { resolve: resolve, timer: timer });
      try {
        var body = Object.assign({ type: type, requestId: requestId }, payload || {});
        window.DreamValleyAuthRequest.postMessage(JSON.stringify(body));
      } catch (e) {
        clearTimeout(timer);
        _pending.delete(requestId);
        resolve({ success: false, value: null, error: 'bridge_unavailable' });
      }
    });
  }

  window.DreamValleyAuth = {
    isAvailable: true,
    storeToken: function (token) {
      return send('store', { token: token }).then(function (r) { return r.success === true; });
    },
    readToken: function () {
      return send('read', {}).then(function (r) { return r.success ? r.value : null; });
    },
    clearToken: function () {
      return send('clear', {}).then(function (r) { return r.success === true; });
    },
    // On-device probe for native QA — verifies the full round-trip end-to-end.
    // Call from web console after building 2.0:
    //   const r = await window.DreamValleyAuth._selfTest(); console.log(r);
    // Expect { ok: true }.
    _selfTest: async function () {
      var probe = 'dv-probe-' + Date.now();
      var writeOk = await this.storeToken(probe);
      if (!writeOk) return { ok: false, step: 'store', detail: 'write failed' };
      var readVal = await this.readToken();
      if (readVal !== probe) return { ok: false, step: 'read', detail: 'wrote=' + probe + ' read=' + readVal };
      var clearOk = await this.clearToken();
      if (!clearOk) return { ok: false, step: 'clear', detail: 'clear failed' };
      var readAfter = await this.readToken();
      if (readAfter !== null) return { ok: false, step: 'read-after-clear', detail: 'expected null got=' + readAfter };
      return { ok: true };
    }
  };
})();
''';
