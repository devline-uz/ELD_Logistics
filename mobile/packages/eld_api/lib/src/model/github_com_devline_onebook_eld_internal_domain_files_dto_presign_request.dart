//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_files_dto_presign_request.g.dart';

/// GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest
///
/// Properties:
/// * [contentType] 
/// * [filename] - Filename is optional and only contributes a sanitised file extension.
/// * [kind] 
/// * [sizeBytes] - SizeBytes is the size the client is about to upload; it is checked against the per-kind ceiling before a URL is issued and is then signed into the URL as Content-Length, so the PUT must match it exactly.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest implements Built<GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest, GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestBuilder> {
  @BuiltValueField(wireName: r'content_type')
  String get contentType;

  /// Filename is optional and only contributes a sanitised file extension.
  @BuiltValueField(wireName: r'filename')
  String? get filename;

  @BuiltValueField(wireName: r'kind')
  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum get kind;
  // enum kindEnum {  dvir_photo,  invoice,  signature,  logo,  chat,  import,  };

  /// SizeBytes is the size the client is about to upload; it is checked against the per-kind ceiling before a URL is issued and is then signed into the URL as Content-Length, so the PUT must match it exactly.
  @BuiltValueField(wireName: r'size_bytes')
  int get sizeBytes;

  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest._();

  factory GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest([void updates(GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest> get serializer => _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest, _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'content_type';
    yield serializers.serialize(
      object.contentType,
      specifiedType: const FullType(String),
    );
    if (object.filename != null) {
      yield r'filename';
      yield serializers.serialize(
        object.filename,
        specifiedType: const FullType(String),
      );
    }
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum),
    );
    yield r'size_bytes';
    yield serializers.serialize(
      object.sizeBytes,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'content_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.contentType = valueDes;
          break;
        case r'filename':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.filename = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum),
          ) as GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum;
          result.kind = valueDes;
          break;
        case r'size_bytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sizeBytes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}


class GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'dvir_photo')
  static const GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum dvirPhoto = _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum_dvirPhoto;
  @BuiltValueEnumConst(wireName: r'invoice')
  static const GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum invoice = _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum_invoice;
  @BuiltValueEnumConst(wireName: r'signature')
  static const GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum signature = _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum_signature;
  @BuiltValueEnumConst(wireName: r'logo')
  static const GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum logo = _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum_logo;
  @BuiltValueEnumConst(wireName: r'chat')
  static const GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum chat = _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum_chat;
  @BuiltValueEnumConst(wireName: r'import')
  static const GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum import_ = _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum_import_;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum> get values => _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnumValues;
  static GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainFilesDtoPresignRequestKindEnumValueOf(name);
}

