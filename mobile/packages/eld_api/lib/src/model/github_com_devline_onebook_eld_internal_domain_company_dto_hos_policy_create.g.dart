// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_company_dto_hos_policy_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate
    extends GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate {
  @override
  final DateTime? effectiveFrom;
  @override
  final GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocInput
      policy;

  factory _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreateBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreateBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate._(
      {this.effectiveFrom, required this.policy})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreateBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreateBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreateBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate &&
        effectiveFrom == other.effectiveFrom &&
        policy == other.policy;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, effectiveFrom.hashCode);
    _$hash = $jc(_$hash, policy.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate')
          ..add('effectiveFrom', effectiveFrom)
          ..add('policy', policy))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreateBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate,
            GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreateBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate? _$v;

  DateTime? _effectiveFrom;
  DateTime? get effectiveFrom => _$this._effectiveFrom;
  set effectiveFrom(DateTime? effectiveFrom) =>
      _$this._effectiveFrom = effectiveFrom;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocInputBuilder?
      _policy;
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocInputBuilder
      get policy => _$this._policy ??=
          GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocInputBuilder();
  set policy(
          GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocInputBuilder?
              policy) =>
      _$this._policy = policy;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreateBuilder() {
    GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreateBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _effectiveFrom = $v.effectiveFrom;
      _policy = $v.policy.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreateBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate _build() {
    _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate._(
            effectiveFrom: effectiveFrom,
            policy: policy.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'policy';
        policy.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate',
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
