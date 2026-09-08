/// FMCSA Appendix A malfunction / diagnostic kodlari (tz-mobile §10.6, M77).
///
/// Kod harfi wire formatda (`notes`, `diagnostics[]`) ishlatiladi, shuning uchun
/// **hech qachon o'zgartirilmaydi**.
library;

/// Nosozlik turi: `malfunction` doimiy qizil banner, `diagnostic` — sariq.
enum EldFaultKind {
  malfunction,
  diagnostic;

  String get wire => name;
}

/// `P/E/T/L/R/S/O` kodlari.
enum EldFaultCode {
  /// Power compliance — quvvat uzilishi.
  power('P'),

  /// Engine synchronization — ECM bilan sinxronlik yo'q.
  engineSync('E'),

  /// Timing — soat farqi > 10 daqiqa (§7.2).
  timing('T'),

  /// Positioning — pozitsiya olinmadi.
  positioning('L'),

  /// Data recording — lokal yozuv joyi yo'q.
  dataRecording('R'),

  /// Data transfer — loglar uzoq vaqt uzatilmadi (M78).
  dataTransfer('S'),

  /// Other — vendor bergan boshqa kod.
  other('O');

  const EldFaultCode(this.letter);

  /// Wire qiymati — bitta katta harf.
  final String letter;

  static EldFaultCode? fromLetter(String value) {
    final String v = value.trim().toUpperCase();
    for (final EldFaultCode code in EldFaultCode.values) {
      if (code.letter == v) {
        return code;
      }
    }
    return null;
  }
}

/// Aniqlangan nosozlik — detektor va transport shu tipni chiqaradi.
class EldFault implements Comparable<EldFault> {
  const EldFault({required this.code, required this.kind, required this.detectedAt, this.detail});

  final EldFaultCode code;
  final EldFaultKind kind;

  /// `TimeSource` bergan UTC vaqt (`DateTime.now()` taqiq).
  final DateTime detectedAt;

  /// Ixtiyoriy qo'shimcha (masalan `S` uchun kunlar soni) — **PII yo'q**.
  final String? detail;

  bool get isMalfunction => kind == EldFaultKind.malfunction;

  /// Outbox `event_type=malfunction` uchun `notes` qiymati (M77).
  String get notes => detail == null ? code.letter : '${code.letter}:$detail';

  @override
  int compareTo(EldFault other) => code.index.compareTo(other.code.index);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EldFault &&
          other.code == code &&
          other.kind == kind &&
          other.detectedAt == detectedAt &&
          other.detail == detail;

  @override
  int get hashCode => Object.hash(code, kind, detectedAt, detail);

  @override
  String toString() => 'EldFault(${code.letter}, ${kind.wire}, $detectedAt, $detail)';
}
