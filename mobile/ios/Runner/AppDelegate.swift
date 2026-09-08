import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    // S-H5: ekran himoyasi kanali (uz.stackyard.eld_mobile/screen_security).
    ScreenSecurityPlugin.shared.register(with: engineBridge.applicationRegistrar.messenger())
  }

  // MARK: - S-H5 / M158: snapshot himoyasi
  // UIScene ishlatilsa SceneDelegate chaqiriladi; bu yerdagi hooklar
  // scene'siz (yoki eski) oqim uchun zaxira.

  override func applicationWillResignActive(_ application: UIApplication) {
    ScreenSecurityPlugin.shared.showPrivacyOverlay()
    super.applicationWillResignActive(application)
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    ScreenSecurityPlugin.shared.hidePrivacyOverlay()
    super.applicationDidBecomeActive(application)
  }
}
