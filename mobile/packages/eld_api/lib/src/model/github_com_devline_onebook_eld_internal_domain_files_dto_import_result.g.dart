// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_files_dto_import_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult
    extends GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult {
  @override
  final BuiltList<
      GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError>? errors;
  @override
  final int? imported;
  @override
  final int? total;

  factory _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult._(
      {this.errors, this.imported, this.total})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult &&
        errors == other.errors &&
        imported == other.imported &&
        total == other.total;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, errors.hashCode);
    _$hash = $jc(_$hash, imported.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult')
          ..add('errors', errors)
          ..add('imported', imported)
          ..add('total', total))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult,
            GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult? _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError>?
      _errors;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError>
      get errors => _$this._errors ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError>();
  set errors(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainFilesDtoImportRowError>?
              errors) =>
      _$this._errors = errors;

  int? _imported;
  int? get imported => _$this._imported;
  set imported(int? imported) => _$this._imported = imported;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultBuilder() {
    GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _errors = $v.errors?.toBuilder();
      _imported = $v.imported;
      _total = $v.total;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult other) {
    _$v =
        other as _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult _build() {
    _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult._(
            errors: _errors?.build(),
            imported: imported,
            total: total,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'errors';
        _errors?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
