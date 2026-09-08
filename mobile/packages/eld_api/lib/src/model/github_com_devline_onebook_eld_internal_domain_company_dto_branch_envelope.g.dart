// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_company_dto_branch_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchEnvelope
    extends GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainCompanyDtoBranch? data;

  factory _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchEnvelope,
            GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchEnvelope other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchEnvelope _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchEnvelope._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchEnvelope',
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
