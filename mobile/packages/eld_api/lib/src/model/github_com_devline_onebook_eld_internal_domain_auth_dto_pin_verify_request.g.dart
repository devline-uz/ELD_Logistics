// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_auth_dto_pin_verify_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum
    _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum_switchDriver =
    const GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum
        ._('switchDriver');
const GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum
    _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum_returnToTruck =
    const GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum
        ._('returnToTruck');
const GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum
    _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum
    _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnumValueOf(
        String name) {
  switch (name) {
    case 'switchDriver':
      return _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum_switchDriver;
    case 'returnToTruck':
      return _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum_returnToTruck;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum>
    _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum>(const <GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum>[
  _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum_switchDriver,
  _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum_returnToTruck,
  _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum>
    _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum> {
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
    GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest
    extends GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest {
  @override
  final GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum?
      action;
  @override
  final String pin;

  factory _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest._(
      {this.action, required this.pin})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest &&
        action == other.action &&
        pin == other.pin;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, pin.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest')
          ..add('action', action)
          ..add('pin', pin))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest,
            GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest? _$v;

  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum?
      _action;
  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum?
      get action => _$this._action;
  set action(
          GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum?
              action) =>
      _$this._action = action;

  String? _pin;
  String? get pin => _$this._pin;
  set pin(String? pin) => _$this._pin = pin;

  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestBuilder() {
    GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _action = $v.action;
      _pin = $v.pin;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest._(
          action: action,
          pin: BuiltValueNullFieldError.checkNotNull(
              pin,
              r'GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest',
              'pin'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
