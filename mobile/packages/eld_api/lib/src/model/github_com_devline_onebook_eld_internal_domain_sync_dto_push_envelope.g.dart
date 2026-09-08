// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_sync_dto_push_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope
    extends GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse? data;

  factory _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope._({this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelopeBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope,
            GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponseBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponseBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponseBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponseBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope other) {
    _$v =
        other as _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope',
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
