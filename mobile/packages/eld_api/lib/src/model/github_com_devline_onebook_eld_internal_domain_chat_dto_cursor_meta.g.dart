// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_chat_dto_cursor_meta.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta
    extends GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta {
  @override
  final bool? hasMore;
  @override
  final DateTime? nextBefore;
  @override
  final int? perPage;
  @override
  final int? unread;

  factory _$GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainChatDtoCursorMetaBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainChatDtoCursorMetaBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta._(
      {this.hasMore, this.nextBefore, this.perPage, this.unread})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainChatDtoCursorMetaBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoCursorMetaBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainChatDtoCursorMetaBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta &&
        hasMore == other.hasMore &&
        nextBefore == other.nextBefore &&
        perPage == other.perPage &&
        unread == other.unread;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, hasMore.hashCode);
    _$hash = $jc(_$hash, nextBefore.hashCode);
    _$hash = $jc(_$hash, perPage.hashCode);
    _$hash = $jc(_$hash, unread.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta')
          ..add('hasMore', hasMore)
          ..add('nextBefore', nextBefore)
          ..add('perPage', perPage)
          ..add('unread', unread))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainChatDtoCursorMetaBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta,
            GithubComDevlineOnebookEldInternalDomainChatDtoCursorMetaBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta? _$v;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  DateTime? _nextBefore;
  DateTime? get nextBefore => _$this._nextBefore;
  set nextBefore(DateTime? nextBefore) => _$this._nextBefore = nextBefore;

  int? _perPage;
  int? get perPage => _$this._perPage;
  set perPage(int? perPage) => _$this._perPage = perPage;

  int? _unread;
  int? get unread => _$this._unread;
  set unread(int? unread) => _$this._unread = unread;

  GithubComDevlineOnebookEldInternalDomainChatDtoCursorMetaBuilder() {
    GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainChatDtoCursorMetaBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _hasMore = $v.hasMore;
      _nextBefore = $v.nextBefore;
      _perPage = $v.perPage;
      _unread = $v.unread;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainChatDtoCursorMetaBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta._(
          hasMore: hasMore,
          nextBefore: nextBefore,
          perPage: perPage,
          unread: unread,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
