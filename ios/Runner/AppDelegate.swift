import UIKit
import Flutter
import YandexMapsMobile

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Get YANDEX_API_KEY from Flutter via method channel
    if let controller = window?.rootViewController as? FlutterViewController {
      let envChannel = FlutterMethodChannel(
        name: "com.prokurs.app/env",
        binaryMessenger: controller.binaryMessenger
      )
      
      envChannel.invokeMethod("getEnv", arguments: "YANDEX_API_KEY") { (result: Any?) in
        if let key = result as? String, !key.isEmpty {
          YMKMapKit.setApiKey(key)
        }
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
