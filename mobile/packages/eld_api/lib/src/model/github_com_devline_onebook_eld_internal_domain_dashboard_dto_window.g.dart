// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_dashboard_dto_window.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow
    extends GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow {
  @override
  final DateTime? from;
  @override
  final DateTime? to;

  factory _$GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDashboardDtoWindowBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDashboardDtoWindowBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow._(
      {this.from, this.to})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDashboardDtoWindowBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDashboardDtoWindowBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainDashboardDtoWindowBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow &&
        from == other.from &&
        to == other.to;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, from.hashCode);
    _$hash = $jc(_$hash, to.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow')
          ..add('from', from)
          ..add('to', to))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDashboardDtoWindowBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow,
            GithubComDevlineOnebookEldInternalDomainDashboardDtoWindowBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow? _$v;

  DateTime? _from;
  DateTime? get from => _$this._from;
  set from(DateTime? from) => _$this._from = from;

  DateTime? _to;
  DateTime? get to => _$this._to;
  set to(DateTime? to) => _$this._to = to;

  GithubComDevlineOnebookEldInternalDomainDashboardDtoWindowBuilder() {
    GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainDashboardDtoWindowBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _from = $v.from;
      _to = $v.to;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDashboardDtoWindowBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainDashboardDtoWindow._(
          from: from,
          to: to,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
