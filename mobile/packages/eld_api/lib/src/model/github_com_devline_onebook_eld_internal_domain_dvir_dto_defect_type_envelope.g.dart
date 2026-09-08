// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_dvir_dto_defect_type_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelope
    extends GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType? data;

  factory _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelope,
            GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelope other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelope._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelope',
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
