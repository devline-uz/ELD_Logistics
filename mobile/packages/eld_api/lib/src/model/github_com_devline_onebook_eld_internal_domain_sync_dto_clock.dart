//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_sync_dto_clock.g.dart';

/// GithubComDevlineOnebookEldInternalDomainSyncDtoClock
///
/// Properties:
/// * [eldRtc] 
/// * [phone] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainSyncDtoClock implements Built<GithubComDevlineOnebookEldInternalDomainSyncDtoClock, GithubComDevlineOnebookEldInternalDomainSyncDtoClockBuilder> {
  @BuiltValueField(wireName: r'eld_rtc')
  DateTime? get eldRtc;

  @BuiltValueField(wireName: r'phone')
  DateTime? get phone;

  GithubComDevlineOnebookEldInternalDomainSyncDtoClock._();

  factory GithubComDevlineOnebookEldInternalDomainSyncDtoClock([void updates(GithubComDevlineOnebookEldInternalDomainSyncDtoClockBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainSyncDtoClock;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainSyncDtoClockBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoClock> get serializer => _$GithubComDevlineOnebookEldInternalDomainSyncDtoClockSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoClockSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainSyncDtoClock> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainSyncDtoClock, _$GithubComDevlineOnebookEldInternalDomainSyncDtoClock];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainSyncDtoClock';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoClock object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.eldRtc != null) {
      yield r'eld_rtc';
      yield serializers.serialize(
        object.eldRtc,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.phone != null) {
      yield r'phone';
      yield serializers.serialize(
        object.phone,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoClock object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainSyncDtoClockBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'eld_rtc':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.eldRtc = valueDes;
          break;
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.phone = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoClock deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainSyncDtoClockBuilder();
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


