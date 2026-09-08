/// Tema rejimi va `Zoom` toggle (tz-mobile M94).
///
/// Tanlov `kv_settings` da saqlanadi (`theme_mode`, `text_scale`) — ilova qayta
/// ochilganda tiklanadi. Do'kon `core/session/kvStoreProvider` dan keladi:
/// bootstrap uni `DriftKvStore` bilan almashtiradi, testlarda esa xotiradagi
/// implementatsiya ishlaydi (Drift ochilmagan holatda ham provayder yiqilmaydi).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/daos/settings_dao.dart';
import '../db/kv_store.dart';
import '../session/session_profile.dart';
import 'typography.dart';

/// Foydalanuvchi tanlagan ko'rinish sozlamalari.
@immutable
class AppUiSettings {
  const AppUiSettings({this.themeMode = ThemeMode.system, this.zoom = ZoomLevel.normal});

  /// `Profile › Dark mode` (telefon) / app bar tema ikonkasi (planshet).
  final ThemeMode themeMode;

  /// M94 `Zoom` — matnni yiriklashtirish.
  final ZoomLevel zoom;

  AppUiSettings copyWith({ThemeMode? themeMode, ZoomLevel? zoom}) =>
      AppUiSettings(themeMode: themeMode ?? this.themeMode, zoom: zoom ?? this.zoom);

  @override
  bool operator ==(Object other) =>
      other is AppUiSettings && other.themeMode == themeMode && other.zoom == zoom;

  @override
  int get hashCode => Object.hash(themeMode, zoom);
}

/// `kv_settings` dagi barqaror satrlar (enum `name` iga bog'lanmaydi).
@visibleForTesting
abstract final class UiSettingsWire {
  const UiSettingsWire._();

  static String themeMode(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };

  static ThemeMode? parseThemeMode(String? raw) => switch (raw) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    'system' => ThemeMode.system,
    _ => null,
  };

  static String zoom(ZoomLevel level) => switch (level) {
    ZoomLevel.normal => 'normal',
    ZoomLevel.large => 'large',
  };

  static ZoomLevel? parseZoom(String? raw) => switch (raw) {
    'normal' => ZoomLevel.normal,
    'large' => ZoomLevel.large,
    _ => null,
  };
}

class AppUiSettingsNotifier extends Notifier<AppUiSettings> {
  @override
  AppUiSettings build() {
    unawaited(restore());
    return const AppUiSettings();
  }

  KvStore get _store => ref.read(kvStoreProvider);

  /// `kv_settings` dan oxirgi tanlovni tiklaydi (M94).
  Future<void> restore() async {
    final Map<String, String> values = await _store.readAll(<String>[
      KvKeys.themeMode,
      KvKeys.textScale,
    ]);
    final ThemeMode? mode = UiSettingsWire.parseThemeMode(values[KvKeys.themeMode]);
    final ZoomLevel? zoom = UiSettingsWire.parseZoom(values[KvKeys.textScale]);
    if (mode == null && zoom == null) {
      return;
    }
    state = state.copyWith(themeMode: mode, zoom: zoom);
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    unawaited(_store.write(KvKeys.themeMode, UiSettingsWire.themeMode(mode)));
  }

  /// Light ↔ dark almashtirish. `system` holatida joriy `platformBrightness`
  /// ning teskarisiga o'tadi.
  void toggleTheme(Brightness current) {
    setThemeMode(current == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
  }

  void setZoom(ZoomLevel zoom) {
    state = state.copyWith(zoom: zoom);
    unawaited(_store.write(KvKeys.textScale, UiSettingsWire.zoom(zoom)));
  }

  void toggleZoom() => setZoom(state.zoom.toggled);
}

final NotifierProvider<AppUiSettingsNotifier, AppUiSettings> appUiSettingsProvider =
    NotifierProvider<AppUiSettingsNotifier, AppUiSettings>(AppUiSettingsNotifier.new);
