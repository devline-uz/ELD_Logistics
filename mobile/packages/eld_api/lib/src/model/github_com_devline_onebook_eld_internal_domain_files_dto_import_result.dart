//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_files_dto_import_row_error.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_files_dto_import_result.g.dart';

/// GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult
///
/// Properties:
/// * [errors] 
/// * [imported] 
/// * [total] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult implements Built<GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult, GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultBuilder> {
  @BuiltValueField(wireName: r'errors')
  BuiltList<GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError>? get errors;

  @BuiltValueField(wireName: r'imported')
  int? get imported;

  @BuiltValueField(wireName: r'total')
  int? get total;

  GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult._();

  factory GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult([void updates(GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult> get serializer => _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult, _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.errors != null) {
      yield r'errors';
      yield serializers.serialize(
        object.errors,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError)]),
      );
    }
    if (object.imported != null) {
      yield r'imported';
      yield serializers.serialize(
        object.imported,
        specifiedType: const FullType(int),
      );
    }
    if (object.total != null) {
      yield r'total';
      yield serializers.serialize(
        object.total,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'errors':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError>?;
          if (valueDes == null) continue;
          result.errors.replace(valueDes);
          break;
        case r'imported':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.imported = valueDes;
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.total = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultBuilder();
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


