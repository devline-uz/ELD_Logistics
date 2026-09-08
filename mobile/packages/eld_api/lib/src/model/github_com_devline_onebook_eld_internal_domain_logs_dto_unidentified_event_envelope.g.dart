// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_logs_dto_unidentified_event_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope
    extends GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent? data;

  factory _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope,
            GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope?
      _$v;

  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventBuilder?
      _data;
  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventBuilder
      get data => _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope',
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
