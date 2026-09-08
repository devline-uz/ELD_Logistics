// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_auth_dto_message_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse
    extends GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse {
  @override
  final String? message;

  factory _$GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponseBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponseBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse._(
      {this.message})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponseBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponseBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse')
          ..add('message', message))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponseBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse,
            GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponseBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse? _$v;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponseBuilder() {
    GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponseBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse._(
          message: message,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
