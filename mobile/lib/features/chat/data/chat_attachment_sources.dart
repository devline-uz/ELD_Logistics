/// [ChatAttachmentPicker] va [ChatLocationSource] ning vaqtinchalik
/// implementatsiyalari (M139/§14.3).
///
/// TODO(P12): platforma paketlari qo'shilgach shu sinflar almashtiriladi —
/// portlar va UI o'zgarmaydi.
library;

import '../domain/chat_attachment.dart';

/// Hech narsa tanlamaydi (paket hali ulanmagan) — UI xatosiz bekor qiladi.
class UnavailableChatAttachmentPicker implements ChatAttachmentPicker {
  const UnavailableChatAttachmentPicker();

  @override
  Future<PickedAttachment?> pick(ChatAttachmentKind kind) async => null;
}

/// GPS manbai ulanmagan.
class UnavailableChatLocationSource implements ChatLocationSource {
  const UnavailableChatLocationSource();

  @override
  Future<ChatLocationFix?> current() async => null;
}
