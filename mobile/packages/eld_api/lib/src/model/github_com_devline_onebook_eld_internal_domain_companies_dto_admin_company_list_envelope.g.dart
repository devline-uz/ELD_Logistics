// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_companies_dto_admin_company_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope {
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany>?
      data;
  @override
  final GithubComDevlineOnebookEldInternalDomainCompaniesDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope
      rebuild(
              void Function(
                      GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelopeBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope &&
        data == other.data &&
        meta == other.meta;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, meta.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope,
            GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope?
      _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany>?
      _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany>();
  set data(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoMetaBuilder? _meta;
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoMetaBuilder get meta =>
      _$this._meta ??=
          GithubComDevlineOnebookEldInternalDomainCompaniesDtoMetaBuilder();
  set meta(
          GithubComDevlineOnebookEldInternalDomainCompaniesDtoMetaBuilder?
              meta) =>
      _$this._meta = meta;

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelopeBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data?.toBuilder();
      _meta = $v.meta?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope
              ._(
            data: _data?.build(),
            meta: _meta?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
        _$failedField = 'meta';
        _meta?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope',
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
