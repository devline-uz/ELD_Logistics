// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_files_dto_import_result_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope
    extends GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult? data;

  factory _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope &&
        data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope,
            GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultBuilder
      get data => _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelopeBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope
              ._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope',
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
