// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_auth_dto_pin_verified.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum
    _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum_switchDriver =
    const GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum
        ._('switchDriver');
const GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum
    _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum_returnToTruck =
    const GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum
        ._('returnToTruck');
const GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum
    _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum
    _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnumValueOf(
        String name) {
  switch (name) {
    case 'switchDriver':
      return _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum_switchDriver;
    case 'returnToTruck':
      return _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum_returnToTruck;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum>
    _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum>(const <GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum>[
  _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum_switchDriver,
  _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum_returnToTruck,
  _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum_unknownDefaultOpenApi,
]);

Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum>
    _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'switchDriver': 'switch_driver',
    'returnToTruck': 'return_to_truck',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'switch_driver': 'switchDriver',
    'return_to_truck': 'returnToTruck',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified
    extends GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified {
  @override
  final GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum?
      action;
  @override
  final bool? sessionResumed;
  @override
  final bool? verified;

  factory _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified._(
      {this.action, this.sessionResumed, this.verified})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified &&
        action == other.action &&
        sessionResumed == other.sessionResumed &&
        verified == other.verified;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, sessionResumed.hashCode);
    _$hash = $jc(_$hash, verified.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified')
          ..add('action', action)
          ..add('sessionResumed', sessionResumed)
          ..add('verified', verified))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified,
            GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified? _$v;

  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum? _action;
  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum?
      get action => _$this._action;
  set action(
          GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum?
              action) =>
      _$this._action = action;

  bool? _sessionResumed;
  bool? get sessionResumed => _$this._sessionResumed;
  set sessionResumed(bool? sessionResumed) =>
      _$this._sessionResumed = sessionResumed;

  bool? _verified;
  bool? get verified => _$this._verified;
  set verified(bool? verified) => _$this._verified = verified;

  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedBuilder() {
    GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _action = $v.action;
      _sessionResumed = $v.sessionResumed;
      _verified = $v.verified;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified._(
          action: action,
          sessionResumed: sessionResumed,
          verified: verified,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
