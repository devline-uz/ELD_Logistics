@Timeout(Duration(seconds: 60))
library;

import 'package:eld_mobile/core/db/daos/settings_dao.dart';
import 'package:eld_mobile/core/db/kv_store.dart';
import 'package:eld_mobile/core/session/session_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ProviderContainer containerWith(InMemoryKvStore store) {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[kvStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('kv_settings dan yuklanadi (M4/M8 «No unit assigned» muammosi)', () async {
    final InMemoryKvStore store = InMemoryKvStore(<String, String>{
      KvKeys.driverId: 'driver-1',
      KvKeys.driverName: 'Ali Karimov',
      KvKeys.unitNumber: '1021',
      KvKeys.vehicleLabel: 'ABC-123',
      KvKeys.carrierName: 'Onebook LLC',
      KvKeys.homeTerminalAddress: '12 Main St, Chicago',
      KvKeys.homeTerminalTz: 'America/Chicago',
    });
    final ProviderContainer container = containerWith(store);

    await container.read(sessionProfileProvider.notifier).reload();
    final SessionProfile profile = container.read(sessionProfileProvider);

    expect(profile.driverId, 'driver-1');
    expect(profile.unitNumber, '1021');
    expect(profile.carrierName, 'Onebook LLC');
    expect(profile.homeTerminalAddress, '12 Main St, Chicago');
    expect(profile.homeTerminalTz, 'America/Chicago');
    expect(profile.isEmpty, isFalse);
  });

  test('write bo\'lakni birlashtiradi va kv_settings ga yozadi', () async {
    final InMemoryKvStore store = InMemoryKvStore();
    final ProviderContainer container = containerWith(store);
    final SessionProfileNotifier notifier = container.read(sessionProfileProvider.notifier);

    // Login javobi: faqat haydovchi.
    await notifier.write(const SessionProfile(driverId: 'driver-1', driverName: 'Ali Karimov'));
    // `sync/pull`: unit va carrier.
    await notifier.write(const SessionProfile(unitNumber: '1021', carrierName: 'Onebook LLC'));

    final SessionProfile profile = container.read(sessionProfileProvider);
    expect(profile.driverId, 'driver-1');
    expect(profile.driverName, 'Ali Karimov');
    expect(profile.unitNumber, '1021');
    expect(await store.read(KvKeys.carrierName), 'Onebook LLC');
    expect(await store.read(KvKeys.driverName), 'Ali Karimov');
  });

  test('bo\'sh bo\'lak mavjud qiymatni o\'chirmaydi', () async {
    final InMemoryKvStore store = InMemoryKvStore();
    final ProviderContainer container = containerWith(store);
    final SessionProfileNotifier notifier = container.read(sessionProfileProvider.notifier);

    await notifier.write(const SessionProfile(driverId: 'd-1', unitNumber: '1021'));
    await notifier.write(const SessionProfile(driverName: 'Ali'));

    expect(container.read(sessionProfileProvider).unitNumber, '1021');
    expect(await store.read(KvKeys.unitNumber), '1021');
  });

  test('toString PII chiqarmaydi (M159)', () {
    const SessionProfile profile = SessionProfile(
      driverId: 'd-1',
      driverName: 'Ali Karimov',
      driverEmail: 'ali@example.com',
    );
    expect(profile.toString(), 'SessionProfile(d-1)');
  });
}
