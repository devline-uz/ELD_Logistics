// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_dvir_dto_meta.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoMeta
    extends GithubComDevlineOnebookEldInternalDomainDvirDtoMeta {
  @override
  final int? page;
  @override
  final int? perPage;
  @override
  final int? total;

  factory _$GithubComDevlineOnebookEldInternalDomainDvirDtoMeta(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDvirDtoMetaBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDvirDtoMetaBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDvirDtoMeta._(
      {this.page, this.perPage, this.total})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoMeta rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDvirDtoMetaBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoMetaBuilder toBuilder() =>
      GithubComDevlineOnebookEldInternalDomainDvirDtoMetaBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainDvirDtoMeta &&
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
            r'GithubComDevlineOnebookEldInternalDomainDvirDtoMeta')
          ..add('page', page)
          ..add('perPage', perPage)
          ..add('total', total))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDvirDtoMetaBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainDvirDtoMeta,
            GithubComDevlineOnebookEldInternalDomainDvirDtoMetaBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDvirDtoMeta? _$v;

  int? _page;
  int? get page => _$this._page;
  set page(int? page) => _$this._page = page;

  int? _perPage;
  int? get perPage => _$this._perPage;
  set perPage(int? perPage) => _$this._perPage = perPage;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  GithubComDevlineOnebookEldInternalDomainDvirDtoMetaBuilder() {
    GithubComDevlineOnebookEldInternalDomainDvirDtoMeta._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainDvirDtoMetaBuilder get _$this {
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
  void replace(GithubComDevlineOnebookEldInternalDomainDvirDtoMeta other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainDvirDtoMeta;
  }

  @override
  void update(
      void Function(GithubComDevlineOnebookEldInternalDomainDvirDtoMetaBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoMeta build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainDvirDtoMeta _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainDvirDtoMeta._(
          page: page,
          perPage: perPage,
          total: total,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
