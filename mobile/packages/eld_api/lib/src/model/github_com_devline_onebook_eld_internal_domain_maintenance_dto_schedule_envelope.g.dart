// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_maintenance_dto_schedule_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope
    extends GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainMaintenanceDtoSchedule? data;

  factory _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope,
            GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleBuilder
      get data => _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope',
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
