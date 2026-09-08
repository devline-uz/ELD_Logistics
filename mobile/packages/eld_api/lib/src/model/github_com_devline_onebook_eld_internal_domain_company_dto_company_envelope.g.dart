// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_company_dto_company_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope
    extends GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainCompanyDtoCompany? data;

  factory _$GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope,
            GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope',
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
