// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_notifications_dto_push_token_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope
    extends GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken? data;

  factory _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope,
            GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope?
      _$v;

  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenBuilder?
      _data;
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenBuilder
      get data => _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope',
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
