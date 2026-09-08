@Timeout(Duration(seconds: 60))
/// #B-24: M7 modullari sessiyani `core/session` dan oladi (ilgari `logs`
/// modulining `presentation` papkasidagi `LogsSession` dan olardi).
library;

import 'package:eld_mobile/core/db/kv_store.dart';
import 'package:eld_mobile/core/session/session_context.dart';
import 'package:eld_mobile/core/session/session_profile.dart';
import 'package:eld_mobile/core/time/day_boundary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromProfile maydonlarni ko\'chiradi, TZ bo\'sh bo\'lsa UTC', () {
    const SessionProfile profile = SessionProfile(
      driverId: 'drv-1',
      driverName: 'John Doe',
      unitId: 'unit-1',
      unitNumber: '1021',
      homeTerminalAddress: '5432 Lorem Ipsum',
    );

    final SessionContext context = SessionContext.fromProfile(profile);
    expect(context.driverId, 'drv-1');
    expect(context.driverName, 'John Doe');
    expect(context.unitId, 'unit-1');
    expect(context.unitNumber, '1021');
    expect(context.homeTerminal, '5432 Lorem Ipsum');
    // M42: zona noma'lum bo'lsa ham kun chegarasi qurilma TZ siga tushmaydi.
    expect(context.homeTerminalTz, kFallbackTimeZone);
  });

  test('home_terminal_tz profildan olinadi', () {
    const SessionProfile profile = SessionProfile(
      driverId: 'drv-1',
      homeTerminalTz: 'America/Chicago',
    );
    expect(SessionContext.fromProfile(profile).homeTerminalTz, 'America/Chicago');
    expect(
      SessionContext.fromProfile(
        const SessionProfile(driverId: 'd', homeTerminalTz: ''),
      ).homeTerminalTz,
      kFallbackTimeZone,
    );
  });

  test('provayder `sessionProfileProvider` dan hosil bo\'ladi (override kerak emas)', () async {
    final InMemoryKvStore store = InMemoryKvStore();
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[kvStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);

    await container
        .read(sessionProfileProvider.notifier)
        .write(
          const SessionProfile(
            driverId: 'drv-9',
            unitNumber: '77',
            homeTerminalTz: 'America/New_York',
          ),
        );

    expect(container.read(sessionContextProvider).driverId, 'drv-9');
    expect(container.read(sessionContextProvider).unitNumber, '77');
    expect(container.read(homeTerminalTzProvider), 'America/New_York');
  });

  test('toString PII chiqarmaydi (M159)', () {
    const SessionContext context = SessionContext(driverId: 'drv-1', driverName: 'John Doe');
    expect(context.toString(), 'SessionContext(drv-1)');
    expect(context.toString(), isNot(contains('John')));
  });

  test('qiymat tengligi (Riverpod ortiqcha rebuild qilmasin)', () {
    const SessionContext a = SessionContext(driverId: 'd', unitNumber: '1');
    const SessionContext b = SessionContext(driverId: 'd', unitNumber: '1');
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(const SessionContext(driverId: 'd', unitNumber: '2')));
  });
}
