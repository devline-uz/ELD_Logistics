// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_fleet_dto_unit_assignment_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentEnvelope
    extends GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment? data;

  factory _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentEnvelope,
            GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentBuilder
      get data => _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentEnvelope',
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
