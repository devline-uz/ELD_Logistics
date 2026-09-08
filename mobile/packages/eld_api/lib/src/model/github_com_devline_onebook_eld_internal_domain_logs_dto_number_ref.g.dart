// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_logs_dto_number_ref.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef
    extends GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef {
  @override
  final String? id;
  @override
  final String? number;

  factory _$GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRefBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRefBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef._(
      {this.id, this.number})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRefBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRefBuilder toBuilder() =>
      GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRefBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef &&
        id == other.id &&
        number == other.number;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, number.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef')
          ..add('id', id)
          ..add('number', number))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRefBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef,
            GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRefBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _number;
  String? get number => _$this._number;
  set number(String? number) => _$this._number = number;

  GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRefBuilder() {
    GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRefBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _number = $v.number;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRefBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef._(
          id: id,
          number: number,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
