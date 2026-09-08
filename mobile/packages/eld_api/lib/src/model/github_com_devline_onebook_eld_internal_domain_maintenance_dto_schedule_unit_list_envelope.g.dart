// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_maintenance_dto_schedule_unit_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitListEnvelope {
  @override
  final BuiltList<
      GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnit>? data;
  @override
  final GithubComDevlineOnebookEldInternalDomainMaintenanceDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitListEnvelope
      rebuild(
              void Function(
                      GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitListEnvelopeBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitListEnvelope,
            GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitListEnvelope?
      _$v;

  ListBuilder<
          GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnit>?
      _data;
  ListBuilder<
          GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnit>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnit>();
  set data(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnit>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoMetaBuilder? _meta;
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoMetaBuilder get meta =>
      _$this._meta ??=
          GithubComDevlineOnebookEldInternalDomainMaintenanceDtoMetaBuilder();
  set meta(
          GithubComDevlineOnebookEldInternalDomainMaintenanceDtoMetaBuilder?
              meta) =>
      _$this._meta = meta;

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitListEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitListEnvelope
              ._(
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
            r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitListEnvelope',
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
