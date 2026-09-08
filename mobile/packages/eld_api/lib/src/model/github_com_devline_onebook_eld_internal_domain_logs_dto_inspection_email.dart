//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_logs_dto_inspection_email.g.dart';

/// GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail
///
/// Properties:
/// * [comment] 
/// * [date] - Date anchors the 7 days + today window; defaults to today.
/// * [driverId] - DriverID is required for an admin caller; a driver always sends its own.
/// * [email] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail implements Built<GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail, GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmailBuilder> {
  @BuiltValueField(wireName: r'comment')
  String? get comment;

  /// Date anchors the 7 days + today window; defaults to today.
  @BuiltValueField(wireName: r'date')
  Date? get date;

  /// DriverID is required for an admin caller; a driver always sends its own.
  @BuiltValueField(wireName: r'driver_id')
  String? get driverId;

  @BuiltValueField(wireName: r'email')
  String get email;

  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail._();

  factory GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail([void updates(GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmailBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmailBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail> get serializer => _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmailSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmailSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail, _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.comment != null) {
      yield r'comment';
      yield serializers.serialize(
        object.comment,
        specifiedType: const FullType(String),
      );
    }
    if (object.date != null) {
      yield r'date';
      yield serializers.serialize(
        object.date,
        specifiedType: const FullType(Date),
      );
    }
    if (object.driverId != null) {
      yield r'driver_id';
      yield serializers.serialize(
        object.driverId,
        specifiedType: const FullType(String),
      );
    }
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmailBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'comment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.comment = valueDes;
          break;
        case r'date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.date = valueDes;
          break;
        case r'driver_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverId = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmailBuilder();
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


