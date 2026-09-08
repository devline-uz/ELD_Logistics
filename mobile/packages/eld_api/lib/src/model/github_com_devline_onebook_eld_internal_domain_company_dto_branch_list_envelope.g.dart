// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_company_dto_branch_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope {
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainCompanyDtoBranch>?
      data;
  @override
  final GithubComDevlineOnebookEldInternalDomainCompanyDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope,
            GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope? _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainCompanyDtoBranch>? _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainCompanyDtoBranch>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainCompanyDtoBranch>();
  set data(
          ListBuilder<GithubComDevlineOnebookEldInternalDomainCompanyDtoBranch>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoMetaBuilder? _meta;
  GithubComDevlineOnebookEldInternalDomainCompanyDtoMetaBuilder get meta =>
      _$this._meta ??=
          GithubComDevlineOnebookEldInternalDomainCompanyDtoMetaBuilder();
  set meta(
          GithubComDevlineOnebookEldInternalDomainCompanyDtoMetaBuilder?
              meta) =>
      _$this._meta = meta;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope',
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
