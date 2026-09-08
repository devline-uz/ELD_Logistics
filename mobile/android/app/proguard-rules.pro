# ONEBOOK ELD — R8 qoidalari (release).
# Flutter engine va plaginlar uchun zarur saqlashlar.

# Flutter embedding
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# flutter_foreground_task — xizmat refleksiya orqali topiladi.
-keep class com.pravera.flutter_foreground_task.** { *; }

# flutter_blue_plus — BLE callback'lari.
-keep class com.boskokg.flutter_blue_plus.** { *; }
-keep class com.lib.flutter_blue_plus.** { *; }

# sqlite3 / SQLCipher native bindinglari
-keep class net.zetetic.** { *; }
-keep class com.davidmoten.** { *; }
-dontwarn org.sqlite.**

# Play Core (deferred components) — Flutter ishlatmasa ham havola qoladi.
-dontwarn com.google.android.play.core.**

# Log chiqishini release'da o'chirish (PII sizishiga qarshi, M159).
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
