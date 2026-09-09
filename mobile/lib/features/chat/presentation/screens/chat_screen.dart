/// `M-42 Chat` (telefon) va `T-34 Chat` (planshet paneli).
///
/// Bitta [ChatController] — ikkala profil uchun (M7). Farq faqat `View` da:
/// telefonda to'liq ekran, planshetda kengroq ustun.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/device/device_profile.dart';
import '../../../../core/error/api_error.dart';
import '../../../../core/error/api_error_messages.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/chat_attachment.dart';
import '../../domain/chat_message.dart';
import '../../domain/chat_send_policy.dart';
import '../chat_providers.dart';
import '../controllers/chat_controller.dart';
import '../widgets/chat_attachment_sheet.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_composer.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final ChatUiState ui = ref.watch(chatControllerProvider);
    final AsyncValue<List<ChatMessage>> messages = ref.watch(chatMessagesProvider);
    final bool driving = ref.watch(chatDrivingModeProvider).value ?? false;
    final int queued = ref.watch(chatQueuedCountProvider).value ?? 0;

    return AdaptiveScaffold(
      applyHorizontalPadding: false,
      // Figma `1118-114`: chapda `<` qaytish, sarlavha chapga tekislangan,
      // o'ngda amal guruhi **yo'q** (#B-26).
      appBar: AppBarPrimary(
        title: l10n.chatTitle,
        leading: const AppBackButton(),
        showDefaultActions: false,
      ),
      banners: <Widget>[
        if (queued > 0)
          BannerStrip(message: l10n.chatQueuedBanner(queued), tone: BannerTone.offline),
      ],
      bottomBar: ChatComposer(
        enabled: !driving,
        errorText: _rejectionText(context, ui.rejection),
        onSend: (String text) => ref.read(chatControllerProvider.notifier).sendText(text),
        onAttach: () => _attach(context, ref),
      ),
      phone: (BuildContext context) => _ChatBody(ui: ui, messages: messages),
      tablet: (BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: _ChatBody(ui: ui, messages: messages),
        ),
      ),
    );
  }

  static String? _rejectionText(BuildContext context, ChatSendRejection? rejection) =>
      switch (rejection) {
        null || ChatSendRejection.emptyText => null,
        ChatSendRejection.drivingMode => context.l10n.chatDrivingDisabled,
        ChatSendRejection.textTooLong => context.l10n.chatMessageTooLong,
        ChatSendRejection.fileTooLarge => context.l10n.chatFileTooLarge,
        ChatSendRejection.invalidLocation => context.l10n.errValidation,
      };

  static Future<void> _attach(BuildContext context, WidgetRef ref) async {
    final ChatAttachmentKind? kind = await showChatAttachmentSheet(context);
    if (kind == null) {
      return;
    }
    final ChatController controller = ref.read(chatControllerProvider.notifier);
    if (kind == ChatAttachmentKind.location) {
      final ChatLocationFix? fix = await ref.read(chatLocationSourceProvider).current();
      if (fix != null) {
        await controller.send(ChatDraft.location(latitude: fix.lat, longitude: fix.lng));
      }
      return;
    }
    final PickedAttachment? picked = await ref.read(chatAttachmentPickerProvider).pick(kind);
    if (picked == null) {
      return;
    }
    final ChatDraft draft = kind == ChatAttachmentKind.photo
        ? ChatDraft.image(path: picked.path)
        : ChatDraft.file(path: picked.path);
    await controller.send(draft, fileSizeBytes: picked.sizeBytes);
  }
}

class _ChatBody extends ConsumerWidget {
  const _ChatBody({required this.ui, required this.messages});

  final ChatUiState ui;
  final AsyncValue<List<ChatMessage>> messages;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final List<ChatMessage> list = messages.value ?? const <ChatMessage>[];

    // Yuklanish: lokal kesh ham bo'sh bo'lsa skeleton.
    if (list.isEmpty && (ui.initialLoading || messages.isLoading)) {
      return const LoadingSkeleton(itemCount: 6);
    }
    // Xato: kesh bo'sh bo'lsa to'liq ekran, aks holda ro'yxat + banner.
    if (list.isEmpty && ui.loadError != null) {
      final ApiError error = ui.loadError!;
      return ErrorState(
        message: localizedApiError(l10n, error),
        retryLabel: l10n.commonRetry,
        onRetry: () => ref.read(chatControllerProvider.notifier).refresh(),
      );
    }
    if (list.isEmpty) {
      return EmptyState(
        icon: Icons.forum_outlined,
        title: l10n.chatEmptyTitle,
        message: l10n.chatEmptyMessage,
      );
    }
    return _MessageList(ui: ui, messages: list);
  }
}

class _MessageList extends ConsumerWidget {
  const _MessageList({required this.ui, required this.messages});

  final ChatUiState ui;
  final List<ChatMessage> messages;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final ChatController controller = ref.read(chatControllerProvider.notifier);
    final List<ChatDaySection> sections = groupChatByDay(messages, dayOf: _dayOf);

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: context.deviceProfile == DeviceProfile.tablet
              ? Spacing.screenPaddingTablet
              : Spacing.screenPaddingPhone,
          vertical: Spacing.s10,
        ),
        children: <Widget>[
          if (ui.loadingOlder)
            const Center(
              child: Padding(padding: EdgeInsets.all(Spacing.s10), child: _Spinner()),
            )
          else if (ui.hasMore)
            AppButton.text(label: l10n.chatLoadOlder, onPressed: controller.loadOlder)
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: Spacing.s10),
                child: Text(
                  l10n.chatNoMoreMessages,
                  style: context.text.body16.copyWith(color: context.colors.textSecondary),
                ),
              ),
            ),
          for (final ChatDaySection section in sections) ...<Widget>[
            _DayDivider(day: section.day),
            for (final ChatMessage message in section.messages)
              ChatBubble(
                message: message,
                sendWhenStopped: ui.sendWhenStopped,
                onRetry: controller.retry,
                onSendWhenStoppedChanged: (bool value) =>
                    controller.setSendWhenStopped(value: value),
              ),
          ],
          if (ui.peerTyping) const ChatTypingBubble(),
        ],
      ),
    );
  }

  /// TODO(M42): Home Terminal TZ ulangach kun chegarasi `TimeSource` dan
  /// olinadi; hozircha qurilma lokal kuni.
  static DateTime _dayOf(DateTime utc) {
    final DateTime local = utc.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}

class _DayDivider extends StatelessWidget {
  const _DayDivider({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: Spacing.s10),
    child: Center(
      child: Text(
        AppFormats.listHeaderOf(day),
        style: context.text.body16.copyWith(color: context.colors.textSecondary),
      ),
    ),
  );
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: Spacing.s20,
    height: Spacing.s20,
    child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.primary),
  );
}
