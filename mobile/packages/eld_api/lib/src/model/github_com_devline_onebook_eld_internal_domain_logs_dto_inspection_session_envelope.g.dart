// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_logs_dto_inspection_session_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionEnvelope
    extends GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSession? data;

  factory _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionEnvelope,
            GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionEnvelope?
      _$v;

  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionBuilder?
      _data;
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionBuilder
      get data => _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionEnvelope',
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
