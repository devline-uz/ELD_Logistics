// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_notifications_dto_read_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult
    extends GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult {
  @override
  final int? unread;
  @override
  final int? updated;

  factory _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult._(
      {this.unread, this.updated})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult &&
        unread == other.unread &&
        updated == other.updated;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, unread.hashCode);
    _$hash = $jc(_$hash, updated.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult')
          ..add('unread', unread)
          ..add('updated', updated))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult,
            GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult? _$v;

  int? _unread;
  int? get unread => _$this._unread;
  set unread(int? unread) => _$this._unread = unread;

  int? _updated;
  int? get updated => _$this._updated;
  set updated(int? updated) => _$this._updated = updated;

  GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultBuilder() {
    GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _unread = $v.unread;
      _updated = $v.updated;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult
      _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult._(
          unread: unread,
          updated: updated,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
