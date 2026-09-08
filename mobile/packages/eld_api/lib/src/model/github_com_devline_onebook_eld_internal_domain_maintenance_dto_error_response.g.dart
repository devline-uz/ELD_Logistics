// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_maintenance_dto_error_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse
    extends GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse {
  @override
  final GithubComDevlineOnebookEldInternalHttpxDtoErrorBody? error;

  factory _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponseBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponseBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse._(
      {this.error})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponseBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponseBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse &&
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
            r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse')
          ..add('error', error))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponseBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse,
            GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponseBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse? _$v;

  GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder? _error;
  GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder get error =>
      _$this._error ??=
          GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder();
  set error(
          GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder? error) =>
      _$this._error = error;

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponseBuilder() {
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponseBuilder
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
      GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse
              ._(
            error: _error?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'error';
        _error?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse',
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
