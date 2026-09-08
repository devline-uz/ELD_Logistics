// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_companies_dto_admin_company_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope
    extends GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany? data;

  factory _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope,
            GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope?
      _$v;

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope',
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
