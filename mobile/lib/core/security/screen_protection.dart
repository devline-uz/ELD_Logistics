/// **S-H5 / M157 / M158** — ekran himoyasining Dart tomoni.
///
/// Platforma tomoni tayyor:
///  * Android — `MainActivity` `WindowManager.LayoutParams.FLAG_SECURE` ni
///    yoqadi/o'chiradi (app-switcher snapshot'i ham qoraytiriladi);
///  * iOS — `ScreenSecurityPlugin` blur overlay (M158) + skrinshot/ekran
///    yozuvi eventlari.
///
/// Qoida (M157): `setSecure(true)` **faqat** `M-04 PIN`, `M-05 Invite`,
/// `M-08 2FA`, `M-30 Sign`, `M-38 Begin inspection` ekranlarida yoqiladi va
/// ekrandan chiqishda **majburiy** tozalanadi — boshqa ekranlarda support
/// skrinshoti ishlashi kerak.
///
/// Ishlatish (istalgan modul, shu jumladan `certify` va `inspection`):
/// ```dart
/// class _SignScreenState extends ConsumerState<SignScreen>
///     with SecureScreenMixin<SignScreen> { ... }
/// ```
/// yoki Riverpod'siz joyda:
/// ```dart
/// await ref.read(screenProtectionProvider).setSecure(true);
/// ```
library;

import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Kanal nomlari — platforma kodi bilan **aynan** bir xil.
abstract final class ScreenSecurityChannels {
  const ScreenSecurityChannels._();

  static const String method = 'uz.stackyard.eld_mobile/screen_security';

  /// Faqat iOS'da mavjud; Android'da bu kanal umuman ro'yxatdan o'tmagan.
  static const String events = 'uz.stackyard.eld_mobile/screen_security_events';

  static const String setSecure = 'setSecure';
  static const String isSecure = 'isSecure';

  /// Platforma `setSecure` ga bool bo'lmagan argument kelganda qaytaradi.
  static const String invalidArgument = 'INVALID_ARGUMENT';
}

/// iOS'dan keladigan ekran ushlash hodisalari (Android'da hech qachon emas).
enum ScreenCaptureEvent {
  screenshotTaken,
  screenRecordingStarted,
  screenRecordingStopped;

  static ScreenCaptureEvent? parse(Object? raw) => switch (raw) {
    'screenshotTaken' => ScreenCaptureEvent.screenshotTaken,
    'screenRecordingStarted' => ScreenCaptureEvent.screenRecordingStarted,
    'screenRecordingStopped' => ScreenCaptureEvent.screenRecordingStopped,
    _ => null,
  };
}

/// `FLAG_SECURE` / iOS snapshot himoyasi ustidagi yupqa o'ram.
///
/// Hech qachon **istisno tashlamaydi**: kanal yo'q bo'lsa (test muhiti,
/// eski platforma build'i) himoya jimgina o'tkazib yuboriladi — ekran
/// baribir ochilishi kerak. Bu holat `lastError` da qoladi (diagnostika).
class ScreenProtection {
  ScreenProtection({MethodChannel? channel, EventChannel? eventChannel, bool? iosEvents})
    : _channel = channel ?? const MethodChannel(ScreenSecurityChannels.method),
      _eventChannel = eventChannel ?? const EventChannel(ScreenSecurityChannels.events),
      // Android'da event kanali YO'Q — unga obuna bo'lish
      // `MissingPluginException` beradi, shuning uchun platforma bo'yicha
      // qo'riqlanadi (test uchun ochiq parametr).
      _iosEvents = iosEvents ?? _isIOS;

  static bool get _isIOS {
    try {
      return Platform.isIOS;
    } on Object catch (_) {
      return false;
    }
  }

  final MethodChannel _channel;
  final EventChannel _eventChannel;
  final bool _iosEvents;

  /// Oxirgi kanal xatosi (faqat diagnostika uchun; PII yo'q).
  PlatformException? lastError;

  /// Ekran himoyasini yoqadi/o'chiradi.
  ///
  /// Argument platformaga **to'g'ridan-to'g'ri bool** sifatida uzatiladi
  /// (map emas) — Kotlin/Swift tomoni aynan shuni kutadi.
  Future<void> setSecure(bool enabled) async {
    try {
      await _channel.invokeMethod<void>(ScreenSecurityChannels.setSecure, enabled);
      lastError = null;
    } on PlatformException catch (error) {
      lastError = error;
    } on MissingPluginException catch (_) {
      // Test / desktop muhiti — himoya yo'q, lekin ilova yiqilmaydi.
      return;
    }
  }

  /// Hozir himoya yoqilganmi (diagnostika va testlar uchun).
  Future<bool> isSecure() async {
    try {
      return await _channel.invokeMethod<bool>(ScreenSecurityChannels.isSecure) ?? false;
    } on PlatformException catch (error) {
      lastError = error;
      return false;
    } on MissingPluginException catch (_) {
      return false;
    }
  }

  /// Skrinshot / ekran yozuvi hodisalari — **faqat iOS**.
  ///
  /// Android'da bo'sh oqim qaytadi (kanal mavjud emas). Hodisa PII saqlamaydi,
  /// shuning uchun uni audit izida ishlatish mumkin (M159 buzilmaydi).
  Stream<ScreenCaptureEvent> captureEvents() {
    if (!_iosEvents) {
      return const Stream<ScreenCaptureEvent>.empty();
    }
    return _eventChannel
        .receiveBroadcastStream()
        .map(ScreenCaptureEvent.parse)
        .where((ScreenCaptureEvent? e) => e != null)
        .cast<ScreenCaptureEvent>()
        .handleError((Object _) {});
  }
}

/// Butun ilova uchun yagona instans. Testda `overrideWithValue` bilan
/// almashtiriladi.
final Provider<ScreenProtection> screenProtectionProvider = Provider<ScreenProtection>(
  (Ref ref) => ScreenProtection(),
);

/// M157: himoyani ekran umriga bog'laydigan mixin.
///
/// `initState` da yoqadi, `dispose` da **majburiy** o'chiradi. `dispose` da
/// `ref` ga murojaat qilinmaydi (Riverpod'da xavfsiz emas) — obyekt
/// `initState` da olinadi.
mixin SecureScreenMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  ScreenProtection? _protection;

  @override
  void initState() {
    super.initState();
    final ScreenProtection protection = ref.read(screenProtectionProvider);
    _protection = protection;
    unawaited(protection.setSecure(true));
  }

  @override
  void dispose() {
    // Ekrandan chiqishda flag tozalanadi — aks holda butun ilova
    // skrinshotsiz qolib ketadi (M157).
    unawaited(_protection?.setSecure(false) ?? Future<void>.value());
    _protection = null;
    super.dispose();
  }
}
