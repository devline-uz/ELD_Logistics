// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_drivers_dto_status_change.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChange
    extends GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChange {
  @override
  final String? reason;

  factory _$GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChange(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChangeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChangeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChange._(
      {this.reason})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChange rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChangeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChangeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChangeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChange &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChange')
          ..add('reason', reason))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChangeBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChange,
            GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChangeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChange? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChangeBuilder() {
    GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChange._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChangeBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChange other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChange;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChangeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChange build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChange _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChange._(
          reason: reason,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
