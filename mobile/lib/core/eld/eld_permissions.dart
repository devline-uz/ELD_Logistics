/// Ruxsatlar oqimi (tz-mobile §10.2, M69, M70).
///
/// Ketma-ketlik **[MUST]**:
/// ```
/// 1 Notifications → 2 Bluetooth → 3 Location (When in use)
/// → 4 Location (Always, alohida ekran) → 5 Battery optimization istisnosi
/// ```
/// Ruxsat rad etilsa ilova **bloklanmaydi**: `Permissions` bandida qizil belgi
/// va Home'da banner ko'rinadi (M69). «Don't ask again» → tizim sozlamalari.
///
/// **Qat'iy:** UI qatlami platforma tipini ko'rmaydi — faqat
/// [EldPermissionService]. Implementatsiyalar: [MockEldPermissionService]
/// (birinchi, barcha ekranlar u bilan ishlaydi) va
/// `PlatformEldPermissionService` (`MethodChannel('eld/permissions')`).
library;

/// So'raladigan ruxsatlar (§10.2 jadvali).
enum EldPermission {
  /// `POST_NOTIFICATIONS` (Android 13+) / `UNUserNotificationCenter` (iOS).
  notifications,

  /// Android 12+: `BLUETOOTH_SCAN` (`neverForLocation` **qo'yilmaydi**) +
  /// `BLUETOOTH_CONNECT`; iOS: `NSBluetoothAlwaysUsageDescription`.
  bluetooth,

  /// `ACCESS_FINE_LOCATION` / `NSLocationWhenInUseUsageDescription`.
  locationWhenInUse,

  /// `ACCESS_BACKGROUND_LOCATION` / `NSLocationAlwaysAndWhenInUseUsageDescription`.
  ///
  /// **Alohida ekranda** so'raladi (Play review, risk R1).
  locationAlways,

  /// `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` — faqat Android, iOS'da
  /// [EldPermissionStatus.notApplicable].
  batteryOptimization;

  /// M-18 jadvalida ko'rsatiladigan bandlar (battery — alohida qatorda emas).
  static const List<EldPermission> screenRows = <EldPermission>[
    EldPermission.locationWhenInUse,
    EldPermission.locationAlways,
    EldPermission.bluetooth,
    EldPermission.notifications,
  ];

  /// So'rash tartibi (§10.2 [MUST]).
  static const List<EldPermission> requestOrder = <EldPermission>[
    EldPermission.notifications,
    EldPermission.bluetooth,
    EldPermission.locationWhenInUse,
    EldPermission.locationAlways,
    EldPermission.batteryOptimization,
  ];

  /// Wire qiymati — platform channel argumenti.
  String get wire => switch (this) {
    EldPermission.notifications => 'notifications',
    EldPermission.bluetooth => 'bluetooth',
    EldPermission.locationWhenInUse => 'location_when_in_use',
    EldPermission.locationAlways => 'location_always',
    EldPermission.batteryOptimization => 'battery_optimization',
  };

  static EldPermission? fromWire(String value) {
    for (final EldPermission p in EldPermission.values) {
      if (p.wire == value) {
        return p;
      }
    }
    return null;
  }
}

/// Ruxsat holati.
enum EldPermissionStatus {
  granted,

  /// Rad etilgan, lekin qayta so'rash mumkin.
  denied,

  /// «Don't ask again» / iOS'da bir marta rad etilgan — `openAppSettings()`.
  permanentlyDenied,

  /// MDM yoki ota-ona nazorati bloklagan.
  restricted,

  /// Bu platformada/versiyada talab qilinmaydi (masalan iOS batareya).
  notApplicable,

  /// Hali so'ralmagan.
  unknown;

  static EldPermissionStatus fromWire(String value) => switch (value) {
    'granted' => EldPermissionStatus.granted,
    'denied' => EldPermissionStatus.denied,
    'permanently_denied' => EldPermissionStatus.permanentlyDenied,
    'restricted' => EldPermissionStatus.restricted,
    'not_applicable' => EldPermissionStatus.notApplicable,
    _ => EldPermissionStatus.unknown,
  };

