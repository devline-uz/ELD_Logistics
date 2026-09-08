//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_logs_dto_number_ref.dart';
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_logs_dto_unit_ref.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_logs_dto_log_form.g.dart';

/// GithubComDevlineOnebookEldInternalDomainLogsDtoLogForm
///
/// Properties:
/// * [carrierName] 
/// * [coDriverName] 
/// * [distanceM] 
/// * [driverName] 
/// * [homeTerminalAddress] - HomeTerminalAddress is the carrier's home terminal (Q16).
/// * [shippingDocs] 
/// * [signatureKey] - SignatureKey is the object storage key of the stored signature image.
/// * [signedAt] 
/// * [signedDeviceId] 
/// * [signedIp] 
/// * [trailers] 
/// * [units] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainLogsDtoLogForm implements Built<GithubComDevlineOnebookEldInternalDomainLogsDtoLogForm, GithubComDevlineOnebookEldInternalDomainLogsDtoLogFormBuilder> {
  @BuiltValueField(wireName: r'carrier_name')
  String? get carrierName;

  @BuiltValueField(wireName: r'co_driver_name')
  String? get coDriverName;

  @BuiltValueField(wireName: r'distance_m')
  int? get distanceM;

  @BuiltValueField(wireName: r'driver_name')
  String? get driverName;

  /// HomeTerminalAddress is the carrier's home terminal (Q16).
  @BuiltValueField(wireName: r'home_terminal_address')
  String? get homeTerminalAddress;

  @BuiltValueField(wireName: r'shipping_docs')
  BuiltList<GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef>? get shippingDocs;

  /// SignatureKey is the object storage key of the stored signature image.
  @BuiltValueField(wireName: r'signature_key')
  String? get signatureKey;

  @BuiltValueField(wireName: r'signed_at')
  DateTime? get signedAt;

  @BuiltValueField(wireName: r'signed_device_id')
  String? get signedDeviceId;

  @BuiltValueField(wireName: r'signed_ip')
  String? get signedIp;

  @BuiltValueField(wireName: r'trailers')
  BuiltList<GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef>? get trailers;

  @BuiltValueField(wireName: r'units')
  BuiltList<GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef>? get units;

  GithubComDevlineOnebookEldInternalDomainLogsDtoLogForm._();

  factory GithubComDevlineOnebookEldInternalDomainLogsDtoLogForm([void updates(GithubComDevlineOnebookEldInternalDomainLogsDtoLogFormBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogForm;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainLogsDtoLogFormBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoLogForm> get serializer => _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogFormSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogFormSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainLogsDtoLogForm> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainLogsDtoLogForm, _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogForm];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainLogsDtoLogForm';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoLogForm object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.carrierName != null) {
      yield r'carrier_name';
      yield serializers.serialize(
        object.carrierName,
        specifiedType: const FullType(String),
      );
    }
    if (object.coDriverName != null) {
      yield r'co_driver_name';
      yield serializers.serialize(
        object.coDriverName,
        specifiedType: const FullType(String),
      );
    }
    if (object.distanceM != null) {
      yield r'distance_m';
      yield serializers.serialize(
        object.distanceM,
        specifiedType: const FullType(int),
      );
    }
    if (object.driverName != null) {
      yield r'driver_name';
      yield serializers.serialize(
        object.driverName,
        specifiedType: const FullType(String),
      );
    }
    if (object.homeTerminalAddress != null) {
      yield r'home_terminal_address';
      yield serializers.serialize(
        object.homeTerminalAddress,
        specifiedType: const FullType(String),
      );
    }
    if (object.shippingDocs != null) {
      yield r'shipping_docs';
      yield serializers.serialize(
        object.shippingDocs,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef)]),
      );
    }
    if (object.signatureKey != null) {
      yield r'signature_key';
      yield serializers.serialize(
        object.signatureKey,
        specifiedType: const FullType(String),
      );
    }
    if (object.signedAt != null) {
      yield r'signed_at';
      yield serializers.serialize(
        object.signedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.signedDeviceId != null) {
      yield r'signed_device_id';
      yield serializers.serialize(
        object.signedDeviceId,
        specifiedType: const FullType(String),
      );
    }
    if (object.signedIp != null) {
      yield r'signed_ip';
      yield serializers.serialize(
        object.signedIp,
        specifiedType: const FullType(String),
      );
    }
    if (object.trailers != null) {
      yield r'trailers';
      yield serializers.serialize(
        object.trailers,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef)]),
      );
    }
    if (object.units != null) {
      yield r'units';
      yield serializers.serialize(
        object.units,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoLogForm object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainLogsDtoLogFormBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'carrier_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.carrierName = valueDes;
          break;
        case r'co_driver_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.coDriverName = valueDes;
          break;
        case r'distance_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.distanceM = valueDes;
          break;
        case r'driver_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverName = valueDes;
          break;
        case r'home_terminal_address':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.homeTerminalAddress = valueDes;
          break;
        case r'shipping_docs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef>?;
          if (valueDes == null) continue;
          result.shippingDocs.replace(valueDes);
          break;
        case r'signature_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.signatureKey = valueDes;
          break;
        case r'signed_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.signedAt = valueDes;
          break;
        case r'signed_device_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.signedDeviceId = valueDes;
          break;
        case r'signed_ip':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.signedIp = valueDes;
          break;
        case r'trailers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef>?;
          if (valueDes == null) continue;
          result.trailers.replace(valueDes);
          break;
        case r'units':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef>?;
          if (valueDes == null) continue;
          result.units.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogForm deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainLogsDtoLogFormBuilder();
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


