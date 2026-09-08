//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_files_dto_import_row_error.g.dart';

/// GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError
///
/// Properties:
/// * [field] 
/// * [message] 
/// * [row] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError implements Built<GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError, GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowErrorBuilder> {
  @BuiltValueField(wireName: r'field')
  String? get field;

  @BuiltValueField(wireName: r'message')
  String? get message;

  @BuiltValueField(wireName: r'row')
  int? get row;

  GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError._();

  factory GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError([void updates(GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowErrorBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowErrorBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError> get serializer => _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowErrorSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowErrorSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError, _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.field != null) {
      yield r'field';
      yield serializers.serialize(
        object.field,
        specifiedType: const FullType(String),
      );
    }
    if (object.message != null) {
      yield r'message';
      yield serializers.serialize(
        object.message,
        specifiedType: const FullType(String),
      );
    }
    if (object.row != null) {
      yield r'row';
      yield serializers.serialize(
        object.row,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowErrorBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'field':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.field = valueDes;
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.message = valueDes;
          break;
        case r'row':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.row = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowErrorBuilder();
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


