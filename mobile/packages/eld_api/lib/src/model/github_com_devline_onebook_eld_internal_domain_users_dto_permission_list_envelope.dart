//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_users_dto_permission_module.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_users_dto_permission_list_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope, GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule>? get data;

  GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope, _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule>?;
          if (valueDes == null) continue;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionListEnvelopeBuilder();
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


