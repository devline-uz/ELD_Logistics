/// Oflayn-first yozish amallarining natijasi (M11 klasteri uchun umumiy).
///
/// `feedback` va `support` modullari bir xil qoidaga bo'ysunadi: tarmoq
/// bo'lmasa so'rov `outbox_items` ga tushadi va keyin yuboriladi (§5.3).
library;

enum SubmitOutcome {
  /// Server javob berdi (201).
  sent,

  /// Oflayn: navbatga qo'yildi.
  queued,
}
