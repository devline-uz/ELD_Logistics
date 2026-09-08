//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_logs_dto_log_edit_change.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_logs_dto_log_edit_request_create.g.dart';

/// GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate
///
/// Properties:
/// * [changes] 
/// * [dailyLogId] 
/// * [driverId] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate implements Built<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate, GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreateBuilder> {
  @BuiltValueField(wireName: r'changes')
  BuiltList<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChange> get changes;

  @BuiltValueField(wireName: r'daily_log_id')
  String get dailyLogId;

  @BuiltValueField(wireName: r'driver_id')
  String get driverId;

  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate._();

  factory GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate([void updates(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate> get serializer => _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate, _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'changes';
    yield serializers.serialize(
      object.changes,
      specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChange)]),
    );
    yield r'daily_log_id';
    yield serializers.serialize(
      object.dailyLogId,
      specifiedType: const FullType(String),
    );
    yield r'driver_id';
    yield serializers.serialize(
      object.driverId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'changes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChange)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChange>;
          result.changes.replace(valueDes);
          break;
        case r'daily_log_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.dailyLogId = valueDes;
          break;
        case r'driver_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreateBuilder();
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


