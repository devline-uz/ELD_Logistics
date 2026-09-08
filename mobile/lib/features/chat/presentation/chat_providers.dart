/// `M-42` provayderlari — DI faqat Riverpod orqali (`get_it` yo'q).
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/db_providers.dart';
import '../../../core/sync/sync_providers.dart';
import '../../../core/time/time_providers.dart';
import '../../../core/time/time_source.dart';
import '../data/chat_attachment_sources.dart';
import '../data/chat_local_data_source.dart';
import '../data/chat_remote_data_source.dart';
import '../data/chat_repository_impl.dart';
import '../data/driving_mode_source_impl.dart';
import '../data/queued_chat_file_uploader.dart';
import '../domain/chat_attachment.dart';
import '../domain/chat_message.dart';
import '../domain/chat_ports.dart';
import '../domain/chat_repository.dart';

/// TODO(CORE): `core/network/api_client.dart` uchun umumiy provayder hali yo'q —
/// bootstrap (`main.dart`) shuni `overrideWithValue(ApiClient…dio)` qiladi.
final Provider<Dio> chatDioProvider = Provider<Dio>((Ref ref) {
  throw UnimplementedError('chatDioProvider bootstrap da override qilinadi');
});

/// TODO(M-02): sessiya moduli tayyor bo'lgach `authSessionProvider` dan olinadi.
final Provider<String> currentDriverIdProvider = Provider<String>((Ref ref) {
  throw UnimplementedError('currentDriverIdProvider sessiyadan override qilinadi');
});

/// M140/M141 manbai (hozircha xotirada — `duty_status` ulanmagan).
final Provider<DrivingModeSource> drivingModeSourceProvider = Provider<DrivingModeSource>((
  Ref ref,
) {
  final InMemoryDrivingModeSource source = InMemoryDrivingModeSource();
  ref.onDispose(source.dispose);
  return source;
});

final Provider<ChatFileUploader> chatFileUploaderProvider = Provider<ChatFileUploader>((Ref ref) {
  final TimeSource time = ref.watch(timeSourceProvider);
  return QueuedChatFileUploader(dao: ref.watch(dvirDaoProvider), now: time.now);
});

/// M139: `+` menyusidagi rasm/fayl tanlash manbai.
final Provider<ChatAttachmentPicker> chatAttachmentPickerProvider = Provider<ChatAttachmentPicker>(
  (Ref ref) => const UnavailableChatAttachmentPicker(),
);

/// §14.3: joriy GPS nuqtasi.
final Provider<ChatLocationSource> chatLocationSourceProvider = Provider<ChatLocationSource>(
  (Ref ref) => const UnavailableChatLocationSource(),
);

final Provider<ChatRemoteDataSource> chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>(
  (Ref ref) => HttpChatRemoteDataSource(ref.watch(chatDioProvider)),
);

final Provider<ChatLocalDataSource> chatLocalDataSourceProvider = Provider<ChatLocalDataSource>(
  (Ref ref) => ChatLocalDataSource(
    dao: ref.watch(chatDaoProvider),
    outbox: ref.watch(outboxRepositoryProvider),
    currentDriverId: ref.watch(currentDriverIdProvider),
  ),
);

/// Chat repozitoriysi — `presentation` faqat shu portni ko'radi (M5).
final Provider<ChatRepository> chatRepositoryProvider = Provider<ChatRepository>((Ref ref) {
  final ChatRepositoryImpl repository = ChatRepositoryImpl(
    local: ref.watch(chatLocalDataSourceProvider),
    remote: ref.watch(chatRemoteDataSourceProvider),
    uploader: ref.watch(chatFileUploaderProvider),
    driving: ref.watch(drivingModeSourceProvider),
    time: ref.watch(timeSourceProvider),
    driverId: ref.watch(currentDriverIdProvider),
  );
  ref.onDispose(repository.dispose);
  return repository;
});

/// Pastki tab badge'i (M89) va app bar uchun: navbatdagi xabarlar soni.
final StreamProvider<int> chatQueuedCountProvider = StreamProvider<int>(
  (Ref ref) => ref.watch(chatRepositoryProvider).watchQueuedCount(),
);

/// M140: kiritish qatori bloklanishi.
final StreamProvider<bool> chatDrivingModeProvider = StreamProvider<bool>(
  (Ref ref) => ref.watch(chatRepositoryProvider).watchDrivingMode(),
);

/// Lokal keshdagi xabarlar (oflayn ham to'la).
final StreamProvider<List<ChatMessage>> chatMessagesProvider = StreamProvider<List<ChatMessage>>(
  (Ref ref) => ref.watch(chatRepositoryProvider).watchMessages(),
);
