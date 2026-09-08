/// Nuqson katalogi qoidalari (tz-mobile M105, #B-12).
///
/// Katalog **serverdan** keladi (`GET /defect-types`). Dizayndagi 44 bandli
/// statik ro'yxat faqat **fallback** va u tozalanadi:
///   * `Engine` dublikati olib tashlanadi (44 → 43);
///   * `Refresh` bandi nuqson emas — olib tashlanadi;
///   * `Accident Photo` nuqson emas — alohida foto bandi (`kAccidentPhotoName`).
///
/// Bu qoidalar serverdan kelgan ro'yxatga ham qo'llanadi: ma'lumot bazasi
/// dublikat yoki `Refresh` qaytarsa ham UI toza bo'ladi (B-12 acceptance).
library;

import 'dvir_models.dart';

/// «Nuqson emas» bandlar — katalogdan chiqariladi.
const Set<String> kNonDefectNames = <String>{'refresh'};

/// Alohida foto yuklash bandi sifatida ajratiladi (M105).
const String kAccidentPhotoName = 'accident photo';

/// Katalogni tozalaydi: `Refresh` va `Accident Photo` chiqariladi, nom bo'yicha
/// dublikatlar (registrga sezgir emas) birinchi uchraganidan tashqari olib
/// tashlanadi, tartib `sort_order` → `name`.
List<DefectType> sanitizeDefectCatalog(Iterable<DefectType> source) {
  final Set<String> seen = <String>{};
  final List<DefectType> result = <DefectType>[];

  for (final DefectType type in source) {
    final String key = _normalize(type.name);
    if (key.isEmpty || kNonDefectNames.contains(key) || key == kAccidentPhotoName) {
      continue;
    }
    // `category` bilan birga: `Other` truck va trailer'da alohida band bo'lishi mumkin.
    if (!seen.add('${type.category.wire}/$key')) {
      continue;
    }
    result.add(type);
  }

  result.sort((DefectType a, DefectType b) {
    final int byOrder = a.sortOrder.compareTo(b.sortOrder);
    return byOrder != 0 ? byOrder : a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });
  return result;
}

/// Katalogda `Accident Photo` bandi bormi (alohida foto bloki ko'rsatiladi).
bool catalogHasAccidentPhoto(Iterable<DefectType> source) =>
    source.any((DefectType t) => _normalize(t.name) == kAccidentPhotoName);

/// Qidiruv filtri (M-33 🎨 qidiruv maydoni).
List<DefectType> filterDefects(List<DefectType> catalog, String query) {
  final String q = _normalize(query);
  if (q.isEmpty) {
    return catalog;
  }
  return catalog.where((DefectType t) => _normalize(t.name).contains(q)).toList();
}

String _normalize(String value) => value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

/// Dizayndagi statik ro'yxat (`1169:1467` va `1113:8737`) — **fallback**, server
/// katalogi bo'lmaganda ishlatiladi. `Engine` bu yerda **bir marta**, `Refresh`
/// va `Accident Photo` umuman yo'q (#B-12).
///
/// `id` — `local:` prefiksli, chunki server `defect_type_id` si yo'q; bunday
/// nuqson bilan yuborish `DEFECT_TYPE_UNKNOWN` beradi, shuning uchun fallback
/// faqat **ko'rsatish** uchun (yuborish onlayn katalog kelgach).
const List<String> kFallbackTruckDefectNames = <String>[
  'Air Compressor',
  'Air Lines',
  'Battery',
  'Body',
  'Brake Accessories',
  'Brakes, Parking',
  'Brakes, Service',
  'Clutch',
  'Coupling Device',
  'Defroster/Heater',
  'Drive Line',
  'Engine',
  'Exhaust',
  'Fifth Wheel',
  'Frame and Assembly',
  'Front Axle',
  'Fuel Tanks',
  'Heater',
  'Horn',
  'Lights',
  'Mirrors',
  'Muffler',
  'Oil Pressure',
  'Radiator',
  'Rear End',
  'Reflectors',
  'Safety Equipment',
  'Springs',
  'Starter',
  'Steering',
  'Suspension System',
  'Tire Chains',
  'Tires',
  'Transmission',
  'Trip Recorder',
  'Wheels and Rims',
  'Windows',
  'Windshield Wipers',
  'Other',
];

const List<String> kFallbackTrailerDefectNames = <String>[
  'Brakes',
  'Coupling Devices',
  'Doors',
  'Hitch',
  'Landing Gear',
  'Lights',
  'Roof',
  'Springs',
  'Tarpaulin',
  'Tires',
  'Wheels and Rims',
  'Other',
];

/// Fallback katalogni domen modeliga o'giradi.
List<DefectType> buildFallbackCatalog() {
  final List<DefectType> list = <DefectType>[];
  for (int i = 0; i < kFallbackTruckDefectNames.length; i++) {
    list.add(
      DefectType(
        id: 'local:truck:${_normalize(kFallbackTruckDefectNames[i])}',
        name: kFallbackTruckDefectNames[i],
        category: DefectCategory.truck,
        sortOrder: i,
      ),
    );
  }
  for (int i = 0; i < kFallbackTrailerDefectNames.length; i++) {
    list.add(
      DefectType(
        id: 'local:trailer:${_normalize(kFallbackTrailerDefectNames[i])}',
        name: kFallbackTrailerDefectNames[i],
        category: DefectCategory.trailer,
        sortOrder: i,
      ),
    );
  }
  return sanitizeDefectCatalog(list);
}
