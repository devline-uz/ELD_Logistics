// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_company_dto_settings.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum
    _$githubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum_usStates =
    const GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum
        ._('usStates');
const GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum
    _$githubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum_pkProvinces =
    const GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum
        ._('pkProvinces');
const GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum
    _$githubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum_uzRegions =
    const GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum
        ._('uzRegions');
const GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum
    _$githubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum_none =
    const GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum
        ._('none');
const GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum
    _$githubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum
    _$githubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnumValueOf(
        String name) {
  switch (name) {
    case 'usStates':
      return _$githubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum_usStates;
    case 'pkProvinces':
      return _$githubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum_pkProvinces;
    case 'uzRegions':
      return _$githubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum_uzRegions;
    case 'none':
      return _$githubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum_none;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum>
    _$githubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum>(const <GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum>[
  _$githubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum_usStates,
  _$githubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum_pkProvinces,
  _$githubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum_uzRegions,
  _$githubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum_none,
  _$githubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum>
    _$githubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'usStates': 'us_states',
    'pkProvinces': 'pk_provinces',
    'uzRegions': 'uz_regions',
    'none': 'none',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'us_states': 'usStates',
    'pk_provinces': 'pkProvinces',
    'uz_regions': 'uzRegions',
    'none': 'none',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings
    extends GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings {
  @override
  final GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum?
      distanceRegionsSet;
  @override
  final BuiltList<String>? fuelTypes;
  @override
  final BuiltList<String>? quickNotes;

  factory _$GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings._(
      {this.distanceRegionsSet, this.fuelTypes, this.quickNotes})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings &&
        distanceRegionsSet == other.distanceRegionsSet &&
        fuelTypes == other.fuelTypes &&
        quickNotes == other.quickNotes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, distanceRegionsSet.hashCode);
    _$hash = $jc(_$hash, fuelTypes.hashCode);
    _$hash = $jc(_$hash, quickNotes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings')
          ..add('distanceRegionsSet', distanceRegionsSet)
          ..add('fuelTypes', fuelTypes)
          ..add('quickNotes', quickNotes))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings,
            GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings? _$v;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum?
      _distanceRegionsSet;
  GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum?
      get distanceRegionsSet => _$this._distanceRegionsSet;
  set distanceRegionsSet(
          GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum?
              distanceRegionsSet) =>
      _$this._distanceRegionsSet = distanceRegionsSet;

  ListBuilder<String>? _fuelTypes;
  ListBuilder<String> get fuelTypes =>
      _$this._fuelTypes ??= ListBuilder<String>();
  set fuelTypes(ListBuilder<String>? fuelTypes) =>
      _$this._fuelTypes = fuelTypes;

  ListBuilder<String>? _quickNotes;
  ListBuilder<String> get quickNotes =>
      _$this._quickNotes ??= ListBuilder<String>();
  set quickNotes(ListBuilder<String>? quickNotes) =>
      _$this._quickNotes = quickNotes;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsBuilder() {
    GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _distanceRegionsSet = $v.distanceRegionsSet;
      _fuelTypes = $v.fuelTypes?.toBuilder();
      _quickNotes = $v.quickNotes?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings _build() {
    _$GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings._(
            distanceRegionsSet: distanceRegionsSet,
            fuelTypes: _fuelTypes?.build(),
            quickNotes: _quickNotes?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'fuelTypes';
        _fuelTypes?.build();
        _$failedField = 'quickNotes';
        _quickNotes?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
