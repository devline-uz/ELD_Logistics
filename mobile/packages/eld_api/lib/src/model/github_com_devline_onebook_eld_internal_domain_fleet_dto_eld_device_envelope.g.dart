// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_fleet_dto_eld_device_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope
    extends GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainFleetDtoEldDevice? data;

  factory _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope,
            GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope',
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
