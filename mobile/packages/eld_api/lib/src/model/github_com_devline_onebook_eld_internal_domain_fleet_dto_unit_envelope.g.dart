// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_fleet_dto_unit_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope
    extends GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainFleetDtoUnit? data;

  factory _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope._({this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelopeBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope,
            GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainFleetDtoUnitBuilder();
  set data(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitBuilder? data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope other) {
    _$v =
        other as _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope',
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
