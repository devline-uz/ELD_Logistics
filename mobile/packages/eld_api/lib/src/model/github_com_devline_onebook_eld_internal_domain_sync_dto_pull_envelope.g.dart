// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_sync_dto_pull_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope
    extends GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse? data;

  factory _$GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope._({this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelopeBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope,
            GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponseBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponseBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponseBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponseBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope other) {
    _$v =
        other as _$GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope',
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
