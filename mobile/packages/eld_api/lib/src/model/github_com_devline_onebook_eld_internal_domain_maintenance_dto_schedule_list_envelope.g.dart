// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_maintenance_dto_schedule_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope {
  @override
  final BuiltList<
      GithubComDevlineOnebookEldInternalDomainMaintenanceDtoSchedule>? data;
  @override
  final GithubComDevlineOnebookEldInternalDomainMaintenanceDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope
      rebuild(
              void Function(
                      GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelopeBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope,
            GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope?
      _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoSchedule>?
      _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoSchedule>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainMaintenanceDtoSchedule>();
  set data(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoSchedule>?
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

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope',
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
