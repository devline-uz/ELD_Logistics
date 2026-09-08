// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_sync_dto_telemetry_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult
    extends GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult {
  @override
  final int? accepted;
  @override
  final int? distanceM;
  @override
  final int? duplicate;
  @override
  final int? rejected;

  factory _$GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResultBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResultBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult._(
      {this.accepted, this.distanceM, this.duplicate, this.rejected})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResultBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResultBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResultBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult &&
        accepted == other.accepted &&
        distanceM == other.distanceM &&
        duplicate == other.duplicate &&
        rejected == other.rejected;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accepted.hashCode);
    _$hash = $jc(_$hash, distanceM.hashCode);
    _$hash = $jc(_$hash, duplicate.hashCode);
    _$hash = $jc(_$hash, rejected.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult')
          ..add('accepted', accepted)
          ..add('distanceM', distanceM)
          ..add('duplicate', duplicate)
          ..add('rejected', rejected))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResultBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult,
            GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResultBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult? _$v;

  int? _accepted;
  int? get accepted => _$this._accepted;
  set accepted(int? accepted) => _$this._accepted = accepted;

  int? _distanceM;
  int? get distanceM => _$this._distanceM;
  set distanceM(int? distanceM) => _$this._distanceM = distanceM;

  int? _duplicate;
  int? get duplicate => _$this._duplicate;
  set duplicate(int? duplicate) => _$this._duplicate = duplicate;

  int? _rejected;
  int? get rejected => _$this._rejected;
  set rejected(int? rejected) => _$this._rejected = rejected;

  GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResultBuilder() {
    GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResultBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _accepted = $v.accepted;
      _distanceM = $v.distanceM;
      _duplicate = $v.duplicate;
      _rejected = $v.rejected;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResultBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult._(
          accepted: accepted,
          distanceM: distanceM,
          duplicate: duplicate,
          rejected: rejected,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
