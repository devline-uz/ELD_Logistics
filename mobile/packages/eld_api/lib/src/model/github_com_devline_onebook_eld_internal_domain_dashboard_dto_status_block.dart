//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_dashboard_dto_status_block.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDashboardDtoStatusBlock
///
/// Properties:
/// * [dr] 
/// * [off] 
/// * [on_] 
/// * [sb] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDashboardDtoStatusBlock implements Built<GithubComDevlineOnebookEldInternalDomainDashboardDtoStatusBlock, GithubComDevlineOnebookEldInternalDomainDashboardDtoStatusBlockBuilder> {
  @BuiltValueField(wireName: r'dr')
  int? get dr;

  @BuiltValueField(wireName: r'off')
  int? get off;

  @BuiltValueField(wireName: r'on')
  int? get on_;

  @BuiltValueField(wireName: r'sb')
  int? get sb;

  GithubComDevlineOnebookEldInternalDomainDashboardDtoStatusBlock._();

  factory GithubComDevlineOnebookEldInternalDomainDashboardDtoStatusBlock([void updates(GithubComDevlineOnebookEldInternalDomainDashboardDtoStatusBlockBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDashboardDtoStatusBlock;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDashboardDtoStatusBlockBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDashboardDtoStatusBlock> get serializer => _$GithubComDevlineOnebookEldInternalDomainDashboardDtoStatusBlockSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDashboardDtoStatusBlockSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDashboardDtoStatusBlock> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDashboardDtoStatusBlock, _$GithubComDevlineOnebookEldInternalDomainDashboardDtoStatusBlock];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDashboardDtoStatusBlock';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDashboardDtoStatusBlock object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.dr != null) {
      yield r'dr';
      yield serializers.serialize(
        object.dr,
        specifiedType: const FullType(int),
      );
    }
    if (object.off != null) {
      yield r'off';
      yield serializers.serialize(
        object.off,
        specifiedType: const FullType(int),
      );
    }
    if (object.on_ != null) {
      yield r'on';
      yield serializers.serialize(
        object.on_,
        specifiedType: const FullType(int),
      );
    }
    if (object.sb != null) {
      yield r'sb';
      yield serializers.serialize(
        object.sb,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDashboardDtoStatusBlock object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDashboardDtoStatusBlockBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'dr':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.dr = valueDes;
          break;
        case r'off':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.off = valueDes;
          break;
        case r'on':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.on_ = valueDes;
          break;
        case r'sb':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.sb = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDashboardDtoStatusBlock deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDashboardDtoStatusBlockBuilder();
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


