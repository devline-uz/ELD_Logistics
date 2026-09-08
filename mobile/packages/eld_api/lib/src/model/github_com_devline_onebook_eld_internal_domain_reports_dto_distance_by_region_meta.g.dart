// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_reports_dto_distance_by_region_meta.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum
    _$githubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum_regionsAndUnits =
    const GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum
        ._('regionsAndUnits');
const GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum
    _$githubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum_regionsOnly =
    const GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum
        ._('regionsOnly');
const GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum
    _$githubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum
    _$githubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnumValueOf(
        String name) {
  switch (name) {
    case 'regionsAndUnits':
      return _$githubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum_regionsAndUnits;
    case 'regionsOnly':
      return _$githubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum_regionsOnly;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum>
    _$githubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum>(const <GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum>[
  _$githubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum_regionsAndUnits,
  _$githubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum_regionsOnly,
  _$githubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum>
    _$githubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'regionsAndUnits': 'regions_and_units',
    'regionsOnly': 'regions_only',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'regions_and_units': 'regionsAndUnits',
    'regions_only': 'regionsOnly',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta
    extends GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta {
  @override
  final Date? from;
  @override
  final GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum?
      mode;
  @override
  final int? quarter;
  @override
  final Date? to;
  @override
  final int? totalDistanceM;
  @override
  final int? year;

  factory _$GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta._(
      {this.from,
      this.mode,
      this.quarter,
      this.to,
      this.totalDistanceM,
      this.year})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta &&
        from == other.from &&
        mode == other.mode &&
        quarter == other.quarter &&
        to == other.to &&
        totalDistanceM == other.totalDistanceM &&
        year == other.year;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, from.hashCode);
    _$hash = $jc(_$hash, mode.hashCode);
    _$hash = $jc(_$hash, quarter.hashCode);
    _$hash = $jc(_$hash, to.hashCode);
    _$hash = $jc(_$hash, totalDistanceM.hashCode);
    _$hash = $jc(_$hash, year.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta')
          ..add('from', from)
          ..add('mode', mode)
          ..add('quarter', quarter)
          ..add('to', to)
          ..add('totalDistanceM', totalDistanceM)
          ..add('year', year))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta,
            GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta? _$v;

  Date? _from;
  Date? get from => _$this._from;
  set from(Date? from) => _$this._from = from;

  GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum?
      _mode;
  GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum?
      get mode => _$this._mode;
  set mode(
          GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum?
              mode) =>
      _$this._mode = mode;

  int? _quarter;
  int? get quarter => _$this._quarter;
  set quarter(int? quarter) => _$this._quarter = quarter;

  Date? _to;
  Date? get to => _$this._to;
  set to(Date? to) => _$this._to = to;

  int? _totalDistanceM;
  int? get totalDistanceM => _$this._totalDistanceM;
  set totalDistanceM(int? totalDistanceM) =>
      _$this._totalDistanceM = totalDistanceM;

  int? _year;
  int? get year => _$this._year;
  set year(int? year) => _$this._year = year;

  GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaBuilder() {
    GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _from = $v.from;
      _mode = $v.mode;
      _quarter = $v.quarter;
      _to = $v.to;
      _totalDistanceM = $v.totalDistanceM;
      _year = $v.year;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta
      _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta
            ._(
          from: from,
          mode: mode,
          quarter: quarter,
          to: to,
          totalDistanceM: totalDistanceM,
          year: year,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
