package uz.stackyard.eld_mobile

import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * S-H5 (M157 / M158) — ekran himoyasi.
 *
 * Dart tomoni `uz.stackyard.eld_mobile/screen_security` kanali orqali chaqiradi:
 *   - `setSecure(bool enabled)` -> `null`
 *       `true`  : WindowManager.LayoutParams.FLAG_SECURE yoqiladi — skrinshot,
 *                 ekran yozuvi va app-switcher snapshot'i bloklanadi.
 *       `false` : flag tozalanadi (support skrinshotlari uchun).
 *   - `isSecure()` -> `bool` (test/diagnostika uchun).
 *
 * FLAG_SECURE faqat M-04 PIN, M-05 Invite, M-08 2FA, M-30 Sign, M-38 Begin inspection
 * ekranlarida yoqiladi va ekrandan chiqishda MAJBURIY tozalanadi.
 *
 * Android'da FLAG_SECURE app-switcher snapshot'ini ham qoraytiradi, shuning uchun
 * iOS'dagi kabi alohida blur overlay kerak emas.
 */
class MainActivity : FlutterActivity() {

    private var channel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SCREEN_SECURITY_CHANNEL,
        ).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "setSecure" -> {
                        val enabled = call.arguments as? Boolean
                        if (enabled == null) {
                            result.error(
                                "INVALID_ARGUMENT",
                                "setSecure kutilgan argument: bool",
                                null,
                            )
                        } else {
                            applySecure(enabled)
                            result.success(null)
                        }
                    }

                    "isSecure" -> result.success(isSecureEnabled())

                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        channel?.setMethodCallHandler(null)
        channel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    private fun applySecure(enabled: Boolean) {
        // UI thread'da bajarilishi shart — kanal handler'i allaqachon main'da ishlaydi.
        if (enabled) {
            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        } else {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }

    private fun isSecureEnabled(): Boolean =
        (window.attributes.flags and WindowManager.LayoutParams.FLAG_SECURE) != 0

    private companion object {
        const val SCREEN_SECURITY_CHANNEL = "uz.stackyard.eld_mobile/screen_security"
    }
}
