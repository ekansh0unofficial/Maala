import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let hapticChannel = FlutterMethodChannel(
        name: "maala/haptic",
        binaryMessenger: controller.binaryMessenger
      )
      hapticChannel.setMethodCallHandler { call, result in
        if call.method == "vibrate" {
          let args = call.arguments as? [String: Any]
          var duration = 30
          if let d = args?["duration"] as? Int {
            duration = d
          } else if let d = args?["duration"] as? Double {
            duration = Int(d)
          }
          let style: UIImpactFeedbackGenerator.FeedbackStyle =
            duration >= 150 ? .heavy : (duration >= 60 ? .medium : .light)
          let generator = UIImpactFeedbackGenerator(style: style)
          generator.prepare()
          generator.impactOccurred()
          result(true)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
