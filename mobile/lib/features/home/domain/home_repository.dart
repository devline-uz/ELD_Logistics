/// `M-09` uchun domen interfeysi (M5).
library;

import '../../duty_status/domain/hos_snapshot.dart';
import 'home_models.dart';

abstract class HomeRepository {
  /// Oxirgi 8 kunning sertifikatsiya holati (`Certify (Last 8 days)`).
  Stream<List<CertifyDay>> watchCertifyDays({int days = 8});

  /// Haydovchi qaroriga muhtoj tahrir so'rovlari soni (`M-26`).
  Stream<int> watchPendingEditCount();

  /// Da'vo qilinishi mumkin bo'lgan unidentified segmentlar soni (`M-28`).
  Stream<int> watchUnidentifiedCount();

  /// Joriy kunning 24 soatlik grid segmentlari.
  Future<List<DutyDaySegment>> todaySegments({required DateTime now});
}
