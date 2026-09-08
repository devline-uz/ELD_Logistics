// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_auditlog_dto_error_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoErrorResponse
    extends GithubComDevlineOnebookEldInternalDomainAuditlogDtoErrorResponse {
  @override
  final GithubComDevlineOnebookEldInternalHttpxDtoErrorBody? error;

  factory _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoErrorResponse(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainAuditlogDtoErrorResponseBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainAuditlogDtoErrorResponseBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoErrorResponse._(
      {this.error})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainAuditlogDtoErrorResponse rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainAuditlogDtoErrorResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainAuditlogDtoErrorResponseBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainAuditlogDtoErrorResponseBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainAuditlogDtoErrorResponse &&
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
            r'GithubComDevlineOnebookEldInternalDomainAuditlogDtoErrorResponse')
          ..add('error', error))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainAuditlogDtoErrorResponseBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainAuditlogDtoErrorResponse,
            GithubComDevlineOnebookEldInternalDomainAuditlogDtoErrorResponseBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoErrorResponse? _$v;

  GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder? _error;
  GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder get error =>
      _$this._error ??=
          GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder();
  set error(
          GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder? error) =>
      _$this._error = error;

  GithubComDevlineOnebookEldInternalDomainAuditlogDtoErrorResponseBuilder() {
    GithubComDevlineOnebookEldInternalDomainAuditlogDtoErrorResponse._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainAuditlogDtoErrorResponseBuilder
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
      GithubComDevlineOnebookEldInternalDomainAuditlogDtoErrorResponse other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoErrorResponse;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainAuditlogDtoErrorResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuditlogDtoErrorResponse build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoErrorResponse _build() {
    _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoErrorResponse _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoErrorResponse._(
            error: _error?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'error';
        _error?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainAuditlogDtoErrorResponse',
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
