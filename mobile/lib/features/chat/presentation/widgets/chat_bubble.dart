/// `M-42` xabar pufakchasi (Figma `1118-114`, dark `2665-34989`).
///
/// O'lchamlar Figma'dan (#B-26): maks. kenglik ro'yxat enining **75 %** i
/// (393 dp ekranda ≈ 264 dp), matn 14/20, ichki padding gorizontal 15 /
/// vertikal 10 (Figma 16/6 — `Spacing` shkalasidagi eng yaqin qadam),
/// burchak radiusi `r16`, «dum» tomonidagi pastki burchak `r4`;
/// vaqt va holat belgisi pufakcha ostida (12/20, `textSecondary`).
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/chat_message.dart';

/// #B-26: pufakcha eng ko'pi bilan ro'yxat enining 75 % ini egallaydi.
const double kChatBubbleMaxWidthFactor = 0.75;

/// #B-26: `r16`, «dum» burchagi (o'z xabarida pastki o'ng, boshqasida pastki
/// chap) `r4`. `StadiumBorder` **ishlatilmaydi** — ko'p qatorli xabarda shakl
/// buziladi.
BorderRadius chatBubbleRadius({required bool mine}) => BorderRadius.only(
  topLeft: const Radius.circular(Radii.group),
  topRight: const Radius.circular(Radii.group),
  bottomLeft: Radius.circular(mine ? Radii.group : Radii.sm),
  bottomRight: Radius.circular(mine ? Radii.sm : Radii.group),
);

/// TODO(CORE): `AppFormats` da kunlik vaqt (`hh:mm a`) yordamchisi yo'q —
/// §11.0.7 jadvalidagi format shu yerda takrorlanadi (M92: `intl` + `en_US`).
final DateFormat kChatBubbleTime = DateFormat('hh:mm a', kFormatLocale);

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    required this.message,
    required this.onRetry,
    this.sendWhenStopped = true,
    this.onSendWhenStoppedChanged,
    super.key,
  });

  final ChatMessage message;

  /// M138: rad etilgan xabarni qayta yuborish.
  final ValueChanged<String> onRetry;

  /// M141 2-band: `Send when stopped` (default yoqilgan).
  final bool sendWhenStopped;
  final ValueChanged<bool>? onSendWhenStoppedChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final bool mine = message.isMine;
    final bool blocked = message.status == ChatMessageStatus.blocked;

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.s10),
      child: Column(
        crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) => ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth * kChatBubbleMaxWidthFactor,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  // M141: bloklangan pufakcha kulrang bo'ladi.
                  color: mine && !blocked ? c.primary : c.surfaceAlt,
                  borderRadius: chatBubbleRadius(mine: mine),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.s15,
                    vertical: Spacing.s10,
                  ),
                  child: _Body(message: message, onPrimaryBackground: mine && !blocked),
                ),
              ),
            ),
          ),
          const SizedBox(height: Spacing.s5),
          _MetaRow(message: message),
          if (blocked) ...<Widget>[
            Text(
              context.l10n.chatBlockedNotSent,
              style: context.text.body16.copyWith(color: c.error),
            ),
            _SendWhenStopped(value: sendWhenStopped, onChanged: onSendWhenStoppedChanged),
          ],
          if (message.status == ChatMessageStatus.failed)
            AppButton.text(
              label: context.l10n.chatRetryAction,
              expand: false,
              onPressed: () => onRetry(message.clientId ?? message.id),
            ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.message, required this.onPrimaryBackground});

  final ChatMessage message;
  final bool onPrimaryBackground;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Color fg = onPrimaryBackground ? c.onPrimary : c.textPrimary;
    final TextStyle style = context.text.body15.copyWith(color: fg);

    return switch (message.kind) {
      ChatMessageKind.text => Text(AppFormats.orNa(message.text), style: style),
      ChatMessageKind.image => _Attachment(
        icon: Icons.image_outlined,
        label: message.text ?? context.l10n.chatImageMessage,
        style: style,
        color: fg,
        progress: message.uploadProgress,
      ),
      ChatMessageKind.file => _Attachment(
        icon: Icons.attach_file,
        label: message.text ?? context.l10n.chatFileMessage,
        style: style,
        color: fg,
        progress: message.uploadProgress,
      ),
      ChatMessageKind.location => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _Attachment(
            icon: Icons.place_outlined,
            label: context.l10n.chatLocationMessage,
            style: style,
            color: fg,
            progress: null,
          ),
          const SizedBox(height: Spacing.s5),
          Text(
            '${AppFormats.coordinate(message.lat)}, ${AppFormats.coordinate(message.lng)}',
            style: context.text.body16.copyWith(color: fg),
          ),
          const SizedBox(height: Spacing.s5),
          Text(context.l10n.chatOpenInMaps, style: context.text.body16.copyWith(color: fg)),
        ],
      ),
    };
  }
}

