/// Tema rejimi va Zoom toggle (M94).
library;

import 'package:eld_mobile/core/db/daos/settings_dao.dart';
import 'package:eld_mobile/core/db/kv_store.dart';
import 'package:eld_mobile/core/session/session_profile.dart';
import 'package:eld_mobile/core/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;
  late InMemoryKvStore store;

  setUp(() {
    store = InMemoryKvStore();
    container = ProviderContainer(overrides: <Override>[kvStoreProvider.overrideWithValue(store)]);
  });
  tearDown(() => container.dispose());

  AppUiSettingsNotifier notifier() => container.read(appUiSettingsProvider.notifier);
  AppUiSettings state() => container.read(appUiSettingsProvider);

  test('boshlang\'ich holat: system + normal zoom', () {
    expect(state().themeMode, ThemeMode.system);
    expect(state().zoom, ZoomLevel.normal);
  });

  test('tema rejimi o\'zgaradi', () {
    notifier().setThemeMode(ThemeMode.dark);
    expect(state().themeMode, ThemeMode.dark);
  });

  test('toggleTheme joriy brightness ning teskarisiga o\'tadi', () {
    notifier().toggleTheme(Brightness.light);
    expect(state().themeMode, ThemeMode.dark);
    notifier().toggleTheme(Brightness.dark);
    expect(state().themeMode, ThemeMode.light);
  });

  test('Zoom toggle normal ↔ large', () {
    notifier().toggleZoom();
    expect(state().zoom, ZoomLevel.large);
    notifier().toggleZoom();
    expect(state().zoom, ZoomLevel.normal);
  });

  test('M94: tanlov kv_settings ga yoziladi', () async {
    notifier().setThemeMode(ThemeMode.dark);
    notifier().setZoom(ZoomLevel.large);

    // `unawaited` yozuv navbatining tugashini kutamiz.
    await Future<void>.delayed(Duration.zero);

    expect(await store.read(KvKeys.themeMode), 'dark');
    expect(await store.read(KvKeys.textScale), 'large');
  });

  test('M94: ilova qayta ochilganda tanlov tiklanadi', () async {
    final InMemoryKvStore saved = InMemoryKvStore(<String, String>{
      KvKeys.themeMode: 'light',
      KvKeys.textScale: 'large',
    });
    final ProviderContainer restored = ProviderContainer(
      overrides: <Override>[kvStoreProvider.overrideWithValue(saved)],
    );
    addTearDown(restored.dispose);

    await restored.read(appUiSettingsProvider.notifier).restore();

    expect(restored.read(appUiSettingsProvider).themeMode, ThemeMode.light);
    expect(restored.read(appUiSettingsProvider).zoom, ZoomLevel.large);
  });

  test('noma\'lum saqlangan qiymat standartni buzmaydi', () async {
    final ProviderContainer restored = ProviderContainer(
      overrides: <Override>[
        kvStoreProvider.overrideWithValue(
          InMemoryKvStore(<String, String>{KvKeys.themeMode: 'neon'}),
        ),
      ],
    );
    addTearDown(restored.dispose);

    await restored.read(appUiSettingsProvider.notifier).restore();
    expect(restored.read(appUiSettingsProvider).themeMode, ThemeMode.system);
  });

  test('AppUiSettings tenglik va copyWith', () {
    const AppUiSettings a = AppUiSettings();
    expect(a.copyWith(), a);
    expect(a.copyWith(zoom: ZoomLevel.large), isNot(a));
    expect(a.hashCode, const AppUiSettings().hashCode);
  });
}
