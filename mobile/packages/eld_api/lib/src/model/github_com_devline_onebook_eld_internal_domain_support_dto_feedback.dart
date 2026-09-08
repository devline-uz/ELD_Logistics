//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_support_dto_feedback.g.dart';

/// GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback
///
/// Properties:
/// * [appRating] - AppRating is 1..5 stars, null when the driver only left a comment.
/// * [driverId] 
/// * [driverName] 
/// * [id] 
/// * [submittedAt] 
/// * [text] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback implements Built<GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback, GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackBuilder> {
  /// AppRating is 1..5 stars, null when the driver only left a comment.
  @BuiltValueField(wireName: r'app_rating')
  int? get appRating;

  @BuiltValueField(wireName: r'driver_id')
  String? get driverId;

  @BuiltValueField(wireName: r'driver_name')
  String? get driverName;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'submitted_at')
  DateTime? get submittedAt;

  @BuiltValueField(wireName: r'text')
  String? get text;

  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback._();

  factory GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback([void updates(GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback> get serializer => _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback, _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.appRating != null) {
      yield r'app_rating';
      yield serializers.serialize(
        object.appRating,
        specifiedType: const FullType(int),
      );
    }
    if (object.driverId != null) {
      yield r'driver_id';
      yield serializers.serialize(
        object.driverId,
        specifiedType: const FullType(String),
      );
    }
    if (object.driverName != null) {
      yield r'driver_name';
      yield serializers.serialize(
        object.driverName,
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
    if (object.submittedAt != null) {
      yield r'submitted_at';
      yield serializers.serialize(
        object.submittedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.text != null) {
      yield r'text';
      yield serializers.serialize(
        object.text,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'app_rating':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.appRating = valueDes;
          break;
        case r'driver_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverId = valueDes;
          break;
        case r'driver_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverName = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'submitted_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.submittedAt = valueDes;
          break;
        case r'text':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.text = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackBuilder();
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


