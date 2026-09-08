// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_drivers_dto_meta.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainDriversDtoMeta
    extends GithubComDevlineOnebookEldInternalDomainDriversDtoMeta {
  @override
  final int? page;
  @override
  final int? perPage;
  @override
  final int? total;

  factory _$GithubComDevlineOnebookEldInternalDomainDriversDtoMeta(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDriversDtoMetaBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDriversDtoMetaBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDriversDtoMeta._(
      {this.page, this.perPage, this.total})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoMeta rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDriversDtoMetaBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoMetaBuilder toBuilder() =>
      GithubComDevlineOnebookEldInternalDomainDriversDtoMetaBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainDriversDtoMeta &&
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
            r'GithubComDevlineOnebookEldInternalDomainDriversDtoMeta')
          ..add('page', page)
          ..add('perPage', perPage)
          ..add('total', total))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDriversDtoMetaBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainDriversDtoMeta,
            GithubComDevlineOnebookEldInternalDomainDriversDtoMetaBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDriversDtoMeta? _$v;

  int? _page;
  int? get page => _$this._page;
  set page(int? page) => _$this._page = page;

  int? _perPage;
  int? get perPage => _$this._perPage;
  set perPage(int? perPage) => _$this._perPage = perPage;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  GithubComDevlineOnebookEldInternalDomainDriversDtoMetaBuilder() {
    GithubComDevlineOnebookEldInternalDomainDriversDtoMeta._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainDriversDtoMetaBuilder get _$this {
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
  void replace(GithubComDevlineOnebookEldInternalDomainDriversDtoMeta other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainDriversDtoMeta;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDriversDtoMetaBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoMeta build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainDriversDtoMeta _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainDriversDtoMeta._(
          page: page,
          perPage: perPage,
          total: total,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
