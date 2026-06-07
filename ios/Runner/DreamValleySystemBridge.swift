import Flutter
import UIKit

/// System bridge: open a URL in the EXTERNAL browser (Safari), not the WebView.
///
/// Used for Stripe checkout (#35) — digital-goods purchase flows must not run
/// inside the app's WebView (reader-app compliance). The web calls
/// window.DreamValleySystem.openExternal(url); Dart forwards it here.
///
/// MethodChannel: com.vervetogether.dreamvalley/system  (Dart → iOS)
///   "openExternal" → { url: String } → Bool (true iff the open was accepted)
public class DreamValleySystemBridge: NSObject, FlutterPlugin {
  private static let channelName = "com.vervetogether.dreamvalley/system"

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = DreamValleySystemBridge()
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      instance.handle(call, result: result)
    }
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "openExternal":
      let args = call.arguments as? [String: Any] ?? [:]
      guard let urlStr = args["url"] as? String, let url = URL(string: urlStr) else {
        NSLog("[DVSystem] openExternal: invalid url")
        result(false)
        return
      }
      DispatchQueue.main.async {
        UIApplication.shared.open(url, options: [:]) { ok in
          NSLog("[DVSystem] openExternal: opened=\(ok)")
          result(ok)
        }
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
