/// Fon xizmati provayderlari (§10.4).
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../eld/eld_providers.dart';
import '../location/location_providers.dart';
import 'android_foreground_service.dart';
import 'background_coordinator.dart';
import 'background_service.dart';
import 'state_restoration.dart';

/// Bildirishnoma kanali nomi/tavsifi.
///
/// `core` da lokalizatsiya konteksti yo'q, shuning uchun matn bootstrap'da
/// `overrideWithValue` orqali `context.l10n` dan beriladi.
class BackgroundChannelLabels {
  const BackgroundChannelLabels({required this.name, required this.description});

  final String name;
  final String description;
}

/// Kanal matnlari. Standart qiymat — bo'sh: `app.dart` bootstrap'i ilova
/// qurilishida `context.l10n.eldServiceChannelName/Description` bilan
/// to'ldiradi (`core` da `BuildContext` yo'q). Xizmat faqat shundan keyin
/// ishga tushadi, shuning uchun bo'sh qiymat foydalanuvchiga ko'rinmaydi.
class BackgroundChannelLabelsNotifier extends Notifier<BackgroundChannelLabels> {
  @override
  BackgroundChannelLabels build() => const BackgroundChannelLabels(name: '', description: '');

  void set({required String name, required String description}) {
    final BackgroundChannelLabels next = BackgroundChannelLabels(
      name: name,
      description: description,
    );
    if (state.name != next.name || state.description != next.description) {
      state = next;
    }
  }
}

final NotifierProvider<BackgroundChannelLabelsNotifier, BackgroundChannelLabels>
backgroundChannelLabelsProvider =
    NotifierProvider<BackgroundChannelLabelsNotifier, BackgroundChannelLabels>(
      BackgroundChannelLabelsNotifier.new,
    );

/// Platformaga mos fon xizmati (iOS'da FGS yo'q — `Noop`).
final Provider<BackgroundService> backgroundServiceProvider = Provider<BackgroundService>((
  Ref ref,
) {
  final BackgroundChannelLabels labels = ref.watch(backgroundChannelLabelsProvider);
  final BackgroundService service = !kIsWeb && Platform.isAndroid
      ? AndroidForegroundService(channelName: labels.name, channelDescription: labels.description)
      : NoopBackgroundService();
  ref.onDispose(service.dispose);
  return service;
});

/// Xizmat + GPS profili + haydash bayrog'i.
final Provider<BackgroundCoordinator> backgroundCoordinatorProvider =
    Provider<BackgroundCoordinator>((Ref ref) {
      final BackgroundCoordinator coordinator = BackgroundCoordinator(
        service: ref.watch(backgroundServiceProvider),
        location: ref.watch(locationServiceProvider),
      );
      coordinator.attachMotion(ref.watch(motionRunnerProvider).events);
      ref.onDispose(coordinator.dispose);
      return coordinator;
    });

/// **M74:** tiklanish koordinatori. `onRestored` bootstrap'da sync scheduler'ni
/// ishga tushirish bilan override qilinadi.
final Provider<StateRestorationCoordinator> stateRestorationProvider =
    Provider<StateRestorationCoordinator>((Ref ref) {
      final StateRestorationCoordinator coordinator = StateRestorationCoordinator(
        onRestored: (RestoreReason reason) async {
          // M74: darhol ELD ulanishini tiklaymiz; sync scheduler'ni bootstrap
          // override qiladi (`core/sync` boshqa agent qo'lida).
          await ref.read(eldConnectionManagerProvider).start();
        },
      );
      ref.onDispose(coordinator.dispose);
      return coordinator;
    });
