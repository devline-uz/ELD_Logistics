// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_duty_dto_meta.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainDutyDtoMeta
    extends GithubComDevlineOnebookEldInternalDomainDutyDtoMeta {
  @override
  final int? page;
  @override
  final int? perPage;
  @override
  final int? total;

  factory _$GithubComDevlineOnebookEldInternalDomainDutyDtoMeta(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDutyDtoMetaBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDutyDtoMetaBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDutyDtoMeta._(
      {this.page, this.perPage, this.total})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDutyDtoMeta rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDutyDtoMetaBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDutyDtoMetaBuilder toBuilder() =>
      GithubComDevlineOnebookEldInternalDomainDutyDtoMetaBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainDutyDtoMeta &&
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
            r'GithubComDevlineOnebookEldInternalDomainDutyDtoMeta')
          ..add('page', page)
          ..add('perPage', perPage)
          ..add('total', total))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDutyDtoMetaBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainDutyDtoMeta,
            GithubComDevlineOnebookEldInternalDomainDutyDtoMetaBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDutyDtoMeta? _$v;

  int? _page;
  int? get page => _$this._page;
  set page(int? page) => _$this._page = page;

  int? _perPage;
  int? get perPage => _$this._perPage;
  set perPage(int? perPage) => _$this._perPage = perPage;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  GithubComDevlineOnebookEldInternalDomainDutyDtoMetaBuilder() {
    GithubComDevlineOnebookEldInternalDomainDutyDtoMeta._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainDutyDtoMetaBuilder get _$this {
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
  void replace(GithubComDevlineOnebookEldInternalDomainDutyDtoMeta other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainDutyDtoMeta;
  }

  @override
  void update(
      void Function(GithubComDevlineOnebookEldInternalDomainDutyDtoMetaBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDutyDtoMeta build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainDutyDtoMeta _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainDutyDtoMeta._(
          page: page,
          perPage: perPage,
          total: total,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
