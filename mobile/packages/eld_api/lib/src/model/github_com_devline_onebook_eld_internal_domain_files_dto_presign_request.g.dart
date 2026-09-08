// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_files_dto_presign_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum
    _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum_dvirPhoto =
    const GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum
        ._('dvirPhoto');
const GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum
    _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum_invoice =
    const GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum
        ._('invoice');
const GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum
    _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum_signature =
    const GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum
        ._('signature');
const GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum
    _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum_logo =
    const GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum
        ._('logo');
const GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum
    _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum_chat =
    const GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum
        ._('chat');
const GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum
    _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum_import_ =
    const GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum
        ._('import_');
const GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum
    _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum
    _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnumValueOf(
        String name) {
  switch (name) {
    case 'dvirPhoto':
      return _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum_dvirPhoto;
    case 'invoice':
      return _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum_invoice;
    case 'signature':
      return _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum_signature;
    case 'logo':
      return _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum_logo;
    case 'chat':
      return _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum_chat;
    case 'import_':
      return _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum_import_;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum>
    _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum>(const <GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum>[
  _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum_dvirPhoto,
  _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum_invoice,
  _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum_signature,
  _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum_logo,
  _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum_chat,
  _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum_import_,
  _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum>
    _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'dvirPhoto': 'dvir_photo',
    'invoice': 'invoice',
    'signature': 'signature',
    'logo': 'logo',
    'chat': 'chat',
    'import_': 'import',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'dvir_photo': 'dvirPhoto',
    'invoice': 'invoice',
    'signature': 'signature',
    'logo': 'logo',
    'chat': 'chat',
    'import': 'import_',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest
    extends GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest {
  @override
  final String contentType;
  @override
  final String? filename;
  @override
  final GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum
      kind;
  @override
  final int sizeBytes;

  factory _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest._(
      {required this.contentType,
      this.filename,
      required this.kind,
      required this.sizeBytes})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest &&
        contentType == other.contentType &&
        filename == other.filename &&
        kind == other.kind &&
        sizeBytes == other.sizeBytes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, contentType.hashCode);
    _$hash = $jc(_$hash, filename.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, sizeBytes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest')
          ..add('contentType', contentType)
          ..add('filename', filename)
          ..add('kind', kind)
          ..add('sizeBytes', sizeBytes))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest,
            GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest? _$v;

  String? _contentType;
  String? get contentType => _$this._contentType;
  set contentType(String? contentType) => _$this._contentType = contentType;

  String? _filename;
  String? get filename => _$this._filename;
  set filename(String? filename) => _$this._filename = filename;

  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum? _kind;
  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum?
      get kind => _$this._kind;
  set kind(
          GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum?
              kind) =>
      _$this._kind = kind;

  int? _sizeBytes;
  int? get sizeBytes => _$this._sizeBytes;
  set sizeBytes(int? sizeBytes) => _$this._sizeBytes = sizeBytes;

  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestBuilder() {
    GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _contentType = $v.contentType;
      _filename = $v.filename;
      _kind = $v.kind;
      _sizeBytes = $v.sizeBytes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest._(
          contentType: BuiltValueNullFieldError.checkNotNull(
              contentType,
              r'GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest',
              'contentType'),
          filename: filename,
          kind: BuiltValueNullFieldError.checkNotNull(
              kind,
              r'GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest',
              'kind'),
          sizeBytes: BuiltValueNullFieldError.checkNotNull(
              sizeBytes,
              r'GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest',
              'sizeBytes'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
