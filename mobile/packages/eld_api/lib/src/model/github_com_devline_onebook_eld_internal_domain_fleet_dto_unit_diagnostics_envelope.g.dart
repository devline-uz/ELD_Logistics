// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_fleet_dto_unit_diagnostics_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope
    extends GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnostics? data;

  factory _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope,
            GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope?
      _$v;

  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsBuilder
      get data => _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope',
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
