/// Migratsiya karkasi (M21): v1 → v2 (`violations` jadvali) va kelajakdagi
/// qadamlar uchun shablon. Chiqarilgan qadam **hech qachon** tahrirlanmaydi.

library;

import 'package:drift/drift.dart';
import 'package:eld_mobile/core/db/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('joriy sxema toza yaratiladi va qayta ochilganda migratsiya ishlamaydi', () async {
    final AppDatabase first = AppDatabase.memory();
    await first.databaseSizeBytes(); // ochilishni majburlaydi
    expect(first.schemaVersion, 2);
    await first.close();
  });

  test('onUpgrade noma\'lum versiyaga o\'tishda aniq xato beradi', () async {
    final AppDatabase db = AppDatabase.memory();
    addTearDown(db.close);
    await db.databaseSizeBytes();

    // v3 qadami hali yo'q: forward-only ro'yxatga qo'shilmagan versiya
    // jimgina o'tib ketmasligi kerak.
    await expectLater(() => db.stepByStep()(Migrator(db), 2, 3), throwsA(isA<StateError>()));
  });

  test('v1 → v1 hech qanday qadam bajarmaydi', () async {
    final AppDatabase db = AppDatabase.memory();
    addTearDown(db.close);
    await db.databaseSizeBytes();
    await db.stepByStep()(Migrator(db), 1, 1);
  });
}
