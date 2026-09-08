//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_dvir_dto_dvir_repair.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair
///
/// Properties:
/// * [cost] 
/// * [invoiceKey] - InvoiceKey is the optional repair invoice (kind `invoice`).
/// * [invoiceNo] - InvoiceNo, Vendor and Cost are optional bookkeeping of the repair.
/// * [mechanicNote] 
/// * [mechanicSignatureKey] 
/// * [vendor] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair implements Built<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair, GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepairBuilder> {
  @BuiltValueField(wireName: r'cost')
  num? get cost;

  /// InvoiceKey is the optional repair invoice (kind `invoice`).
  @BuiltValueField(wireName: r'invoice_key')
  String? get invoiceKey;

  /// InvoiceNo, Vendor and Cost are optional bookkeeping of the repair.
  @BuiltValueField(wireName: r'invoice_no')
  String? get invoiceNo;

  @BuiltValueField(wireName: r'mechanic_note')
  String get mechanicNote;

  @BuiltValueField(wireName: r'mechanic_signature_key')
  String get mechanicSignatureKey;

  @BuiltValueField(wireName: r'vendor')
  String? get vendor;

  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair._();

  factory GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair([void updates(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepairBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepairBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair> get serializer => _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepairSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepairSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair, _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.cost != null) {
      yield r'cost';
      yield serializers.serialize(
        object.cost,
        specifiedType: const FullType(num),
      );
    }
    if (object.invoiceKey != null) {
      yield r'invoice_key';
      yield serializers.serialize(
        object.invoiceKey,
        specifiedType: const FullType(String),
      );
    }
    if (object.invoiceNo != null) {
      yield r'invoice_no';
      yield serializers.serialize(
        object.invoiceNo,
        specifiedType: const FullType(String),
      );
    }
    yield r'mechanic_note';
    yield serializers.serialize(
      object.mechanicNote,
      specifiedType: const FullType(String),
    );
    yield r'mechanic_signature_key';
    yield serializers.serialize(
      object.mechanicSignatureKey,
      specifiedType: const FullType(String),
    );
    if (object.vendor != null) {
      yield r'vendor';
      yield serializers.serialize(
        object.vendor,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepairBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'cost':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.cost = valueDes;
          break;
        case r'invoice_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.invoiceKey = valueDes;
          break;
        case r'invoice_no':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.invoiceNo = valueDes;
          break;
        case r'mechanic_note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mechanicNote = valueDes;
          break;
        case r'mechanic_signature_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mechanicSignatureKey = valueDes;
          break;
        case r'vendor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.vendor = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepairBuilder();
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


