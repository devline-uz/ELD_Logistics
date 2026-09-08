// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_companies_dto_subscription_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum
    _$githubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum_trial =
    const GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum
        ._('trial');
const GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum
    _$githubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum_active =
    const GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum
        ._('active');
const GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum
    _$githubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum_grace =
    const GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum
        ._('grace');
const GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum
    _$githubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum_readonly =
    const GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum
        ._('readonly');
const GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum
    _$githubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum
    _$githubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnumValueOf(
        String name) {
  switch (name) {
    case 'trial':
      return _$githubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum_trial;
    case 'active':
      return _$githubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum_active;
    case 'grace':
      return _$githubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum_grace;
    case 'readonly':
      return _$githubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum_readonly;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum>(const <GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum>[
  _$githubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum_trial,
  _$githubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum_active,
  _$githubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum_grace,
  _$githubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum_readonly,
  _$githubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'trial': 'trial',
    'active': 'active',
    'grace': 'grace',
    'readonly': 'readonly',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'trial': 'trial',
    'active': 'active',
    'grace': 'grace',
    'readonly': 'readonly',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdate
    extends GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdate {
  @override
  final bool? clearEndAt;
  @override
  final String? plan;
  @override
  final DateTime? subscriptionEndAt;
  @override
  final GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum?
      subscriptionStatus;

  factory _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdate(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdate._(
      {this.clearEndAt,
      this.plan,
      this.subscriptionEndAt,
      this.subscriptionStatus})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdate rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdate &&
        clearEndAt == other.clearEndAt &&
        plan == other.plan &&
        subscriptionEndAt == other.subscriptionEndAt &&
        subscriptionStatus == other.subscriptionStatus;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clearEndAt.hashCode);
    _$hash = $jc(_$hash, plan.hashCode);
    _$hash = $jc(_$hash, subscriptionEndAt.hashCode);
    _$hash = $jc(_$hash, subscriptionStatus.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdate')
          ..add('clearEndAt', clearEndAt)
          ..add('plan', plan)
          ..add('subscriptionEndAt', subscriptionEndAt)
          ..add('subscriptionStatus', subscriptionStatus))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdate,
            GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdate? _$v;

  bool? _clearEndAt;
  bool? get clearEndAt => _$this._clearEndAt;
  set clearEndAt(bool? clearEndAt) => _$this._clearEndAt = clearEndAt;

  String? _plan;
  String? get plan => _$this._plan;
  set plan(String? plan) => _$this._plan = plan;

  DateTime? _subscriptionEndAt;
  DateTime? get subscriptionEndAt => _$this._subscriptionEndAt;
  set subscriptionEndAt(DateTime? subscriptionEndAt) =>
      _$this._subscriptionEndAt = subscriptionEndAt;

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum?
      _subscriptionStatus;
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum?
      get subscriptionStatus => _$this._subscriptionStatus;
  set subscriptionStatus(
          GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum?
              subscriptionStatus) =>
      _$this._subscriptionStatus = subscriptionStatus;

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateBuilder() {
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdate
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _clearEndAt = $v.clearEndAt;
      _plan = $v.plan;
      _subscriptionEndAt = $v.subscriptionEndAt;
      _subscriptionStatus = $v.subscriptionStatus;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdate
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdate;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdate
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdate
      _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdate
            ._(
          clearEndAt: clearEndAt,
          plan: plan,
          subscriptionEndAt: subscriptionEndAt,
          subscriptionStatus: subscriptionStatus,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
