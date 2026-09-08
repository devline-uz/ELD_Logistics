// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_company_dto_notification_settings_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate
    extends GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate {
  @override
  final BuiltList<
          GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdate>
      settings;

  factory _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdateBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdateBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate._(
      {required this.settings})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate
      rebuild(
              void Function(
                      GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdateBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdateBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdateBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate &&
        settings == other.settings;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, settings.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate')
          ..add('settings', settings))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdateBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate,
            GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdateBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate?
      _$v;

  ListBuilder<
          GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdate>?
      _settings;
  ListBuilder<
          GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdate>
      get settings => _$this._settings ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdate>();
  set settings(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdate>?
              settings) =>
      _$this._settings = settings;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdateBuilder() {
    GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdateBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _settings = $v.settings.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdateBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate
              ._(
            settings: settings.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'settings';
        settings.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
