//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_sync_dto_clock_verdict.g.dart';

/// GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdict
///
/// Properties:
/// * [clockSkewSec] - SkewSec is phone minus reference clock, in seconds.
/// * [malfunctionCode] - MalfunctionCode is the FMCSA Appendix A letter to raise above ten minutes of drift (\"T\", timing compliance); empty when the clock is fine.
/// * [source_] - Source is the clock the events were stamped from.
/// * [timeUnverified] - TimeUnverified marks a batch whose only clock was the phone.
/// * [warning] - Warning is raised above two minutes of drift: tell the driver.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdict implements Built<GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdict, GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictBuilder> {
  /// SkewSec is phone minus reference clock, in seconds.
  @BuiltValueField(wireName: r'clock_skew_sec')
  int? get clockSkewSec;

  /// MalfunctionCode is the FMCSA Appendix A letter to raise above ten minutes of drift (\"T\", timing compliance); empty when the clock is fine.
  @BuiltValueField(wireName: r'malfunction_code')
  GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictMalfunctionCodeEnum? get malfunctionCode;
  // enum malfunctionCodeEnum {  T,  };

  /// Source is the clock the events were stamped from.
  @BuiltValueField(wireName: r'source')
  GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictSource_Enum? get source_;
  // enum source_Enum {  eld_rtc,  server,  phone,  };

  /// TimeUnverified marks a batch whose only clock was the phone.
  @BuiltValueField(wireName: r'time_unverified')
  bool? get timeUnverified;

  /// Warning is raised above two minutes of drift: tell the driver.
  @BuiltValueField(wireName: r'warning')
  bool? get warning;

  GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdict._();

  factory GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdict([void updates(GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdict;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdict> get serializer => _$GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdict> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdict, _$GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdict];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdict';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdict object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.clockSkewSec != null) {
      yield r'clock_skew_sec';
      yield serializers.serialize(
        object.clockSkewSec,
        specifiedType: const FullType(int),
      );
    }
    if (object.malfunctionCode != null) {
      yield r'malfunction_code';
      yield serializers.serialize(
        object.malfunctionCode,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictMalfunctionCodeEnum),
      );
    }
    if (object.source_ != null) {
      yield r'source';
      yield serializers.serialize(
        object.source_,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictSource_Enum),
      );
    }
    if (object.timeUnverified != null) {
      yield r'time_unverified';
      yield serializers.serialize(
        object.timeUnverified,
        specifiedType: const FullType(bool),
      );
    }
    if (object.warning != null) {
      yield r'warning';
      yield serializers.serialize(
        object.warning,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdict object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'clock_skew_sec':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.clockSkewSec = valueDes;
          break;
        case r'malfunction_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictMalfunctionCodeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictMalfunctionCodeEnum?;
          if (valueDes == null) continue;
          result.malfunctionCode = valueDes;
          break;
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictSource_Enum),
          ) as GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictSource_Enum?;
          if (valueDes == null) continue;
          result.source_ = valueDes;
          break;
        case r'time_unverified':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.timeUnverified = valueDes;
          break;
        case r'warning':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.warning = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdict deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictBuilder();
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


/// MalfunctionCode is the FMCSA Appendix A letter to raise above ten minutes of drift (\"T\", timing compliance); empty when the clock is fine.
class GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictMalfunctionCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'T')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictMalfunctionCodeEnum T = _$githubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictMalfunctionCodeEnum_T;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictMalfunctionCodeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictMalfunctionCodeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictMalfunctionCodeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictMalfunctionCodeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictMalfunctionCodeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictMalfunctionCodeEnum> get values => _$githubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictMalfunctionCodeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictMalfunctionCodeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictMalfunctionCodeEnumValueOf(name);
}

/// Source is the clock the events were stamped from.
class GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictSource_Enum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'eld_rtc')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictSource_Enum eldRtc = _$githubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictSourceEnum_eldRtc;
  @BuiltValueEnumConst(wireName: r'server')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictSource_Enum server = _$githubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictSourceEnum_server;
  @BuiltValueEnumConst(wireName: r'phone')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictSource_Enum phone = _$githubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictSourceEnum_phone;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictSource_Enum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictSourceEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictSource_Enum> get serializer => _$githubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictSourceEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictSource_Enum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictSource_Enum> get values => _$githubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictSourceEnumValues;
  static GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictSource_Enum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictSourceEnumValueOf(name);
}

