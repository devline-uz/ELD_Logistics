/// `M-57 Force update` uchun do'kon havolasini ochish porti.
///
/// `url_launcher` `pubspec.yaml` da hali yo'q (paket qo'shish bu agentning
/// hududidan tashqarida) — shuning uchun port abstraksiya sifatida yozildi.
/// TODO(P-01): `url_launcher` qo'shilgach [SystemStoreLauncher] uning
/// `launchUrl` chaqiruvi bilan almashtiriladi.
library;

/// Do'kon sahifasini ochadi.
abstract interface class StoreLauncher {
  /// `true` — do'kon ochildi; `false` — qurilmada mos ilova topilmadi
  /// (`authUpdateStoreUnavailable` ko'rsatiladi).
  Future<bool> openStore();
}

/// Platforma implementatsiyasi yo'q paytdagi xavfsiz zaxira: hech narsa
/// ochmaydi va foydalanuvchiga xabar berilishini ta'minlaydi.
class SystemStoreLauncher implements StoreLauncher {
  const SystemStoreLauncher();

  @override
  Future<bool> openStore() async => false;
}
