import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'native_auth_bridge.dart';

// ?source=app makes the web app route to the app (not the marketing page) even
// without UA detection — belt-and-suspenders alongside the web-side UA fix.
const String kAppUrl = 'https://dreamvalley.app/?source=app';
const Color kDeepNight = Color(0xFF0D0B2E);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Immersive dark status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: kDeepNight,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const DreamValleyApp());
}

class DreamValleyApp extends StatelessWidget {
  const DreamValleyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dream Valley',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kDeepNight,
      ),
      home: const WebAppScreen(),
    );
  }
}

class WebAppScreen extends StatefulWidget {
  const WebAppScreen({super.key});

  @override
  State<WebAppScreen> createState() => _WebAppScreenState();
}

class _WebAppScreenState extends State<WebAppScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  // Native media bridge channels (iOS + Android share the same names)
  static const _mediaChannel =
      MethodChannel('com.vervetogether.dreamvalley/media');
  static const _mediaActionsChannel =
      EventChannel('com.vervetogether.dreamvalley/media_actions');

  // Native auth bridge — Keychain (iOS) / EncryptedSharedPreferences (Android).
  // See lib/native_auth_bridge.dart for the JS contract exposed at
  // window.DreamValleyAuth.{storeToken,readToken,clearToken,_selfTest}.
  final NativeAuthBridge _authBridge = NativeAuthBridge();

  @override
  void initState() {
    super.initState();

    // Platform-specific WebView params for media playback
    late final PlatformWebViewControllerCreationParams params;
    if (Platform.isIOS) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(kDeepNight)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) setState(() => _isLoading = true);
        },
        onPageFinished: (_) {
          if (mounted) setState(() => _isLoading = false);

          // Re-inject the native-auth JS shim on every navigation (full-page
          // reloads and cross-origin pushes drop window state). Idempotent.
          _authBridge.injectShim();

          // Inject a script to help unlock AudioContext on Android WebView.
          // Web Audio API requires a user gesture to resume a suspended context;
          // this listener fires on the very first tap and resumes any existing
          // AudioContext so ambient music can play.
          if (Platform.isAndroid) {
            _controller.runJavaScript('''
              (function() {
                if (window.__dvAudioUnlocked) return;
                var unlock = function() {
                  var ctx = window.AudioContext || window.webkitAudioContext;
                  if (ctx) {
                    var a = new ctx();
                    a.resume().then(function() { a.close(); });
                  }
                  // Also resume any existing contexts created by the app
                  if (window.__ambientCtx && window.__ambientCtx.state === 'suspended') {
                    window.__ambientCtx.resume();
                  }
                  window.__dvAudioUnlocked = true;
                  document.removeEventListener('touchstart', unlock, true);
                  document.removeEventListener('click', unlock, true);
                };
                document.addEventListener('touchstart', unlock, true);
                document.addEventListener('click', unlock, true);
              })();
            ''');
          }
        },
        onWebResourceError: (error) {
          if (error.isForMainFrame ?? false) {
            if (mounted) {
              setState(() {
                _hasError = true;
                _isLoading = false;
              });
            }
          }
        },
      ))
      ..setUserAgent(
        // DreamValleyApp/2.0 — the reviewed paywall-capable build. Backend
        // UA-version-gates paywall on this token: <2.0 is treated as legacy
        // (un-paywalled) so old-build users aren't stranded mid-flip.
        // iOS must NOT masquerade as Android — a fake Android UA skewed
        // analytics and breaks iOS-specific web/paywall handling.
        Platform.isIOS
            ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
                'AppleWebKit/605.1.15 (KHTML, like Gecko) '
                'Mobile/15E148 DreamValleyApp/2.0'
            : 'Mozilla/5.0 (Linux; Android 14) '
                'AppleWebKit/537.36 (KHTML, like Gecko) '
                'DreamValleyApp/2.0 Chrome/120.0.0.0 Mobile Safari/537.36',
      )
      ..loadRequest(Uri.parse(kAppUrl));

    // Attach the auth bridge: register the JS channel BEFORE the page loads
    // so window.DreamValleyAuth is available on first paint.
    _authBridge.attach(_controller);

    // Media bridge — works on both iOS and Android.
    // mediaSessionManager.js posts to window.DreamValleyMedia; the native
    // side (DreamValleyMediaBridge on iOS, MainActivity+MediaPlaybackService
    // on Android) updates MPNowPlayingInfoCenter / MediaSessionCompat and
    // sends remote-command events back via _mediaActionsChannel.
    _controller.addJavaScriptChannel(
      'DreamValleyMedia',
      onMessageReceived: _onMediaMessage,
    );
    _mediaActionsChannel
        .receiveBroadcastStream()
        .listen(_onNativeMediaAction);

    // Android-specific WebView tuning for media autoplay.
    if (Platform.isAndroid) {
      final androidController =
          _controller.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);

      // Android 13+ requires POST_NOTIFICATIONS at runtime. Without it the
      // foreground-service notification that drives the lock-screen player
      // is suppressed system-wide and the player silently disappears.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestAndroidNotificationPermission();
      });
    }
  }

  Future<void> _requestAndroidNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isGranted) return;

    final result = await Permission.notification.request();

    // First-time denial: silent. Will re-prompt on next launch.
    // Permanent denial: one-time per-launch hint with a path to Settings,
    // since the system will not show the prompt again.
    if (result.isPermanentlyDenied && mounted) {
      _showNotificationSettingsHint();
    }
  }

  void _showNotificationSettingsHint() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1145),
        title: const Text(
          'Enable notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Dream Valley uses a notification to show the lock-screen player '
          'while a story is playing. Enable notifications in Settings to '
          'see playback controls on your lock screen.',
          style: TextStyle(color: Color(0xFFFFF3CD)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Not now',
              style: TextStyle(color: Color(0xFFB0A8D6)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            child: const Text(
              'Open Settings',
              style: TextStyle(color: Color(0xFF6B4CE6)),
            ),
          ),
        ],
      ),
    );
  }

  /// Handles messages from JavaScript (web player → Dart → Kotlin)
  void _onMediaMessage(JavaScriptMessage message) {
    try {
      final data = jsonDecode(message.message) as Map<String, dynamic>;
      final type = data['type'] as String?;

      switch (type) {
        case 'metadata':
          _mediaChannel.invokeMethod('updateMetadata', {
            'title': data['title'] ?? 'Dream Valley Story',
            'artist': data['artist'] ?? 'Dream Valley',
            'album': data['album'] ?? 'Bedtime Stories',
            'artworkUrl': data['artworkUrl'],
          });
          break;
        case 'state':
          _mediaChannel.invokeMethod('updatePlaybackState', {
            'playing': data['playing'] ?? false,
          });
          break;
        case 'position':
          _mediaChannel.invokeMethod('updatePosition', {
            'position': data['position'] ?? 0.0,
            'duration': data['duration'] ?? 0.0,
          });
          break;
        case 'stop':
          _mediaChannel.invokeMethod('stop');
          break;
      }
    } catch (e) {
      debugPrint('[DreamValley] Media message error: $e');
    }
  }

  /// Handles lock screen button taps from native Kotlin → Dart → JavaScript
  void _onNativeMediaAction(dynamic event) {
    if (event is Map) {
      final action = event['action'] as String?;
      final value = event['value'];
      if (action != null) {
        final jsValue = value != null ? "'$action', $value" : "'$action'";
        _controller.runJavaScript(
          'window.__onNativeMediaAction && window.__onNativeMediaAction($jsValue);',
        );
      }
    }
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _isLoading = true;
    });
    _controller.loadRequest(Uri.parse(kAppUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDeepNight,
      body: SafeArea(
        child: Stack(
          children: [
            // WebView — the actual web app
            WebViewWidget(controller: _controller),

            // Loading splash while web app loads
            if (_isLoading && !_hasError)
              Container(
                color: kDeepNight,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6B4CE6).withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 160,
                            height: 160,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Where magical bedtime stories come alive',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFFFFD93D).withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      const SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF6B4CE6),
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Error state — no internet
            if (_hasError)
              Container(
                color: kDeepNight,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_off_rounded,
                          color: Color(0xFF6B4CE6),
                          size: 80,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Oops! Can\'t reach Dream Valley',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFFFF3CD),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Please check your internet connection and try again',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFFFFF3CD).withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _retry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B4CE6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Try Again',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
