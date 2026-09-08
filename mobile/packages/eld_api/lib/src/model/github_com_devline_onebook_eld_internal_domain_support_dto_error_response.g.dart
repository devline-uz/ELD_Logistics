// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_support_dto_error_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainSupportDtoErrorResponse
    extends GithubComDevlineOnebookEldInternalDomainSupportDtoErrorResponse {
  @override
  final GithubComDevlineOnebookEldInternalHttpxDtoErrorBody? error;

  factory _$GithubComDevlineOnebookEldInternalDomainSupportDtoErrorResponse(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainSupportDtoErrorResponseBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainSupportDtoErrorResponseBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainSupportDtoErrorResponse._(
      {this.error})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoErrorResponse rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainSupportDtoErrorResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoErrorResponseBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainSupportDtoErrorResponseBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainSupportDtoErrorResponse &&
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
            r'GithubComDevlineOnebookEldInternalDomainSupportDtoErrorResponse')
          ..add('error', error))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainSupportDtoErrorResponseBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainSupportDtoErrorResponse,
            GithubComDevlineOnebookEldInternalDomainSupportDtoErrorResponseBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainSupportDtoErrorResponse? _$v;

  GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder? _error;
  GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder get error =>
      _$this._error ??=
          GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder();
  set error(
          GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder? error) =>
      _$this._error = error;

  GithubComDevlineOnebookEldInternalDomainSupportDtoErrorResponseBuilder() {
    GithubComDevlineOnebookEldInternalDomainSupportDtoErrorResponse._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainSupportDtoErrorResponseBuilder
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
      GithubComDevlineOnebookEldInternalDomainSupportDtoErrorResponse other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainSupportDtoErrorResponse;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainSupportDtoErrorResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoErrorResponse build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainSupportDtoErrorResponse _build() {
    _$GithubComDevlineOnebookEldInternalDomainSupportDtoErrorResponse _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainSupportDtoErrorResponse._(
            error: _error?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'error';
        _error?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainSupportDtoErrorResponse',
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
