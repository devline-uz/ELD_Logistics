// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_tracking_dto_error_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainTrackingDtoErrorResponse
    extends GithubComDevlineOnebookEldInternalDomainTrackingDtoErrorResponse {
  @override
  final GithubComDevlineOnebookEldInternalHttpxDtoErrorBody? error;

  factory _$GithubComDevlineOnebookEldInternalDomainTrackingDtoErrorResponse(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainTrackingDtoErrorResponseBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainTrackingDtoErrorResponseBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainTrackingDtoErrorResponse._(
      {this.error})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainTrackingDtoErrorResponse rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainTrackingDtoErrorResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainTrackingDtoErrorResponseBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainTrackingDtoErrorResponseBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainTrackingDtoErrorResponse &&
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
            r'GithubComDevlineOnebookEldInternalDomainTrackingDtoErrorResponse')
          ..add('error', error))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainTrackingDtoErrorResponseBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainTrackingDtoErrorResponse,
            GithubComDevlineOnebookEldInternalDomainTrackingDtoErrorResponseBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainTrackingDtoErrorResponse? _$v;

  GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder? _error;
  GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder get error =>
      _$this._error ??=
          GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder();
  set error(
          GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder? error) =>
      _$this._error = error;

  GithubComDevlineOnebookEldInternalDomainTrackingDtoErrorResponseBuilder() {
    GithubComDevlineOnebookEldInternalDomainTrackingDtoErrorResponse._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainTrackingDtoErrorResponseBuilder
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
      GithubComDevlineOnebookEldInternalDomainTrackingDtoErrorResponse other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainTrackingDtoErrorResponse;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainTrackingDtoErrorResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainTrackingDtoErrorResponse build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainTrackingDtoErrorResponse _build() {
    _$GithubComDevlineOnebookEldInternalDomainTrackingDtoErrorResponse _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainTrackingDtoErrorResponse._(
            error: _error?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'error';
        _error?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainTrackingDtoErrorResponse',
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
