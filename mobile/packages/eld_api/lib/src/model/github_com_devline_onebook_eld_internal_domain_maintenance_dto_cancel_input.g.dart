// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_maintenance_dto_cancel_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput
    extends GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput {
  @override
  final String cancelledReason;

  factory _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInputBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInputBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput._(
      {required this.cancelledReason})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInputBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInputBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInputBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput &&
        cancelledReason == other.cancelledReason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, cancelledReason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput')
          ..add('cancelledReason', cancelledReason))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInputBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput,
            GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInputBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput? _$v;

  String? _cancelledReason;
  String? get cancelledReason => _$this._cancelledReason;
  set cancelledReason(String? cancelledReason) =>
      _$this._cancelledReason = cancelledReason;

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInputBuilder() {
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInputBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _cancelledReason = $v.cancelledReason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInputBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput._(
          cancelledReason: BuiltValueNullFieldError.checkNotNull(
              cancelledReason,
              r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput',
              'cancelledReason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
