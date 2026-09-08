// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_chat_dto_message_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum
    _$githubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum_text =
    const GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum
        ._('text');
const GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum
    _$githubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum_image =
    const GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum
        ._('image');
const GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum
    _$githubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum_file =
    const GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum
        ._('file');
const GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum
    _$githubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum_location =
    const GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum
        ._('location');
const GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum
    _$githubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum
    _$githubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnumValueOf(
        String name) {
  switch (name) {
    case 'text':
      return _$githubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum_text;
    case 'image':
      return _$githubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum_image;
    case 'file':
      return _$githubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum_file;
    case 'location':
      return _$githubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum_location;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum>
    _$githubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum>(const <GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum>[
  _$githubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum_text,
  _$githubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum_image,
  _$githubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum_file,
  _$githubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum_location,
  _$githubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum_unknownDefaultOpenApi,
]);

Serializer<GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum>
    _$githubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum> {
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
    GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate
    extends GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate {
  @override
  final String? fileKey;
  @override
  final GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum
      kind;
  @override
  final num? lat;
  @override
  final num? lng;
  @override
  final String? text;

  factory _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate._(
      {this.fileKey, required this.kind, this.lat, this.lng, this.text})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate &&
        fileKey == other.fileKey &&
        kind == other.kind &&
        lat == other.lat &&
        lng == other.lng &&
        text == other.text;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, fileKey.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, lat.hashCode);
    _$hash = $jc(_$hash, lng.hashCode);
    _$hash = $jc(_$hash, text.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate')
          ..add('fileKey', fileKey)
          ..add('kind', kind)
          ..add('lat', lat)
          ..add('lng', lng)
          ..add('text', text))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate,
            GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate? _$v;

  String? _fileKey;
  String? get fileKey => _$this._fileKey;
  set fileKey(String? fileKey) => _$this._fileKey = fileKey;

  GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum? _kind;
  GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum?
      get kind => _$this._kind;
  set kind(
          GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum?
              kind) =>
      _$this._kind = kind;

  num? _lat;
  num? get lat => _$this._lat;
  set lat(num? lat) => _$this._lat = lat;

  num? _lng;
  num? get lng => _$this._lng;
  set lng(num? lng) => _$this._lng = lng;

  String? _text;
  String? get text => _$this._text;
  set text(String? text) => _$this._text = text;

  GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateBuilder() {
    GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _fileKey = $v.fileKey;
      _kind = $v.kind;
      _lat = $v.lat;
      _lng = $v.lng;
      _text = $v.text;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate other) {
    _$v =
        other as _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate._(
          fileKey: fileKey,
          kind: BuiltValueNullFieldError.checkNotNull(
              kind,
              r'GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate',
              'kind'),
          lat: lat,
          lng: lng,
          text: text,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
