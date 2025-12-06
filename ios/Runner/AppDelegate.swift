import UIKit
import Flutter
import YandexMapsMobile

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let yandexApiKey = loadEnvValue(for: "YANDEX_API_KEY"), !yandexApiKey.isEmpty {
      YMKMapKit.setApiKey(yandexApiKey)
    } else {
      NSLog("AppDelegate: YANDEX_API_KEY not found in .env or is empty")
    }

    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func loadEnvValue(for key: String) -> String? {
    guard let envURL = resolveEnvFileURL() else {
      NSLog("AppDelegate: .env asset not found in bundle")
      return nil
    }

    guard let contents = try? String(contentsOf: envURL, encoding: .utf8) else {
      NSLog("AppDelegate: Unable to read .env file")
      return nil
    }

    for rawLine in contents.components(separatedBy: .newlines) {
      let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)

      if line.isEmpty || line.hasPrefix("#") {
        continue
      }

      let parts = line.split(separator: "=", maxSplits: 1).map { String($0) }
      guard parts.count == 2 else {
        continue
      }

      var currentKey = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
      if currentKey.hasPrefix("export ") {
        currentKey = String(currentKey.dropFirst("export ".count)).trimmingCharacters(in: .whitespacesAndNewlines)
      }

      if currentKey != key {
        continue
      }

      var value = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
      if value.hasPrefix("\"") && value.hasSuffix("\"") && value.count >= 2 {
        value.removeFirst()
        value.removeLast()
      } else if value.hasPrefix("'") && value.hasSuffix("'") && value.count >= 2 {
        value.removeFirst()
        value.removeLast()
      }

      return value
    }

    return nil
  }

  private func resolveEnvFileURL() -> URL? {
    let candidateDirectories = [
      "Frameworks/App.framework/flutter_assets",
      "flutter_assets"
    ]

    for directory in candidateDirectories {
      if let url = Bundle.main.url(
        forResource: ".env",
        withExtension: nil,
        subdirectory: directory
      ) {
        return url
      }
    }

    return Bundle.main.url(forResource: ".env", withExtension: nil)
  }
}
