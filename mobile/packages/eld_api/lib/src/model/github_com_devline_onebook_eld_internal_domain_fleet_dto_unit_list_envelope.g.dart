// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_fleet_dto_unit_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope {
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainFleetDtoUnit>? data;
  @override
  final GithubComDevlineOnebookEldInternalDomainFleetDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope &&
        data == other.data &&
        meta == other.meta;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, meta.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope,
            GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope? _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainFleetDtoUnit>? _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainFleetDtoUnit> get data =>
      _$this._data ??=
          ListBuilder<GithubComDevlineOnebookEldInternalDomainFleetDtoUnit>();
  set data(
          ListBuilder<GithubComDevlineOnebookEldInternalDomainFleetDtoUnit>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainFleetDtoMetaBuilder? _meta;
  GithubComDevlineOnebookEldInternalDomainFleetDtoMetaBuilder get meta =>
      _$this._meta ??=
          GithubComDevlineOnebookEldInternalDomainFleetDtoMetaBuilder();
  set meta(GithubComDevlineOnebookEldInternalDomainFleetDtoMetaBuilder? meta) =>
      _$this._meta = meta;

  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelopeBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data?.toBuilder();
      _meta = $v.meta?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope._(
            data: _data?.build(),
            meta: _meta?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
        _$failedField = 'meta';
        _meta?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope',
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
