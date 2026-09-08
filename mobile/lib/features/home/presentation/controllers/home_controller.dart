/// `M-09 Home` kontrolleri (M7: telefon `M-09` va planshet `T-01` uchun bitta).
///
/// Kontroller **agregator**: barcha ma'lumot lokal Drift provayderlaridan
/// keladi, hisoblash `hos_engine` da. Bu yerda biznes qoidasi yozilmaydi.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/daos/outbox_dao.dart';
import '../../../../core/db/db_providers.dart';
import '../../../../core/eld/eld_providers.dart';
import '../../../../core/eld/eld_session.dart';
import '../../../duty_status/data/duty_status_providers.dart';
import '../../../duty_status/domain/duty_status_models.dart';
import '../../../duty_status/domain/duty_status_repository.dart';
import '../../../duty_status/domain/hos_snapshot.dart';
import '../../data/home_providers.dart';
import '../../domain/home_models.dart';

class HomeController extends Notifier<HomeState> {
  late final DutyStatusRepository _duty = ref.read(dutyStatusRepositoryProvider);

  @override
  HomeState build() {
    final AsyncValue<DutyStatusContext> duty = ref.watch(dutyStatusContextProvider);
    final DutyStatusContext context = duty.value ?? DutyStatusContext.empty();
    final HosSnapshot hos =
        ref.watch(hosSnapshotProvider).value ??
        HosSnapshot.empty(context.since ?? DateTime.utc(2000));
    final EldSessionState? eld = ref.watch(eldSessionProvider).value;
    final OutboxQueueStats? outbox = ref.watch(outboxStatsProvider).value;

    return HomeState(
      duty: context,
      hos: hos,
      loading: duty.isLoading,
      eld: _banner(eld),
      malfunctionCode: eld == null || eld.malfunctions.isEmpty
          ? null
          : eld.malfunctions.first.code.letter,
      queuedRecords: outbox?.pendingTotal ?? 0,
      pendingEdits: ref.watch(pendingEditCountProvider).value ?? 0,
      unidentified: ref.watch(unidentifiedCountProvider).value ?? 0,
      certifyDays: ref.watch(certifyDaysProvider).value ?? const <CertifyDay>[],
      trip: TripDetails(
        shippingDocs: context.shippingDocIds,
        trailers: context.trailerIds,
        notes: context.notes,
      ),
      segments: ref.watch(todaySegmentsProvider).value ?? const <DutyDaySegment>[],
    );
  }

  static HomeEldBanner _banner(EldSessionState? state) {
    if (state == null) {
      return HomeEldBanner.notConnected;
    }
    if (state.hasMalfunction) {
      return HomeEldBanner.malfunction;
    }
    return state.connection.isConnected ? HomeEldBanner.connected : HomeEldBanner.notConnected;
  }

  /// `M-11 Edit documents` — status **o'zgarmaydi** (M53).
  Future<void> saveDocuments({
    required List<String> trailerIds,
    required List<String> shippingDocIds,
    String? notes,
  }) => _duty.updateDocuments(trailerIds: trailerIds, shippingDocIds: shippingDocIds, notes: notes);

  /// Pull-to-refresh: HOS va grid qayta hisoblanadi (sync `core/sync` da).
  void refresh() {
    ref.invalidate(hosSnapshotProvider);
    ref.invalidate(todaySegmentsProvider);
  }
}

final NotifierProvider<HomeController, HomeState> homeControllerProvider =
    NotifierProvider<HomeController, HomeState>(HomeController.new);
