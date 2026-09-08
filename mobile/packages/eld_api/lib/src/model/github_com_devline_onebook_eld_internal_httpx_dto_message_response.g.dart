// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_httpx_dto_message_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalHttpxDtoMessageResponse
    extends GithubComDevlineOnebookEldInternalHttpxDtoMessageResponse {
  @override
  final String? message;

  factory _$GithubComDevlineOnebookEldInternalHttpxDtoMessageResponse(
          [void Function(
                  GithubComDevlineOnebookEldInternalHttpxDtoMessageResponseBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalHttpxDtoMessageResponseBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalHttpxDtoMessageResponse._({this.message})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalHttpxDtoMessageResponse rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalHttpxDtoMessageResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalHttpxDtoMessageResponseBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalHttpxDtoMessageResponseBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalHttpxDtoMessageResponse &&
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
            r'GithubComDevlineOnebookEldInternalHttpxDtoMessageResponse')
          ..add('message', message))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalHttpxDtoMessageResponseBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalHttpxDtoMessageResponse,
            GithubComDevlineOnebookEldInternalHttpxDtoMessageResponseBuilder> {
  _$GithubComDevlineOnebookEldInternalHttpxDtoMessageResponse? _$v;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  GithubComDevlineOnebookEldInternalHttpxDtoMessageResponseBuilder() {
    GithubComDevlineOnebookEldInternalHttpxDtoMessageResponse._defaults(this);
  }

  GithubComDevlineOnebookEldInternalHttpxDtoMessageResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalHttpxDtoMessageResponse other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalHttpxDtoMessageResponse;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalHttpxDtoMessageResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalHttpxDtoMessageResponse build() => _build();

  _$GithubComDevlineOnebookEldInternalHttpxDtoMessageResponse _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalHttpxDtoMessageResponse._(
          message: message,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
