/// `core/ui` testlari uchun umumiy qobiq.
library;

import 'package:eld_mobile/core/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Referens o'lchamlar (tz-mobile §3).
const Size kPhoneSize = Size(393, 852);
const Size kTabletSize = Size(1366, 1024);

/// Widget'ni tema va berilgan qurilma o'lchami bilan qo'yadi.
Future<void> pumpUi(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.light,
  Size size = kPhoneSize,
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.of(brightness),
      home: MediaQuery(
        data: MediaQueryData(size: size, textScaler: TextScaler.linear(textScale)),
        child: Scaffold(body: Center(child: child)),
      ),
    ),
  );
}

/// Widget daraxtidagi birinchi `BuildContext`.
BuildContext contextOf(WidgetTester tester) => tester.element(find.byType(Scaffold));
