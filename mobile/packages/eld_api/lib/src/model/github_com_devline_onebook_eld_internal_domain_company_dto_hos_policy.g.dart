// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_company_dto_hos_policy.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy
    extends GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy {
  @override
  final DateTime? createdAt;
  @override
  final String? createdBy;
  @override
  final DateTime? effectiveFrom;
  @override
  final String? id;
  @override
  final GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDoc? policy;

  factory _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy._(
      {this.createdAt,
      this.createdBy,
      this.effectiveFrom,
      this.id,
      this.policy})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy &&
        createdAt == other.createdAt &&
        createdBy == other.createdBy &&
        effectiveFrom == other.effectiveFrom &&
        id == other.id &&
        policy == other.policy;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, createdBy.hashCode);
    _$hash = $jc(_$hash, effectiveFrom.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, policy.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy')
          ..add('createdAt', createdAt)
          ..add('createdBy', createdBy)
          ..add('effectiveFrom', effectiveFrom)
          ..add('id', id)
          ..add('policy', policy))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy,
            GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy? _$v;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _createdBy;
  String? get createdBy => _$this._createdBy;
  set createdBy(String? createdBy) => _$this._createdBy = createdBy;

  DateTime? _effectiveFrom;
  DateTime? get effectiveFrom => _$this._effectiveFrom;
  set effectiveFrom(DateTime? effectiveFrom) =>
      _$this._effectiveFrom = effectiveFrom;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBuilder?
      _policy;
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBuilder
      get policy => _$this._policy ??=
          GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBuilder();
  set policy(
          GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBuilder?
              policy) =>
      _$this._policy = policy;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyBuilder() {
    GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _createdAt = $v.createdAt;
      _createdBy = $v.createdBy;
      _effectiveFrom = $v.effectiveFrom;
      _id = $v.id;
      _policy = $v.policy?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy other) {
    _$v =
        other as _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy _build() {
    _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy._(
            createdAt: createdAt,
            createdBy: createdBy,
            effectiveFrom: effectiveFrom,
            id: id,
            policy: _policy?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'policy';
        _policy?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy',
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
