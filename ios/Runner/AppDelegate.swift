import Flutter
import UIKit
import AVFoundation
import MediaPlayer

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    do {
      let audioSession = AVAudioSession.sharedInstance()
      try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
      try audioSession.setActive(true)
    } catch {
      print("Dream Valley: Failed to configure audio session: \(error)")
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "DreamValleyMediaBridge") {
      DreamValleyMediaBridge.register(with: registrar)
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "DreamValleyAuthStorage") {
      DreamValleyAuthStorage.register(with: registrar)
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "DreamValleySystemBridge") {
      DreamValleySystemBridge.register(with: registrar)
    }
  }
}

/// Bridges the web player's `window.DreamValleyMedia` JS channel to iOS
/// `MPNowPlayingInfoCenter` / `MPRemoteCommandCenter` so the system lock
/// screen shows story title, artist, artwork, progress, and routes remote
/// commands (play/pause/seek) back to the WebView via an EventChannel.
///
/// Mirrors the Android bridge:
///   MethodChannel  com.vervetogether.dreamvalley/media          (Dart -> iOS)
///   EventChannel   com.vervetogether.dreamvalley/media_actions  (iOS  -> Dart)
public class DreamValleyMediaBridge: NSObject, FlutterPlugin, FlutterStreamHandler {
  private static let methodChannelName = "com.vervetogether.dreamvalley/media"
  private static let eventChannelName  = "com.vervetogether.dreamvalley/media_actions"

  private var actionSink: FlutterEventSink?

  private var currentTitle    = "Dream Valley Story"
  private var currentArtist   = "Dream Valley"
  private var currentAlbum    = "Bedtime Stories"
  private var currentArtwork: UIImage?
  private var lastArtworkKey: String?
  private var isPlaying       = false
  private var currentPosition = 0.0
  private var currentDuration = 0.0

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = DreamValleyMediaBridge()

    let methodChannel = FlutterMethodChannel(
      name: methodChannelName,
      binaryMessenger: registrar.messenger()
    )
    methodChannel.setMethodCallHandler { call, result in
      instance.handle(call, result: result)
    }

    let eventChannel = FlutterEventChannel(
      name: eventChannelName,
      binaryMessenger: registrar.messenger()
    )
    eventChannel.setStreamHandler(instance)

    instance.setupRemoteCommands()
  }

  // MARK: - MethodChannel handler

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    switch call.method {
    case "updateMetadata":
      currentTitle  = (args["title"]  as? String) ?? currentTitle
      currentArtist = (args["artist"] as? String) ?? currentArtist
      currentAlbum  = (args["album"]  as? String) ?? currentAlbum
      let artworkUrl = args["artworkUrl"] as? String
      updateNowPlaying()
      if let urlStr = artworkUrl, urlStr != lastArtworkKey {
        lastArtworkKey = urlStr
        loadArtwork(urlStr) { [weak self] image in
          guard let self = self, self.lastArtworkKey == urlStr else { return }
          self.currentArtwork = image
          self.updateNowPlaying()
        }
      } else if artworkUrl == nil {
        currentArtwork = nil
        lastArtworkKey = nil
        updateNowPlaying()
      }
      result(nil)

    case "updatePlaybackState":
      isPlaying = (args["playing"] as? Bool) ?? false
      updateNowPlaying()
      result(nil)

    case "updatePosition":
      currentPosition = (args["position"] as? Double) ?? 0
      currentDuration = (args["duration"] as? Double) ?? 0
      updateNowPlaying()
      result(nil)

    case "stop":
      MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
      currentArtwork = nil
      lastArtworkKey = nil
      isPlaying = false
      result(nil)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - FlutterStreamHandler (EventChannel out)

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    actionSink = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    actionSink = nil
    return nil
  }

  private func sendAction(_ action: String, value: Double? = nil) {
    guard let sink = actionSink else { return }
    if let value = value {
      sink(["action": action, "value": value])
    } else {
      sink(["action": action])
    }
  }

  // MARK: - Now Playing info

  private func updateNowPlaying() {
    var info: [String: Any] = [
      MPMediaItemPropertyTitle:                    currentTitle,
      MPMediaItemPropertyArtist:                   currentArtist,
      MPMediaItemPropertyAlbumTitle:               currentAlbum,
      MPNowPlayingInfoPropertyPlaybackRate:        isPlaying ? 1.0 : 0.0,
      MPNowPlayingInfoPropertyElapsedPlaybackTime: currentPosition,
    ]
    if currentDuration > 0 {
      info[MPMediaItemPropertyPlaybackDuration] = currentDuration
    }
    if let image = currentArtwork {
      let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
      info[MPMediaItemPropertyArtwork] = artwork
    }
    MPNowPlayingInfoCenter.default().nowPlayingInfo = info
  }

  // MARK: - Remote commands

  private func setupRemoteCommands() {
    let center = MPRemoteCommandCenter.shared()

    center.playCommand.addTarget { [weak self] _ in
      self?.sendAction("play")
      return .success
    }
    center.pauseCommand.addTarget { [weak self] _ in
      self?.sendAction("pause")
      return .success
    }
    center.togglePlayPauseCommand.addTarget { [weak self] _ in
      guard let self = self else { return .commandFailed }
      self.sendAction(self.isPlaying ? "pause" : "play")
      return .success
    }

    center.skipBackwardCommand.preferredIntervals = [15]
    center.skipBackwardCommand.addTarget { [weak self] _ in
      self?.sendAction("seekbackward")
      return .success
    }
    center.skipForwardCommand.preferredIntervals = [15]
    center.skipForwardCommand.addTarget { [weak self] _ in
      self?.sendAction("seekforward")
      return .success
    }

    center.changePlaybackPositionCommand.addTarget { [weak self] event in
      guard let positionEvent = event as? MPChangePlaybackPositionCommandEvent else {
        return .commandFailed
      }
      self?.sendAction("seekto", value: positionEvent.positionTime)
      return .success
    }

    center.nextTrackCommand.isEnabled = true
    center.nextTrackCommand.addTarget { [weak self] _ in
      self?.sendAction("next")
      return .success
    }
    center.previousTrackCommand.isEnabled = true
    center.previousTrackCommand.addTarget { [weak self] _ in
      self?.sendAction("previous")
      return .success
    }
  }

  // MARK: - Artwork loading

  private func loadArtwork(_ urlStr: String, completion: @escaping (UIImage?) -> Void) {
    if urlStr.hasPrefix("data:image/") {
      guard let commaIdx = urlStr.firstIndex(of: ",") else {
        completion(nil); return
      }
      let base64 = String(urlStr[urlStr.index(after: commaIdx)...])
      let data = Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
      completion(data.flatMap { UIImage(data: $0) })
      return
    }

    let resolved = urlStr.hasPrefix("http")
      ? urlStr
      : "https://dreamvalley.app\(urlStr)"
    guard let url = URL(string: resolved) else {
      completion(nil); return
    }
    URLSession.shared.dataTask(with: url) { data, _, _ in
      let image = data.flatMap { UIImage(data: $0) }
      DispatchQueue.main.async { completion(image) }
    }.resume()
  }
}
