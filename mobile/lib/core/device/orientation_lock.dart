/// Orientatsiya qulfi (tz-mobile §3, M6): telefon — **faqat portret**,
/// planshet — **faqat landshaft**.
///
/// Qurilma turi `MediaQuery.size` dan emas, `DeviceProfile` dan aniqlanadi
/// (M7). Ilova ishga tushganda bir marta chaqiriladi; `PlatformDispatcher`
/// birinchi ko'rinishi yetarli, `BuildContext` kerak emas.
///
/// Nega qattiq qulf: kabinada planshet kreslo orasiga o'rnatiladi va
/// portretga aylanishi log gridni va uch ustunli T-01 layout'ini buzadi
/// (M120: ekran scroll qilinmasligi kerak).
library;

import 'dart:ui' show FlutterView, PlatformDispatcher;

import 'package:flutter/services.dart';

import 'device_profile.dart';

abstract final class OrientationLock {
  const OrientationLock._();

  /// Telefon uchun ruxsat etilgan orientatsiyalar.
  static const List<DeviceOrientation> phone = <DeviceOrientation>[DeviceOrientation.portraitUp];

  /// Planshet uchun: ikkala landshaft yo'nalishi (qurilma qaysi tomonga
  /// o'rnatilgani noma'lum).
  static const List<DeviceOrientation> tablet = <DeviceOrientation>[
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  /// Profil bo'yicha ruxsat etilgan orientatsiyalar.
  static List<DeviceOrientation> allowedFor(DeviceProfile profile) =>
      profile.isTablet ? tablet : phone;

  /// Joriy qurilma profilini aniqlab, orientatsiyani qulflaydi.
  static Future<void> apply() {
    final FlutterView view = PlatformDispatcher.instance.views.first;
    final DeviceProfile profile = DeviceProfile.fromSize(view.physicalSize / view.devicePixelRatio);
    return SystemChrome.setPreferredOrientations(allowedFor(profile));
  }
}
