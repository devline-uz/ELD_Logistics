// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_maintenance_dto_schedule_unit_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope
    extends GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnit?
      data;

  factory _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope
      rebuild(
              void Function(
                      GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelopeBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope &&
        data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope,
            GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope?
      _$v;

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitBuilder?
      _data;
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitBuilder
      get data => _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelopeBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope
              ._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope',
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
