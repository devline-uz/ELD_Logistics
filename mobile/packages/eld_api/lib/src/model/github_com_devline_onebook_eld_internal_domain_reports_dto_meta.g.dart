// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_reports_dto_meta.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainReportsDtoMeta
    extends GithubComDevlineOnebookEldInternalDomainReportsDtoMeta {
  @override
  final int? page;
  @override
  final int? perPage;
  @override
  final int? total;

  factory _$GithubComDevlineOnebookEldInternalDomainReportsDtoMeta(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainReportsDtoMetaBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainReportsDtoMetaBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainReportsDtoMeta._(
      {this.page, this.perPage, this.total})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoMeta rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainReportsDtoMetaBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoMetaBuilder toBuilder() =>
      GithubComDevlineOnebookEldInternalDomainReportsDtoMetaBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainReportsDtoMeta &&
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
            r'GithubComDevlineOnebookEldInternalDomainReportsDtoMeta')
          ..add('page', page)
          ..add('perPage', perPage)
          ..add('total', total))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainReportsDtoMetaBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainReportsDtoMeta,
            GithubComDevlineOnebookEldInternalDomainReportsDtoMetaBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainReportsDtoMeta? _$v;

  int? _page;
  int? get page => _$this._page;
  set page(int? page) => _$this._page = page;

  int? _perPage;
  int? get perPage => _$this._perPage;
  set perPage(int? perPage) => _$this._perPage = perPage;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  GithubComDevlineOnebookEldInternalDomainReportsDtoMetaBuilder() {
    GithubComDevlineOnebookEldInternalDomainReportsDtoMeta._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainReportsDtoMetaBuilder get _$this {
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
  void replace(GithubComDevlineOnebookEldInternalDomainReportsDtoMeta other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainReportsDtoMeta;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainReportsDtoMetaBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoMeta build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainReportsDtoMeta _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainReportsDtoMeta._(
          page: page,
          perPage: perPage,
          total: total,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
