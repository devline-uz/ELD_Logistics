/// `+` menyusi (M139/§14.3): telefon — `AppBottomSheet`, planshet — `TabletModal`.
library;

import 'package:flutter/material.dart';

import '../../../../core/device/device_profile.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/chat_attachment.dart';

/// Tanlangan bandni qaytaradi (`null` — bekor).
Future<ChatAttachmentKind?> showChatAttachmentSheet(BuildContext context) {
  final bool tablet = context.deviceProfile == DeviceProfile.tablet;
  if (tablet) {
    return showDialog<ChatAttachmentKind>(
      context: context,
      builder: (BuildContext context) => TabletModal(
        title: context.l10n.chatAttachTitle,
        cancelLabel: context.l10n.commonCancel,
        onCancel: () => Navigator.of(context).pop(),
        child: const ChatAttachmentOptions(),
      ),
    );
  }
  return showModalBottomSheet<ChatAttachmentKind>(
    context: context,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(borderRadius: Radii.sheetRadius),
    builder: (BuildContext context) =>
        AppBottomSheet(title: context.l10n.chatAttachTitle, child: const ChatAttachmentOptions()),
  );
}

/// Uch band — golden test uchun alohida widget.
class ChatAttachmentOptions extends StatelessWidget {
  const ChatAttachmentOptions({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final (ChatAttachmentKind kind, IconData icon, String label) item
            in <(ChatAttachmentKind, IconData, String)>[
              (ChatAttachmentKind.photo, Icons.image_outlined, context.l10n.chatAttachPhoto),
              (ChatAttachmentKind.file, Icons.attach_file, context.l10n.chatAttachFile),
              (ChatAttachmentKind.location, Icons.place_outlined, context.l10n.chatAttachLocation),
            ])
          ListTile(
            leading: Icon(item.$2, color: c.icon),
            title: Text(item.$3, style: context.text.body12.copyWith(color: c.textPrimary)),
            minTileHeight: touchTarget(context),
            onTap: () => Navigator.of(context).pop(item.$1),
          ),
      ],
    );
  }
}
