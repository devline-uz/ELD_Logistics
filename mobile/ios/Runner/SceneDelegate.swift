import Flutter
import UIKit

/// S-H5 / M158 — app-switcher snapshot'i blur bilan yopiladi.
///
/// iOS `sceneWillResignActive` dan keyin, `sceneDidEnterBackground` dan oldin
/// oynaning snapshot'ini oladi. Shuning uchun overlay aynan `willResignActive` da
/// qo'yiladi — aks holda PIN / 2FA / imzo ekrani snapshot keshida diskda qoladi.
class SceneDelegate: FlutterSceneDelegate {

    override func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        super.scene(scene, willConnectTo: session, options: connectionOptions)
        if let windowScene = scene as? UIWindowScene {
            ScreenSecurityPlugin.shared.attach(
                window: windowScene.windows.first { $0.isKeyWindow } ?? windowScene.windows.first
            )
        }
    }

    override func sceneWillResignActive(_ scene: UIScene) {
        ScreenSecurityPlugin.shared.showPrivacyOverlay()
        super.sceneWillResignActive(scene)
    }

    override func sceneDidBecomeActive(_ scene: UIScene) {
        ScreenSecurityPlugin.shared.hidePrivacyOverlay()
        super.sceneDidBecomeActive(scene)
    }
}
