//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_fleet_dto_catalog_update.g.dart';

/// GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdate
///
/// Properties:
/// * [notes] 
/// * [number] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdate implements Built<GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdate, GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdateBuilder> {
  @BuiltValueField(wireName: r'notes')
  String? get notes;

  @BuiltValueField(wireName: r'number')
  String? get number;

  GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdate._();

  factory GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdate([void updates(GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdate> get serializer => _$GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdate, _$GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType(String),
      );
    }
    if (object.number != null) {
      yield r'number';
      yield serializers.serialize(
        object.number,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.notes = valueDes;
          break;
        case r'number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.number = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdateBuilder();
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


