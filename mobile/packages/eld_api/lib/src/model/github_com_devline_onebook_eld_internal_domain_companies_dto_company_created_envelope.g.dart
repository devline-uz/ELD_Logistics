// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_companies_dto_company_created_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope
    extends GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated?
      data;

  factory _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope
      rebuild(
              void Function(
                      GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelopeBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope,
            GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope?
      _$v;

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedBuilder?
      _data;
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedBuilder
      get data => _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope',
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
