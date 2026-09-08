//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_maintenance_dto_complete_input.g.dart';

/// GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInput
///
/// Properties:
/// * [cost] 
/// * [currency] 
/// * [invoiceKey] - InvoiceKey is the storage key of the invoice PDF/JPG (kind `invoice`).
/// * [invoiceNo] 
/// * [notes] 
/// * [performedAt] - PerformedAt defaults to now when omitted.
/// * [vendor] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInput implements Built<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInput, GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInputBuilder> {
  @BuiltValueField(wireName: r'cost')
  num? get cost;

  @BuiltValueField(wireName: r'currency')
  String? get currency;

  /// InvoiceKey is the storage key of the invoice PDF/JPG (kind `invoice`).
  @BuiltValueField(wireName: r'invoice_key')
  String? get invoiceKey;

  @BuiltValueField(wireName: r'invoice_no')
  String? get invoiceNo;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  /// PerformedAt defaults to now when omitted.
  @BuiltValueField(wireName: r'performed_at')
  DateTime? get performedAt;

  @BuiltValueField(wireName: r'vendor')
  String? get vendor;

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInput._();

  factory GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInput([void updates(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInputBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInput> get serializer => _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInputSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInputSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInput> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInput, _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInput];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.cost != null) {
      yield r'cost';
      yield serializers.serialize(
        object.cost,
        specifiedType: const FullType(num),
      );
    }
    if (object.currency != null) {
      yield r'currency';
      yield serializers.serialize(
        object.currency,
        specifiedType: const FullType(String),
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
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType(String),
      );
    }
    if (object.performedAt != null) {
      yield r'performed_at';
      yield serializers.serialize(
        object.performedAt,
        specifiedType: const FullType(DateTime),
      );
    }
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
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInputBuilder result,
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
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.currency = valueDes;
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
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.notes = valueDes;
          break;
        case r'performed_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.performedAt = valueDes;
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
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInputBuilder();
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