class _Attachment extends StatelessWidget {
  const _Attachment({
    required this.icon,
    required this.label,
    required this.style,
    required this.color,
    required this.progress,
  });

  final IconData icon;
  final String label;
  final TextStyle style;
  final Color color;
  final double? progress;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: Spacing.s20, color: color),
          const SizedBox(width: Spacing.s5),
          Flexible(child: Text(label, style: style)),
        ],
      ),
      if (progress != null) ...<Widget>[
        const SizedBox(height: Spacing.s5),
        Text(
          context.l10n.chatUploading((progress! * 100).round()),
          style: context.text.body16.copyWith(color: color),
        ),
      ],
    ],
  );
}

/// Vaqt + yuborish holati (dizayn: `13:42` va ikki belgi).
class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final (IconData icon, Color color, String label) = _status(context, c);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          kChatBubbleTime.format(message.createdAt.toLocal()),
          style: context.text.body16.copyWith(color: c.textSecondary),
        ),
        if (message.isMine) ...<Widget>[
          const SizedBox(width: Spacing.s5),
          Semantics(
            label: label,
            child: Icon(icon, size: Spacing.s15, color: color),
          ),
        ],
      ],
    );
  }

  (IconData, Color, String) _status(BuildContext context, AppColors c) => switch (message.status) {
    // #B-26: Figma da faqat ✓ / ✓✓ bor — navbatdagi xabar ham bitta ✓ bilan,
    // ammo o'chirilgan rangda ko'rsatiladi (soat ikonkasi yo'q).
    ChatMessageStatus.queued => (Icons.check, c.textDisabled, context.l10n.chatStatusQueued),
    ChatMessageStatus.blocked => (Icons.block, c.error, context.l10n.chatStatusBlocked),
    ChatMessageStatus.failed => (Icons.error_outline, c.error, context.l10n.chatStatusFailed),
    ChatMessageStatus.sent => (Icons.check, c.textSecondary, context.l10n.chatStatusSent),
    ChatMessageStatus.delivered => (
      Icons.done_all,
      c.textSecondary,
      context.l10n.chatStatusDelivered,
    ),
    ChatMessageStatus.read => (Icons.done_all, c.primary, context.l10n.chatStatusRead),
  };
}

class _SendWhenStopped extends StatelessWidget {
  const _SendWhenStopped({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      AppSwitch(
        value: value,
        onChanged: onChanged,
        semanticLabel: context.l10n.chatSendWhenStopped,
      ),
      const SizedBox(width: Spacing.s5),
      Flexible(
        child: Text(
          value ? context.l10n.chatSendWhenStoppedOn : context.l10n.chatSendWhenStopped,
          style: context.text.body16.copyWith(color: context.colors.textSecondary),
        ),
      ),
    ],
  );
}

/// #B-26: «yozmoqda» pufakchasi (`•••`) — Figma `1118-114` dagi oxirgi element.
///
/// Shakli oddiy pufakcha bilan bir xil (r16 + «dum» r4), kengligi kontent
/// bo'yicha; animatsiya golden testda beqaror bo'lgani uchun **statik**.
class ChatTypingBubble extends StatelessWidget {
  const ChatTypingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.s10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Semantics(
          label: context.l10n.chatTyping,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: c.surfaceAlt,
              borderRadius: chatBubbleRadius(mine: false),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.s15, vertical: Spacing.s10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (int i = 0; i < 3; i++) ...<Widget>[
                    if (i > 0) const SizedBox(width: Spacing.s5),
                    _TypingDot(color: c.textPrimary),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypingDot extends StatelessWidget {
  const _TypingDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: Spacing.s5,
    height: Spacing.s5,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
