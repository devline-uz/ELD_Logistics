/// `M-35 DVIR details` kontrolleri.
///
/// **M107:** haydovchi DVIR ni tahrirlay/o'chira olmaydi — ekran faqat o'qish.
/// PDF faqat onlayn (`GET /dvir-reports/{id}/pdf`).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import '../../../../core/error/api_error.dart';
import '../../domain/dvir_models.dart';
import 'dvir_providers.dart';

/// Hisobot yuklash — `id` bo'yicha (onlayn, oflayn — lokal kesh).
final FutureProviderFamily<DvirReport?, String> dvirReportProvider =
    FutureProvider.family<DvirReport?, String>(
      (Ref ref, String id) => ref.watch(dvirRepositoryProvider).byId(id),
    );

/// PDF yuklab olish holati.
class DvirPdfState {
  const DvirPdfState({this.busy = false, this.path, this.error});

  final bool busy;
  final String? path;
  final ApiError? error;
}

class DvirPdfController extends Notifier<DvirPdfState> {
  @override
  DvirPdfState build() => const DvirPdfState();

  Future<void> download(String reportId) async {
    state = const DvirPdfState(busy: true);
    try {
      final String path = await ref.read(dvirRepositoryProvider).downloadPdf(reportId);
      state = DvirPdfState(path: path);
    } on ApiError catch (error) {
      state = DvirPdfState(error: error);
    }
  }
}

final NotifierProvider<DvirPdfController, DvirPdfState> dvirPdfControllerProvider =
    NotifierProvider<DvirPdfController, DvirPdfState>(DvirPdfController.new);
