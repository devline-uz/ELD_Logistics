/// Planshet modallari (`T-*`) testlari uchun umumiy qobiq.
///
/// `showAdaptiveModal` `BuildContext` talab qiladi, shuning uchun modal
/// tugma orqali ochiladi.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Planshet referens o'lchami (tz-mobile §3).
const Size kTabletSurface = Size(1366, 1024);

/// Telefon referens o'lchami.
const Size kPhoneSurface = Size(393, 852);

/// Modalni ochish tugmasi matni.
const String kOpenModalLabel = 'open-modal';

/// Modalni ochuvchi minimal ekran.
class ModalHost extends StatelessWidget {
  const ModalHost({required this.open, super.key});

  final Future<void> Function(BuildContext context) open;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Builder(
        builder: (BuildContext inner) =>
            TextButton(onPressed: () => open(inner), child: const Text(kOpenModalLabel)),
      ),
    ),
  );
}

/// Tugmani bosib modalni ochadi va kadrlarni suradi
/// (`pumpAndSettle` emas — skelet shimmer cheksiz animatsiya beradi).
Future<void> openModal(WidgetTester tester) async {
  await tester.tap(find.text(kOpenModalLabel));
  for (int i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}
