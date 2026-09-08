// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_auth_dto_meta.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoMeta
    extends GithubComDevlineOnebookEldInternalDomainAuthDtoMeta {
  @override
  final int? page;
  @override
  final int? perPage;
  @override
  final int? total;

  factory _$GithubComDevlineOnebookEldInternalDomainAuthDtoMeta(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoMetaBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainAuthDtoMetaBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoMeta._(
      {this.page, this.perPage, this.total})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoMeta rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoMetaBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoMetaBuilder toBuilder() =>
      GithubComDevlineOnebookEldInternalDomainAuthDtoMetaBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainAuthDtoMeta &&
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
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoMeta')
          ..add('page', page)
          ..add('perPage', perPage)
          ..add('total', total))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainAuthDtoMetaBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainAuthDtoMeta,
            GithubComDevlineOnebookEldInternalDomainAuthDtoMetaBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainAuthDtoMeta? _$v;

  int? _page;
  int? get page => _$this._page;
  set page(int? page) => _$this._page = page;

  int? _perPage;
  int? get perPage => _$this._perPage;
  set perPage(int? perPage) => _$this._perPage = perPage;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  GithubComDevlineOnebookEldInternalDomainAuthDtoMetaBuilder() {
    GithubComDevlineOnebookEldInternalDomainAuthDtoMeta._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainAuthDtoMetaBuilder get _$this {
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
  void replace(GithubComDevlineOnebookEldInternalDomainAuthDtoMeta other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainAuthDtoMeta;
  }

  @override
  void update(
      void Function(GithubComDevlineOnebookEldInternalDomainAuthDtoMetaBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoMeta build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoMeta _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainAuthDtoMeta._(
          page: page,
          perPage: perPage,
          total: total,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
