//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_drivers_dto_driver_license.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense
///
/// Properties:
/// * [driverId] 
/// * [licenseNo] 
/// * [licenseRegion] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense implements Built<GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense, GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseBuilder> {
  @BuiltValueField(wireName: r'driver_id')
  String? get driverId;

  @BuiltValueField(wireName: r'license_no')
  String? get licenseNo;

  @BuiltValueField(wireName: r'license_region')
  String? get licenseRegion;

  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense._();

  factory GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense([void updates(GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense> get serializer => _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense, _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.driverId != null) {
      yield r'driver_id';
      yield serializers.serialize(
        object.driverId,
        specifiedType: const FullType(String),
      );
    }
    if (object.licenseNo != null) {
      yield r'license_no';
      yield serializers.serialize(
        object.licenseNo,
        specifiedType: const FullType(String),
      );
    }
    if (object.licenseRegion != null) {
      yield r'license_region';
      yield serializers.serialize(
        object.licenseRegion,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'driver_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverId = valueDes;
          break;
        case r'license_no':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.licenseNo = valueDes;
          break;
        case r'license_region':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.licenseRegion = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseBuilder();
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


