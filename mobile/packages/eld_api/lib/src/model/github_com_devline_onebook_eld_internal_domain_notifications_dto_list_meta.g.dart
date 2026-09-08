// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_notifications_dto_list_meta.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMeta
    extends GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMeta {
  @override
  final int? page;
  @override
  final int? perPage;
  @override
  final int? total;
  @override
  final int? unread;

  factory _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMeta(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMetaBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMetaBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMeta._(
      {this.page, this.perPage, this.total, this.unread})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMeta rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMetaBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMetaBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMetaBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMeta &&
        page == other.page &&
        perPage == other.perPage &&
        total == other.total &&
        unread == other.unread;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, page.hashCode);
    _$hash = $jc(_$hash, perPage.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, unread.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMeta')
          ..add('page', page)
          ..add('perPage', perPage)
          ..add('total', total)
          ..add('unread', unread))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMetaBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMeta,
            GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMetaBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMeta? _$v;

  int? _page;
  int? get page => _$this._page;
  set page(int? page) => _$this._page = page;

  int? _perPage;
  int? get perPage => _$this._perPage;
  set perPage(int? perPage) => _$this._perPage = perPage;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  int? _unread;
  int? get unread => _$this._unread;
  set unread(int? unread) => _$this._unread = unread;

  GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMetaBuilder() {
    GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMeta._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMetaBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _page = $v.page;
      _perPage = $v.perPage;
      _total = $v.total;
      _unread = $v.unread;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMeta other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMeta;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMetaBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMeta build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMeta _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoListMeta._(
          page: page,
          perPage: perPage,
          total: total,
          unread: unread,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
