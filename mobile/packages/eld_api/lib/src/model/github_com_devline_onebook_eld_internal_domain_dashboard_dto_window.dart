//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_dashboard_dto_window.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow
///
/// Properties:
/// * [from] 
/// * [to] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow implements Built<GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow, GithubComDevlineOnebookEldInternalDomainDashboardDtoWindowBuilder> {
  @BuiltValueField(wireName: r'from')
  DateTime? get from;

  @BuiltValueField(wireName: r'to')
  DateTime? get to;

  GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow._();

  factory GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow([void updates(GithubComDevlineOnebookEldInternalDomainDashboardDtoWindowBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDashboardDtoWindowBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow> get serializer => _$GithubComDevlineOnebookEldInternalDomainDashboardDtoWindowSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDashboardDtoWindowSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow, _$GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.from != null) {
      yield r'from';
      yield serializers.serialize(
        object.from,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.to != null) {
      yield r'to';
      yield serializers.serialize(
        object.to,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDashboardDtoWindowBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'from':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.from = valueDes;
          break;
        case r'to':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.to = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDashboardDtoWindowBuilder();
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


