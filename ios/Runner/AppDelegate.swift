import Flutter
import GoogleMaps
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // The key comes from the gitignored Flutter/Secrets.xcconfig via
    // Info.plist (GMSApiKey). Missing key = blank map tiles, not a crash.
    if let mapsKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
      !mapsKey.isEmpty
    {
      GMSServices.provideAPIKey(mapsKey)
    }
    // Lets flutter_local_notifications present notifications while the app
    // is in the foreground and report their taps. Firebase itself is set up
    // from Dart (Firebase.initializeApp reads GoogleService-Info.plist).
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
