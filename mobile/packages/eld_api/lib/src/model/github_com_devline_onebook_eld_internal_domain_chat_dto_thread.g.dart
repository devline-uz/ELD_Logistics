// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_chat_dto_thread.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum
    _$githubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum_active =
    const GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum
        ._('active');
const GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum
    _$githubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum_inactive =
    const GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum
        ._('inactive');
const GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum
    _$githubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum
    _$githubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnumValueOf(
        String name) {
  switch (name) {
    case 'active':
      return _$githubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum_active;
    case 'inactive':
      return _$githubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum_inactive;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum>(const <GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum>[
  _$githubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum_active,
  _$githubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum_inactive,
  _$githubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'inactive': 'inactive',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'inactive': 'inactive',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum
      deserialize(
              Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainChatDtoThread
    extends GithubComDevlineOnebookEldInternalDomainChatDtoThread {
  @override
  final String? driverId;
  @override
  final String? driverName;
  @override
  final GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum?
      driverStatus;
  @override
  final GithubComDevlineOnebookEldInternalDomainChatDtoMessage? lastMessage;
  @override
  final int? unreadCount;

  factory _$GithubComDevlineOnebookEldInternalDomainChatDtoThread(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainChatDtoThreadBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainChatDtoThreadBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainChatDtoThread._(
      {this.driverId,
      this.driverName,
      this.driverStatus,
      this.lastMessage,
      this.unreadCount})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoThread rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainChatDtoThreadBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoThreadBuilder toBuilder() =>
      GithubComDevlineOnebookEldInternalDomainChatDtoThreadBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainChatDtoThread &&
        driverId == other.driverId &&
        driverName == other.driverName &&
        driverStatus == other.driverStatus &&
        lastMessage == other.lastMessage &&
        unreadCount == other.unreadCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, driverName.hashCode);
    _$hash = $jc(_$hash, driverStatus.hashCode);
    _$hash = $jc(_$hash, lastMessage.hashCode);
    _$hash = $jc(_$hash, unreadCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainChatDtoThread')
          ..add('driverId', driverId)
          ..add('driverName', driverName)
          ..add('driverStatus', driverStatus)
          ..add('lastMessage', lastMessage)
          ..add('unreadCount', unreadCount))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainChatDtoThreadBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainChatDtoThread,
            GithubComDevlineOnebookEldInternalDomainChatDtoThreadBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainChatDtoThread? _$v;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  String? _driverName;
  String? get driverName => _$this._driverName;
  set driverName(String? driverName) => _$this._driverName = driverName;

  GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum?
      _driverStatus;
  GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum?
      get driverStatus => _$this._driverStatus;
  set driverStatus(
          GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum?
              driverStatus) =>
      _$this._driverStatus = driverStatus;

  GithubComDevlineOnebookEldInternalDomainChatDtoMessageBuilder? _lastMessage;
  GithubComDevlineOnebookEldInternalDomainChatDtoMessageBuilder
      get lastMessage => _$this._lastMessage ??=
          GithubComDevlineOnebookEldInternalDomainChatDtoMessageBuilder();
  set lastMessage(
          GithubComDevlineOnebookEldInternalDomainChatDtoMessageBuilder?
              lastMessage) =>
      _$this._lastMessage = lastMessage;

  int? _unreadCount;
  int? get unreadCount => _$this._unreadCount;
  set unreadCount(int? unreadCount) => _$this._unreadCount = unreadCount;

  GithubComDevlineOnebookEldInternalDomainChatDtoThreadBuilder() {
    GithubComDevlineOnebookEldInternalDomainChatDtoThread._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainChatDtoThreadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _driverId = $v.driverId;
      _driverName = $v.driverName;
      _driverStatus = $v.driverStatus;
      _lastMessage = $v.lastMessage?.toBuilder();
      _unreadCount = $v.unreadCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GithubComDevlineOnebookEldInternalDomainChatDtoThread other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainChatDtoThread;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainChatDtoThreadBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoThread build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainChatDtoThread _build() {
    _$GithubComDevlineOnebookEldInternalDomainChatDtoThread _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainChatDtoThread._(
            driverId: driverId,
            driverName: driverName,
            driverStatus: driverStatus,
            lastMessage: _lastMessage?.build(),
            unreadCount: unreadCount,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'lastMessage';
        _lastMessage?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainChatDtoThread',
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