  /// M-18 jadvalida `Allowed` / `Not allowed`.
  bool get isAllowed => this == granted || this == notApplicable;

  /// Faqat sozlamalar orqali tuzatiladi (M69).
  bool get needsSettings => this == permanentlyDenied || this == restricted;
}

/// Ruxsatlar va tizim xizmatlari kesimi.
class EldPermissionSnapshot {
  const EldPermissionSnapshot({
    this.statuses = const <EldPermission, EldPermissionStatus>{},
    this.bluetoothOn = false,
    this.locationServicesOn = false,
  });

  final Map<EldPermission, EldPermissionStatus> statuses;

  /// Bluetooth adapteri yoqilganmi (`Turn on bluetooth` toggle).
  final bool bluetoothOn;

  /// GPS/Location Services yoqilganmi (`Turn on GPS` toggle).
  final bool locationServicesOn;

  EldPermissionStatus statusOf(EldPermission permission) =>
      statuses[permission] ?? EldPermissionStatus.unknown;

  bool isAllowed(EldPermission permission) => statusOf(permission).isAllowed;

  /// ELD ga ulanish uchun **minimal** to'plam (M70 dialogining sharti).
  static const List<EldPermission> connectRequired = <EldPermission>[
    EldPermission.bluetooth,
    EldPermission.locationWhenInUse,
  ];

  /// M70: ulanish uchun barcha kerakli ruxsatlar bormi.
  bool get canConnectEld => connectRequired.every(isAllowed) && bluetoothOn;

  /// M69: drawer'dagi qizil belgi va Home banneri sharti.
  bool get hasWarning =>
      EldPermission.screenRows.any((EldPermission p) => !isAllowed(p)) ||
      !bluetoothOn ||
      !locationServicesOn;

  /// Rad etilganlar (banner matnida sanaladi).
  List<EldPermission> get missing =>
      EldPermission.screenRows.where((EldPermission p) => !isAllowed(p)).toList(growable: false);

  EldPermissionSnapshot copyWith({
    Map<EldPermission, EldPermissionStatus>? statuses,
    bool? bluetoothOn,
    bool? locationServicesOn,
  }) => EldPermissionSnapshot(
    statuses: statuses ?? this.statuses,
    bluetoothOn: bluetoothOn ?? this.bluetoothOn,
    locationServicesOn: locationServicesOn ?? this.locationServicesOn,
  );

  @override
  String toString() =>
      'EldPermissionSnapshot(missing=${missing.map((EldPermission p) => p.wire)}, '
      'bt=$bluetoothOn, gps=$locationServicesOn)';
}

/// Ruxsat so'rash shartnomasi.
abstract class EldPermissionService {
  /// Joriy holat (so'ramasdan o'qish).
  Future<EldPermissionSnapshot> snapshot();

  /// Holat o'zgarishlari (ilova foreground'ga qaytganda qayta o'qiladi).
  Stream<EldPermissionSnapshot> get changes;

  /// Bitta ruxsatni so'raydi va yangi holatini qaytaradi.
  Future<EldPermissionStatus> request(EldPermission permission);

  /// §10.2 ketma-ketligi bo'yicha barchasini so'raydi (onboarding).
  ///
  /// Har qadamda foydalanuvchi rad etsa ham **keyingisiga o'tiladi** (M69).
  Future<EldPermissionSnapshot> requestOnboardingFlow();

  /// «Don't ask again» holatida — tizim sozlamalari (M69).
  Future<void> openAppSettings();

  /// `Turn on GPS` toggle — tizim location sozlamalari.
  Future<void> openLocationSettings();

  /// `Turn on bluetooth` toggle — tizim BT sozlamalari (Android'da so'rov
  /// dialogi, iOS'da Settings).
  Future<void> openBluetoothSettings();

  /// Holatni qayta o'qiydi va [changes] ga chiqaradi.
  Future<EldPermissionSnapshot> refresh();

  Future<void> dispose();
}
