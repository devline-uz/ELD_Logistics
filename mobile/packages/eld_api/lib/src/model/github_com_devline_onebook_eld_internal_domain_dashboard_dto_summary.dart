//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_dashboard_dto_kpi.dart';
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_dashboard_dto_window.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_dashboard_dto_route.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_dashboard_dto_status_block.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_dashboard_dto_summary.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDashboardDtoSummary
///
/// Properties:
/// * [day] 
/// * [generatedAt] - GeneratedAt lets a 60 second poller detect a stale payload.
/// * [kpi] 
/// * [routes] 
/// * [status] 
/// * [timezone] - Timezone is the company timezone the windows were cut in.
/// * [week] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDashboardDtoSummary implements Built<GithubComDevlineOnebookEldInternalDomainDashboardDtoSummary, GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryBuilder> {
  @BuiltValueField(wireName: r'day')
  GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow? get day;

  /// GeneratedAt lets a 60 second poller detect a stale payload.
  @BuiltValueField(wireName: r'generated_at')
  DateTime? get generatedAt;

  @BuiltValueField(wireName: r'kpi')
  GithubComDevlineOnebookEldInternalDomainDashboardDtoKPI? get kpi;

  @BuiltValueField(wireName: r'routes')
  BuiltList<GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute>? get routes;

  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainDashboardDtoStatusBlock? get status;

  /// Timezone is the company timezone the windows were cut in.
  @BuiltValueField(wireName: r'timezone')
  String? get timezone;

  @BuiltValueField(wireName: r'week')
  GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow? get week;

  GithubComDevlineOnebookEldInternalDomainDashboardDtoSummary._();

  factory GithubComDevlineOnebookEldInternalDomainDashboardDtoSummary([void updates(GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDashboardDtoSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDashboardDtoSummary> get serializer => _$GithubComDevlineOnebookEldInternalDomainDashboardDtoSummarySerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDashboardDtoSummarySerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDashboardDtoSummary> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDashboardDtoSummary, _$GithubComDevlineOnebookEldInternalDomainDashboardDtoSummary];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDashboardDtoSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDashboardDtoSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.day != null) {
      yield r'day';
      yield serializers.serialize(
        object.day,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow),
      );
    }
    if (object.generatedAt != null) {
      yield r'generated_at';
      yield serializers.serialize(
        object.generatedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.kpi != null) {
      yield r'kpi';
      yield serializers.serialize(
        object.kpi,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDashboardDtoKPI),
      );
    }
    if (object.routes != null) {
      yield r'routes';
      yield serializers.serialize(
        object.routes,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute)]),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDashboardDtoStatusBlock),
      );
    }
    if (object.timezone != null) {
      yield r'timezone';
      yield serializers.serialize(
        object.timezone,
        specifiedType: const FullType(String),
      );
    }
    if (object.week != null) {
      yield r'week';
      yield serializers.serialize(
        object.week,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDashboardDtoSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'day':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow),
          ) as GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow?;
          if (valueDes == null) continue;
          result.day.replace(valueDes);
          break;
        case r'generated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.generatedAt = valueDes;
          break;
        case r'kpi':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDashboardDtoKPI),
          ) as GithubComDevlineOnebookEldInternalDomainDashboardDtoKPI?;
          if (valueDes == null) continue;
          result.kpi.replace(valueDes);
          break;
        case r'routes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute>?;
          if (valueDes == null) continue;
          result.routes.replace(valueDes);
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDashboardDtoStatusBlock),
          ) as GithubComDevlineOnebookEldInternalDomainDashboardDtoStatusBlock?;
          if (valueDes == null) continue;
          result.status.replace(valueDes);
          break;
        case r'timezone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.timezone = valueDes;
          break;
        case r'week':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow),
          ) as GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow?;
          if (valueDes == null) continue;
          result.week.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDashboardDtoSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryBuilder();
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


