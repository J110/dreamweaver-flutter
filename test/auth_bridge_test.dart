/// Standalone tests for the native auth MethodChannel contract.
///
/// Verifies the Dart ↔ native plumbing against a mocked native layer. The
/// actual Keychain / EncryptedSharedPreferences ops are platform-native and
/// can only be exercised on a simulator/device — for that, use the on-device
/// probe: `await window.DreamValleyAuth._selfTest()` from the web console
/// after launching the 2.0 build.
///
/// Run:  flutter test test/auth_bridge_test.dart

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _channel = MethodChannel('com.vervetogether.dreamvalley/auth');

/// Minimal in-memory fake of the native storage. Mimics write-back-verify:
/// if [simulateWriteFailure] is true, the "store" path returns false even
/// though the in-memory write technically succeeded — modeling the silent
/// Keychain/Keystore failure mode the bridge guards against.
class _FakeNative {
  String? stored;
  bool simulateWriteFailure = false;

  Future<Object?> handle(MethodCall call) async {
    switch (call.method) {
      case 'store':
        final args = call.arguments as Map?;
        final token = args?['token'] as String? ?? '';
        if (token.isEmpty) return false;
        stored = token;
        if (simulateWriteFailure) {
          // Native write-back-verify failed: report false to Dart.
          // (Real native code returns here without overwriting `stored`
          // with corrupted data, but for the fake we just signal failure.)
          return false;
        }
        // Real native confirms write-back match before returning true.
        return stored == token;
      case 'read':
        return stored;
      case 'clear':
        stored = null;
        return true;
    }
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final fake = _FakeNative();

  setUp(() {
    fake.stored = null;
    fake.simulateWriteFailure = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, fake.handle);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  test('store then read returns the stored token', () async {
    final ok = await _channel.invokeMethod<bool>('store', {'token': 'abc123'});
    expect(ok, true);
    final read = await _channel.invokeMethod<String>('read');
    expect(read, 'abc123');
  });

  test('store rejects empty token', () async {
    final ok = await _channel.invokeMethod<bool>('store', {'token': ''});
    expect(ok, false);
    final read = await _channel.invokeMethod<String>('read');
    expect(read, isNull);
  });

  test('clear removes the token; subsequent read returns null', () async {
    await _channel.invokeMethod('store', {'token': 'xyz'});
    final cleared = await _channel.invokeMethod<bool>('clear');
    expect(cleared, true);
    final read = await _channel.invokeMethod<String>('read');
    expect(read, isNull);
  });

  test('store returns false on simulated write-back-verify failure', () async {
    fake.simulateWriteFailure = true;
    final ok = await _channel.invokeMethod<bool>('store', {'token': 'token'});
    expect(ok, false,
        reason: 'Native must return false on write-back mismatch — the bridge '
            'relies on this to prevent silent token loss surfacing as success.');
  });

  test('round-trip: store → read → clear → read returns null', () async {
    final s = await _channel.invokeMethod<bool>('store', {'token': 'round-trip-token'});
    expect(s, true);
    final r1 = await _channel.invokeMethod<String>('read');
    expect(r1, 'round-trip-token');
    final c = await _channel.invokeMethod<bool>('clear');
    expect(c, true);
    final r2 = await _channel.invokeMethod<String>('read');
    expect(r2, isNull);
  });

  test('overwrite: storing a second token replaces the first', () async {
    await _channel.invokeMethod<bool>('store', {'token': 'first'});
    await _channel.invokeMethod<bool>('store', {'token': 'second'});
    final read = await _channel.invokeMethod<String>('read');
    expect(read, 'second');
  });
}
