// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_tracking_dto_trip_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope
    extends GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainTrackingDtoTripDetail? data;

  factory _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelopeBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope,
            GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainTrackingDtoTripDetailBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainTrackingDtoTripDetailBuilder
      get data => _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainTrackingDtoTripDetailBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainTrackingDtoTripDetailBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope',
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
