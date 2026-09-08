//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_logs_dto_inspection_transfer.g.dart';

/// GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransfer
///
/// Properties:
/// * [comment] 
/// * [date] 
/// * [driverId] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransfer implements Built<GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransfer, GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferBuilder> {
  @BuiltValueField(wireName: r'comment')
  String? get comment;

  @BuiltValueField(wireName: r'date')
  Date? get date;

  @BuiltValueField(wireName: r'driver_id')
  String? get driverId;

  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransfer._();

  factory GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransfer([void updates(GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransfer;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransfer> get serializer => _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransfer> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransfer, _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransfer];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransfer';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransfer object, {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransfer object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransfer deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferBuilder();
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


