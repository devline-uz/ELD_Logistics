// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_reports_dto_activity_row.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum
    _$githubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum_drivers =
    const GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum
        ._('drivers');
const GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum
    _$githubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum_units =
    const GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum
        ._('units');
const GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum
    _$githubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum
    _$githubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'drivers':
      return _$githubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum_drivers;
    case 'units':
      return _$githubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum_units;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum>
    _$githubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum>(const <GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum>[
  _$githubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum_drivers,
  _$githubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum_units,
  _$githubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum>
    _$githubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'drivers': 'drivers',
    'units': 'units',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'drivers': 'drivers',
    'units': 'units',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow
    extends GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow {
  @override
  final int? endOdometerM;
  @override
  final bool? hasData;
  @override
  final String? name;
  @override
  final int? odometerChangeM;
  @override
  final int? startOdometerM;
  @override
  final String? subjectId;
  @override
  final GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum?
      subjectType;

  factory _$GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow._(
      {this.endOdometerM,
      this.hasData,
      this.name,
      this.odometerChangeM,
      this.startOdometerM,
      this.subjectId,
      this.subjectType})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow &&
        endOdometerM == other.endOdometerM &&
        hasData == other.hasData &&
        name == other.name &&
        odometerChangeM == other.odometerChangeM &&
        startOdometerM == other.startOdometerM &&
        subjectId == other.subjectId &&
        subjectType == other.subjectType;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, endOdometerM.hashCode);
    _$hash = $jc(_$hash, hasData.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, odometerChangeM.hashCode);
    _$hash = $jc(_$hash, startOdometerM.hashCode);
    _$hash = $jc(_$hash, subjectId.hashCode);
    _$hash = $jc(_$hash, subjectType.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow')
          ..add('endOdometerM', endOdometerM)
          ..add('hasData', hasData)
          ..add('name', name)
          ..add('odometerChangeM', odometerChangeM)
          ..add('startOdometerM', startOdometerM)
          ..add('subjectId', subjectId)
          ..add('subjectType', subjectType))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow,
            GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow? _$v;

  int? _endOdometerM;
  int? get endOdometerM => _$this._endOdometerM;
  set endOdometerM(int? endOdometerM) => _$this._endOdometerM = endOdometerM;

  bool? _hasData;
  bool? get hasData => _$this._hasData;
  set hasData(bool? hasData) => _$this._hasData = hasData;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _odometerChangeM;
  int? get odometerChangeM => _$this._odometerChangeM;
  set odometerChangeM(int? odometerChangeM) =>
      _$this._odometerChangeM = odometerChangeM;

  int? _startOdometerM;
  int? get startOdometerM => _$this._startOdometerM;
  set startOdometerM(int? startOdometerM) =>
      _$this._startOdometerM = startOdometerM;

  String? _subjectId;
  String? get subjectId => _$this._subjectId;
  set subjectId(String? subjectId) => _$this._subjectId = subjectId;

  GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum?
      _subjectType;
  GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum?
      get subjectType => _$this._subjectType;
  set subjectType(
          GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum?
              subjectType) =>
      _$this._subjectType = subjectType;

  GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowBuilder() {
    GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _endOdometerM = $v.endOdometerM;
      _hasData = $v.hasData;
      _name = $v.name;
      _odometerChangeM = $v.odometerChangeM;
      _startOdometerM = $v.startOdometerM;
      _subjectId = $v.subjectId;
      _subjectType = $v.subjectType;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow._(
          endOdometerM: endOdometerM,
          hasData: hasData,
          name: name,
          odometerChangeM: odometerChangeM,
          startOdometerM: startOdometerM,
          subjectId: subjectId,
          subjectType: subjectType,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
