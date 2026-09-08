// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_chat_dto_read_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainChatDtoReadResult
    extends GithubComDevlineOnebookEldInternalDomainChatDtoReadResult {
  @override
  final int? unread;
  @override
  final int? updated;

  factory _$GithubComDevlineOnebookEldInternalDomainChatDtoReadResult(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainChatDtoReadResultBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainChatDtoReadResultBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainChatDtoReadResult._(
      {this.unread, this.updated})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoReadResult rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainChatDtoReadResultBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoReadResultBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainChatDtoReadResultBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainChatDtoReadResult &&
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
            r'GithubComDevlineOnebookEldInternalDomainChatDtoReadResult')
          ..add('unread', unread)
          ..add('updated', updated))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainChatDtoReadResultBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainChatDtoReadResult,
            GithubComDevlineOnebookEldInternalDomainChatDtoReadResultBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainChatDtoReadResult? _$v;

  int? _unread;
  int? get unread => _$this._unread;
  set unread(int? unread) => _$this._unread = unread;

  int? _updated;
  int? get updated => _$this._updated;
  set updated(int? updated) => _$this._updated = updated;

  GithubComDevlineOnebookEldInternalDomainChatDtoReadResultBuilder() {
    GithubComDevlineOnebookEldInternalDomainChatDtoReadResult._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainChatDtoReadResultBuilder get _$this {
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
      GithubComDevlineOnebookEldInternalDomainChatDtoReadResult other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainChatDtoReadResult;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainChatDtoReadResultBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoReadResult build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainChatDtoReadResult _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainChatDtoReadResult._(
          unread: unread,
          updated: updated,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
