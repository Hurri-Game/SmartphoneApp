import Flutter
import UIKit
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    GeneratedPluginRegistrant.register(with: self)
        // Create and register the channel
    let channel = FlutterMethodChannel(
      name: "com.example.audio_control",
      binaryMessenger: controller.binaryMessenger
    )
    
    channel.setMethodCallHandler { (call, result) in
      switch call.method {
      case "deactivateAudioSession":
        self.deactivateAudioSession()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func deactivateAudioSession() {
    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
      print("Audio session deactivated.")
    } catch {
      print("Failed to deactivate audio session: \(error)")
    }
  }
}
