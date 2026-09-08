// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_sync_dto_chat_message.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum
    _$githubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum_text =
    const GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum._(
        'text');
const GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum
    _$githubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum_image =
    const GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum._(
        'image');
const GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum
    _$githubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum_file =
    const GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum._(
        'file');
const GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum
    _$githubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum_location =
    const GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum._(
        'location');
const GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum
    _$githubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum._(
        'unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum
    _$githubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnumValueOf(
        String name) {
  switch (name) {
    case 'text':
      return _$githubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum_text;
    case 'image':
      return _$githubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum_image;
    case 'file':
      return _$githubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum_file;
    case 'location':
      return _$githubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum_location;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum>
    _$githubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum>(const <GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum>[
  _$githubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum_text,
  _$githubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum_image,
  _$githubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum_file,
  _$githubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum_location,
  _$githubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum_unknownDefaultOpenApi,
]);

Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum>
    _$githubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'text': 'text',
    'image': 'image',
    'file': 'file',
    'location': 'location',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'text': 'text',
    'image': 'image',
    'file': 'file',
    'location': 'location',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage
    extends GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage {
  @override
  final DateTime? deliveredAt;
  @override
  final String? fileKey;
  @override
  final String? id;
  @override
  final GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum?
      kind;
  @override
  final num? lat;
  @override
  final num? lng;
  @override
  final DateTime? readAt;
  @override
  final String? senderId;
  @override
  final DateTime? sentAt;
  @override
  final String? text;
  @override
  final DateTime? updatedAt;

  factory _$GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage._(
      {this.deliveredAt,
      this.fileKey,
      this.id,
      this.kind,
      this.lat,
      this.lng,
      this.readAt,
      this.senderId,
      this.sentAt,
      this.text,
      this.updatedAt})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage &&
        deliveredAt == other.deliveredAt &&
        fileKey == other.fileKey &&
        id == other.id &&
        kind == other.kind &&
        lat == other.lat &&
        lng == other.lng &&
        readAt == other.readAt &&
        senderId == other.senderId &&
        sentAt == other.sentAt &&
        text == other.text &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, deliveredAt.hashCode);
    _$hash = $jc(_$hash, fileKey.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, lat.hashCode);
    _$hash = $jc(_$hash, lng.hashCode);
    _$hash = $jc(_$hash, readAt.hashCode);
    _$hash = $jc(_$hash, senderId.hashCode);
    _$hash = $jc(_$hash, sentAt.hashCode);
    _$hash = $jc(_$hash, text.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage')
          ..add('deliveredAt', deliveredAt)
          ..add('fileKey', fileKey)
          ..add('id', id)
          ..add('kind', kind)
          ..add('lat', lat)
          ..add('lng', lng)
          ..add('readAt', readAt)
          ..add('senderId', senderId)
          ..add('sentAt', sentAt)
          ..add('text', text)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage,
            GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage? _$v;

  DateTime? _deliveredAt;
  DateTime? get deliveredAt => _$this._deliveredAt;
  set deliveredAt(DateTime? deliveredAt) => _$this._deliveredAt = deliveredAt;

  String? _fileKey;
  String? get fileKey => _$this._fileKey;
  set fileKey(String? fileKey) => _$this._fileKey = fileKey;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum? _kind;
  GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum?
      get kind => _$this._kind;
  set kind(
          GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum?
              kind) =>
      _$this._kind = kind;

  num? _lat;
  num? get lat => _$this._lat;
  set lat(num? lat) => _$this._lat = lat;

  num? _lng;
  num? get lng => _$this._lng;
  set lng(num? lng) => _$this._lng = lng;

  DateTime? _readAt;
  DateTime? get readAt => _$this._readAt;
  set readAt(DateTime? readAt) => _$this._readAt = readAt;

  String? _senderId;
  String? get senderId => _$this._senderId;
  set senderId(String? senderId) => _$this._senderId = senderId;

  DateTime? _sentAt;
  DateTime? get sentAt => _$this._sentAt;
  set sentAt(DateTime? sentAt) => _$this._sentAt = sentAt;

  String? _text;
  String? get text => _$this._text;
  set text(String? text) => _$this._text = text;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageBuilder() {
    GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _deliveredAt = $v.deliveredAt;
      _fileKey = $v.fileKey;
      _id = $v.id;
      _kind = $v.kind;
      _lat = $v.lat;
      _lng = $v.lng;
      _readAt = $v.readAt;
      _senderId = $v.senderId;
      _sentAt = $v.sentAt;
      _text = $v.text;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage._(
          deliveredAt: deliveredAt,
          fileKey: fileKey,
          id: id,
          kind: kind,
          lat: lat,
          lng: lng,
          readAt: readAt,
          senderId: senderId,
          sentAt: sentAt,
          text: text,
          updatedAt: updatedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
