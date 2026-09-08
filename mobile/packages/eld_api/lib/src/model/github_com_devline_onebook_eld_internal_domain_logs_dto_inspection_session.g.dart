// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_logs_dto_inspection_session.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSession
    extends GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSession {
  @override
  final String? driverId;
  @override
  final String? driverName;
  @override
  final DateTime? expiresAt;
  @override
  final String? token;

  factory _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSession(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSession._(
      {this.driverId, this.driverName, this.expiresAt, this.token})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSession rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSession &&
        driverId == other.driverId &&
        driverName == other.driverName &&
        expiresAt == other.expiresAt &&
        token == other.token;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, driverName.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSession')
          ..add('driverId', driverId)
          ..add('driverName', driverName)
          ..add('expiresAt', expiresAt)
          ..add('token', token))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSession,
            GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSession? _$v;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  String? _driverName;
  String? get driverName => _$this._driverName;
  set driverName(String? driverName) => _$this._driverName = driverName;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionBuilder() {
    GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSession._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _driverId = $v.driverId;
      _driverName = $v.driverName;
      _expiresAt = $v.expiresAt;
      _token = $v.token;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSession other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSession;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSessionBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSession build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSession _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionSession._(
          driverId: driverId,
          driverName: driverName,
          expiresAt: expiresAt,
          token: token,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
