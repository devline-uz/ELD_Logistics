// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_company_dto_notification_settings_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope
    extends GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope {
  @override
  final BuiltList<
          GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSetting>?
      data;

  factory _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope
      rebuild(
              void Function(
                      GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelopeBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope &&
        data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope,
            GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope?
      _$v;

  ListBuilder<
          GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSetting>?
      _data;
  ListBuilder<
          GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSetting>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSetting>();
  set data(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSetting>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelopeBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope
              ._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope',
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
