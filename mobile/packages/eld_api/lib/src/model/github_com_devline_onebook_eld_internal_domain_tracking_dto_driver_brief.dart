//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_tracking_dto_driver_brief.g.dart';

/// GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief
///
/// Properties:
/// * [firstName] 
/// * [id] 
/// * [lastName] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief implements Built<GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief, GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBriefBuilder> {
  @BuiltValueField(wireName: r'first_name')
  String? get firstName;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'last_name')
  String? get lastName;

  GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief._();

  factory GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief([void updates(GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBriefBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBriefBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief> get serializer => _$GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBriefSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBriefSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief, _$GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.firstName != null) {
      yield r'first_name';
      yield serializers.serialize(
        object.firstName,
        specifiedType: const FullType(String),
      );
    }
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.lastName != null) {
      yield r'last_name';
      yield serializers.serialize(
        object.lastName,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBriefBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'first_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.firstName = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'last_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.lastName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBriefBuilder();
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


