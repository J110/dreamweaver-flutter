import Flutter
import Foundation
import Security

/// Native auth-token storage backed by the iOS Keychain.
///
/// MethodChannel: com.vervetogether.dreamvalley/auth  (Dart → iOS)
///   "store" → { token: String } → Bool (true iff write succeeded AND
///                                       immediate read-back returned an
///                                       identical token; write-back-verify)
///   "read"  → ()                 → String? (the stored token, nil on miss)
///   "clear" → ()                 → Bool   (true on cleared or already absent)
///
/// Accessibility: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
///   - Item readable only after the device has been unlocked at least once
///     since boot. Survives backgrounding.
///   - "ThisDeviceOnly" → never syncs to iCloud Keychain. Token is bound to
///     this physical install on this device.
///   - Uninstall wipes the token (this is by design — restore is the
///     recovery path, NOT persistence across reinstall).
public class DreamValleyAuthStorage: NSObject, FlutterPlugin {
  private static let methodChannelName = "com.vervetogether.dreamvalley/auth"
  private let service = "com.vervetogether.dreamvalley.auth"
  private let account = "session_token"

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = DreamValleyAuthStorage()
    let channel = FlutterMethodChannel(
      name: methodChannelName,
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      instance.handle(call, result: result)
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "store":
      let args = call.arguments as? [String: Any] ?? [:]
      let token = (args["token"] as? String) ?? ""
      if token.isEmpty {
        NSLog("[DVAuth] store: empty token rejected")
        result(false)
        return
      }
      result(store(token: token))

    case "read":
      result(read())

    case "clear":
      result(clear())

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - Keychain ops

  private func store(token: String) -> Bool {
    guard let data = token.data(using: .utf8) else {
      NSLog("[DVAuth] store: utf8 encode failed")
      return false
    }

    // Delete any existing entry first. SecItemUpdate has historically had
    // edge cases on accessibility-flag changes; delete + add is safer.
    let deleteQuery: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
    ]
    SecItemDelete(deleteQuery as CFDictionary)

    let addQuery: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
      kSecValueData as String: data,
      kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
    ]
    let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
    if addStatus != errSecSuccess {
      NSLog("[DVAuth] store: SecItemAdd failed status=\(addStatus)")
      return false
    }

    // Write-back-verify: read immediately, confirm match. A silent Keychain
    // write that doesn't take effect is the exact invisible bug we guard
    // against — only return success if we can read back what we just wrote.
    let readBack = read()
    if readBack == token {
      NSLog("[DVAuth] store: success (write-back verified, token_len=\(token.count))")
      return true
    }
    NSLog("[DVAuth] store: write-back MISMATCH wrote_len=\(token.count) read_len=\(readBack?.count ?? -1)")
    return false
  }

  private func read() -> String? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne,
    ]
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    if status == errSecItemNotFound {
      return nil
    }
    if status != errSecSuccess {
      NSLog("[DVAuth] read: SecItemCopyMatching failed status=\(status)")
      return nil
    }
    guard let data = result as? Data, let token = String(data: data, encoding: .utf8) else {
      NSLog("[DVAuth] read: data decode failed")
      return nil
    }
    return token
  }

  private func clear() -> Bool {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
    ]
    let status = SecItemDelete(query as CFDictionary)
    if status == errSecSuccess || status == errSecItemNotFound {
      NSLog("[DVAuth] clear: success (status=\(status))")
      return true
    }
    NSLog("[DVAuth] clear: SecItemDelete failed status=\(status)")
    return false
  }
}
