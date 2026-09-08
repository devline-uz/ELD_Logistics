// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_auth_dto_error_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoErrorResponse
    extends GithubComDevlineOnebookEldInternalDomainAuthDtoErrorResponse {
  @override
  final GithubComDevlineOnebookEldInternalHttpxDtoErrorBody? error;

  factory _$GithubComDevlineOnebookEldInternalDomainAuthDtoErrorResponse(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoErrorResponseBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainAuthDtoErrorResponseBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoErrorResponse._({this.error})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoErrorResponse rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoErrorResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoErrorResponseBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainAuthDtoErrorResponseBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainAuthDtoErrorResponse &&
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
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoErrorResponse')
          ..add('error', error))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainAuthDtoErrorResponseBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainAuthDtoErrorResponse,
            GithubComDevlineOnebookEldInternalDomainAuthDtoErrorResponseBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainAuthDtoErrorResponse? _$v;

  GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder? _error;
  GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder get error =>
      _$this._error ??=
          GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder();
  set error(
          GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder? error) =>
      _$this._error = error;

  GithubComDevlineOnebookEldInternalDomainAuthDtoErrorResponseBuilder() {
    GithubComDevlineOnebookEldInternalDomainAuthDtoErrorResponse._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainAuthDtoErrorResponseBuilder
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
      GithubComDevlineOnebookEldInternalDomainAuthDtoErrorResponse other) {
    _$v =
        other as _$GithubComDevlineOnebookEldInternalDomainAuthDtoErrorResponse;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainAuthDtoErrorResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoErrorResponse build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoErrorResponse _build() {
    _$GithubComDevlineOnebookEldInternalDomainAuthDtoErrorResponse _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainAuthDtoErrorResponse._(
            error: _error?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'error';
        _error?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoErrorResponse',
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
