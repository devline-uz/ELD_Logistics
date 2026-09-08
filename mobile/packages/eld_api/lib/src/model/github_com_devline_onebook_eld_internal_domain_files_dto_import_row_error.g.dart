// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_files_dto_import_row_error.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError
    extends GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError {
  @override
  final String? field;
  @override
  final String? message;
  @override
  final int? row;

  factory _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowErrorBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowErrorBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError._(
      {this.field, this.message, this.row})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowErrorBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowErrorBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowErrorBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError &&
        field == other.field &&
        message == other.message &&
        row == other.row;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, field.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jc(_$hash, row.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError')
          ..add('field', field)
          ..add('message', message)
          ..add('row', row))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowErrorBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError,
            GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowErrorBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError? _$v;

  String? _field;
  String? get field => _$this._field;
  set field(String? field) => _$this._field = field;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  int? _row;
  int? get row => _$this._row;
  set row(int? row) => _$this._row = row;

  GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowErrorBuilder() {
    GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowErrorBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _field = $v.field;
      _message = $v.message;
      _row = $v.row;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowErrorBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError._(
          field: field,
          message: message,
          row: row,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
