// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_companies_dto_error_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoErrorResponse
    extends GithubComDevlineOnebookEldInternalDomainCompaniesDtoErrorResponse {
  @override
  final GithubComDevlineOnebookEldInternalHttpxDtoErrorBody? error;

  factory _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoErrorResponse(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainCompaniesDtoErrorResponseBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainCompaniesDtoErrorResponseBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoErrorResponse._(
      {this.error})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoErrorResponse rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainCompaniesDtoErrorResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoErrorResponseBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainCompaniesDtoErrorResponseBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainCompaniesDtoErrorResponse &&
        error == other.error;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, error.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainCompaniesDtoErrorResponse')
          ..add('error', error))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainCompaniesDtoErrorResponseBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainCompaniesDtoErrorResponse,
            GithubComDevlineOnebookEldInternalDomainCompaniesDtoErrorResponseBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoErrorResponse? _$v;

  GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder? _error;
  GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder get error =>
      _$this._error ??=
          GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder();
  set error(
          GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder? error) =>
      _$this._error = error;

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoErrorResponseBuilder() {
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoErrorResponse._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoErrorResponseBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _error = $v.error?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainCompaniesDtoErrorResponse other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoErrorResponse;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainCompaniesDtoErrorResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoErrorResponse build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoErrorResponse _build() {
    _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoErrorResponse
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoErrorResponse._(
            error: _error?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'error';
        _error?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainCompaniesDtoErrorResponse',
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
