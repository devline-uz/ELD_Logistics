// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_drivers_dto_co_driver_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverCreate
    extends GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverCreate {
  @override
  final String coDriverId;

  factory _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverCreate(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverCreateBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverCreateBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverCreate._(
      {required this.coDriverId})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverCreate rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverCreateBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverCreateBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverCreateBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverCreate &&
        coDriverId == other.coDriverId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, coDriverId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverCreate')
          ..add('coDriverId', coDriverId))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverCreateBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverCreate,
            GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverCreateBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverCreate? _$v;

  String? _coDriverId;
  String? get coDriverId => _$this._coDriverId;
  set coDriverId(String? coDriverId) => _$this._coDriverId = coDriverId;

  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverCreateBuilder() {
    GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverCreate._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverCreateBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _coDriverId = $v.coDriverId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverCreate other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverCreate;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverCreateBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverCreate build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverCreate _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverCreate._(
          coDriverId: BuiltValueNullFieldError.checkNotNull(
              coDriverId,
              r'GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverCreate',
              'coDriverId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
