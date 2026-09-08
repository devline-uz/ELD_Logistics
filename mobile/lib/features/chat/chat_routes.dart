/// Chat modulining marshrutlari (eld-screens registri: M-42).
///
/// M89: `Chat` — pastki tab bar'ning 3-bo'limi (badge = o'qilmagan xabarlar).
/// Planshetda `T-34` — o'ng ustundagi panel, ekran emas.
/// **M142**: haydash rejimida (`M-15`) chat ikonkasi umuman ko'rsatilmaydi.
library;

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'presentation/screens/chat_screen.dart';

abstract final class ChatRoute {
  const ChatRoute._();

  /// `M-42 Chat` — bitta thread («Dispatch»).
  static const String thread = '/chat';
}

/// `GoRouter` ga qo'shiladigan chat marshrutlari.
final List<RouteBase> chatRoutes = <RouteBase>[
  GoRoute(
    path: ChatRoute.thread,
    builder: (BuildContext context, GoRouterState state) => const ChatScreen(),
  ),
];
