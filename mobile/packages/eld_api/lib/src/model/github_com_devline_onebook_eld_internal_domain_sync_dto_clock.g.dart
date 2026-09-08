// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_sync_dto_clock.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoClock
    extends GithubComDevlineOnebookEldInternalDomainSyncDtoClock {
  @override
  final DateTime? eldRtc;
  @override
  final DateTime? phone;

  factory _$GithubComDevlineOnebookEldInternalDomainSyncDtoClock(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainSyncDtoClockBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainSyncDtoClockBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainSyncDtoClock._(
      {this.eldRtc, this.phone})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoClock rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainSyncDtoClockBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoClockBuilder toBuilder() =>
      GithubComDevlineOnebookEldInternalDomainSyncDtoClockBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainSyncDtoClock &&
        eldRtc == other.eldRtc &&
        phone == other.phone;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, eldRtc.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainSyncDtoClock')
          ..add('eldRtc', eldRtc)
          ..add('phone', phone))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainSyncDtoClockBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainSyncDtoClock,
            GithubComDevlineOnebookEldInternalDomainSyncDtoClockBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainSyncDtoClock? _$v;

  DateTime? _eldRtc;
  DateTime? get eldRtc => _$this._eldRtc;
  set eldRtc(DateTime? eldRtc) => _$this._eldRtc = eldRtc;

  DateTime? _phone;
  DateTime? get phone => _$this._phone;
  set phone(DateTime? phone) => _$this._phone = phone;

  GithubComDevlineOnebookEldInternalDomainSyncDtoClockBuilder() {
    GithubComDevlineOnebookEldInternalDomainSyncDtoClock._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainSyncDtoClockBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _eldRtc = $v.eldRtc;
      _phone = $v.phone;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GithubComDevlineOnebookEldInternalDomainSyncDtoClock other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainSyncDtoClock;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainSyncDtoClockBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoClock build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainSyncDtoClock _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainSyncDtoClock._(
          eldRtc: eldRtc,
          phone: phone,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
