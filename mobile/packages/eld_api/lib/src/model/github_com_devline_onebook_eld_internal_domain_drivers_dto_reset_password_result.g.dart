// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_drivers_dto_reset_password_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum
    _$githubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum_email =
    const GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum
        ._('email');
const GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum
    _$githubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum_sms =
    const GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum
        ._('sms');
const GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum
    _$githubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum
    _$githubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnumValueOf(
        String name) {
  switch (name) {
    case 'email':
      return _$githubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum_email;
    case 'sms':
      return _$githubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum_sms;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum>
    _$githubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum>(const <GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum>[
  _$githubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum_email,
  _$githubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum_sms,
  _$githubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum>
    _$githubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'email': 'email',
    'sms': 'sms',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'email': 'email',
    'sms': 'sms',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult
    extends GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult {
  @override
  final GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum?
      channel;
  @override
  final String? driverId;
  @override
  final DateTime? expiresAt;

  factory _$GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult._(
      {this.channel, this.driverId, this.expiresAt})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult &&
        channel == other.channel &&
        driverId == other.driverId &&
        expiresAt == other.expiresAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, channel.hashCode);
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult')
          ..add('channel', channel)
          ..add('driverId', driverId)
          ..add('expiresAt', expiresAt))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult,
            GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult? _$v;

  GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum?
      _channel;
  GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum?
      get channel => _$this._channel;
  set channel(
          GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum?
              channel) =>
      _$this._channel = channel;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultBuilder() {
    GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _channel = $v.channel;
      _driverId = $v.driverId;
      _expiresAt = $v.expiresAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult
      _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult
            ._(
          channel: channel,
          driverId: driverId,
          expiresAt: expiresAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
