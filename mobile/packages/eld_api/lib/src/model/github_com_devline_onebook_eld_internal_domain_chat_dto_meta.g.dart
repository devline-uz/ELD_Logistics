// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_chat_dto_meta.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainChatDtoMeta
    extends GithubComDevlineOnebookEldInternalDomainChatDtoMeta {
  @override
  final int? page;
  @override
  final int? perPage;
  @override
  final int? total;

  factory _$GithubComDevlineOnebookEldInternalDomainChatDtoMeta(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainChatDtoMetaBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainChatDtoMetaBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainChatDtoMeta._(
      {this.page, this.perPage, this.total})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoMeta rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainChatDtoMetaBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoMetaBuilder toBuilder() =>
      GithubComDevlineOnebookEldInternalDomainChatDtoMetaBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainChatDtoMeta &&
        page == other.page &&
        perPage == other.perPage &&
        total == other.total;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, page.hashCode);
    _$hash = $jc(_$hash, perPage.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainChatDtoMeta')
          ..add('page', page)
          ..add('perPage', perPage)
          ..add('total', total))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainChatDtoMetaBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainChatDtoMeta,
            GithubComDevlineOnebookEldInternalDomainChatDtoMetaBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainChatDtoMeta? _$v;

  int? _page;
  int? get page => _$this._page;
  set page(int? page) => _$this._page = page;

  int? _perPage;
  int? get perPage => _$this._perPage;
  set perPage(int? perPage) => _$this._perPage = perPage;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  GithubComDevlineOnebookEldInternalDomainChatDtoMetaBuilder() {
    GithubComDevlineOnebookEldInternalDomainChatDtoMeta._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainChatDtoMetaBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _page = $v.page;
      _perPage = $v.perPage;
      _total = $v.total;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GithubComDevlineOnebookEldInternalDomainChatDtoMeta other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainChatDtoMeta;
  }

  @override
  void update(
      void Function(GithubComDevlineOnebookEldInternalDomainChatDtoMetaBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoMeta build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainChatDtoMeta _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainChatDtoMeta._(
          page: page,
          perPage: perPage,
          total: total,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
