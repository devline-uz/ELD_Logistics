import Flutter
import UIKit

/// S-H5 (M157 / M158) — iOS ekran himoyasi.
///
/// iOS'da Android'dagi `FLAG_SECURE` ekvivalenti yo'q, shuning uchun ikki qatlam:
///
/// 1. **Snapshot blur (M158)** — `sceneWillResignActive` / `applicationWillResignActive`
///    da butun oynani blur overlay bilan yopamiz. iOS app-switcher uchun aynan shu
///    payt snapshot oladi, demak PII (PIN klaviaturasi, 2FA kodi, imzo) diskdagi
///    snapshot keshiga TUSHMAYDI. `sceneDidBecomeActive` da overlay olib tashlanadi.
///    Bu overlay `isSecure` holatidan QAT'IY NAZAR har doim qo'llanadi.
///
/// 2. **Skrinshot / ekran yozuvi ogohlantirishi** — `isSecure == true` bo'lganda
///    `UIScreen.capturedDidChangeNotification` (ekran yozuvi / AirPlay mirroring)
///    da oyna berkitiladi va Dart tomoniga `screenCaptured` event yuboriladi.
///    Foydalanuvchi qo'lda olgan skrinshotni iOS bloklab bo'lmaydi — Dart tomoni
///    `screenshotTaken` eventini audit log uchun ishlatadi.
///
/// Kanal: `uz.stackyard.eld_mobile/screen_security`
///   - `setSecure(bool)` -> null
///   - `isSecure()`      -> bool
/// Event kanal: `uz.stackyard.eld_mobile/screen_security_events`
///   - `"screenshotTaken"` | `"screenRecordingStarted"` | `"screenRecordingStopped"`
final class ScreenSecurityPlugin: NSObject {

    static let channelName = "uz.stackyard.eld_mobile/screen_security"
    static let eventChannelName = "uz.stackyard.eld_mobile/screen_security_events"

    static let shared = ScreenSecurityPlugin()

    private var isSecure = false
    private var blurView: UIVisualEffectView?
    private var eventSink: FlutterEventSink?
    private weak var window: UIWindow?

    private override init() {
        super.init()
    }

    // MARK: - Ro'yxatdan o'tkazish

    func register(with messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: Self.channelName,
            binaryMessenger: messenger
        )
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else {
                result(FlutterError(code: "UNAVAILABLE", message: "plugin deallocated", details: nil))
                return
            }
            switch call.method {
            case "setSecure":
                guard let enabled = call.arguments as? Bool else {
                    result(FlutterError(
                        code: "INVALID_ARGUMENT",
                        message: "setSecure kutilgan argument: bool",
                        details: nil
                    ))
                    return
                }
                self.isSecure = enabled
                result(nil)
            case "isSecure":
                result(self.isSecure)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        let events = FlutterEventChannel(
            name: Self.eventChannelName,
            binaryMessenger: messenger
        )
        events.setStreamHandler(self)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidTakeScreenshot),
            name: UIApplication.userDidTakeScreenshotNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenCaptureDidChange),
            name: UIScreen.capturedDidChangeNotification,
            object: nil
        )
    }

    func attach(window: UIWindow?) {
        self.window = window
    }

    // MARK: - Blur overlay (M158)

    /// `willResignActive` — app-switcher snapshot'idan OLDIN chaqiriladi.
    func showPrivacyOverlay() {
        guard let window = resolveWindow(), blurView == nil else { return }
        let effect = UIBlurEffect(style: .systemMaterial)
        let view = UIVisualEffectView(effect: effect)
        view.frame = window.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.alpha = 1
        window.addSubview(view)
        blurView = view
    }

    /// `didBecomeActive` — foydalanuvchi ilovaga qaytdi.
    func hidePrivacyOverlay() {
        guard let view = blurView else { return }
        blurView = nil
        UIView.animate(
            withDuration: 0.15,
            animations: { view.alpha = 0 },
            completion: { _ in view.removeFromSuperview() }
        )
    }

    private func resolveWindow() -> UIWindow? {
        if let window { return window }
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }
    }

    // MARK: - Skrinshot / yozuv hodisalari

    @objc private func userDidTakeScreenshot() {
        guard isSecure else { return }
        eventSink?("screenshotTaken")
    }

    @objc private func screenCaptureDidChange() {
        let captured = UIScreen.main.isCaptured
        if captured {
            // Ekran yozuvi / mirroring — himoyalangan ekranda kontentni berkitamiz.
            if isSecure { showPrivacyOverlay() }
            eventSink?("screenRecordingStarted")
        } else {
            if isSecure { hidePrivacyOverlay() }
            eventSink?("screenRecordingStopped")
        }
    }
}

extension ScreenSecurityPlugin: FlutterStreamHandler {
    func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}
