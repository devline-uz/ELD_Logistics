// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_httpx_dto_error_body.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalHttpxDtoErrorBody
    extends GithubComDevlineOnebookEldInternalHttpxDtoErrorBody {
  @override
  final String? code;
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalHttpxDtoFieldError>?
      details;
  @override
  final String? message;

  factory _$GithubComDevlineOnebookEldInternalHttpxDtoErrorBody(
          [void Function(
                  GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalHttpxDtoErrorBody._(
      {this.code, this.details, this.message})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalHttpxDtoErrorBody rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder toBuilder() =>
      GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalHttpxDtoErrorBody &&
        code == other.code &&
        details == other.details &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, details.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalHttpxDtoErrorBody')
          ..add('code', code)
          ..add('details', details)
          ..add('message', message))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalHttpxDtoErrorBody,
            GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder> {
  _$GithubComDevlineOnebookEldInternalHttpxDtoErrorBody? _$v;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  ListBuilder<GithubComDevlineOnebookEldInternalHttpxDtoFieldError>? _details;
  ListBuilder<GithubComDevlineOnebookEldInternalHttpxDtoFieldError>
      get details => _$this._details ??=
          ListBuilder<GithubComDevlineOnebookEldInternalHttpxDtoFieldError>();
  set details(
          ListBuilder<GithubComDevlineOnebookEldInternalHttpxDtoFieldError>?
              details) =>
      _$this._details = details;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder() {
    GithubComDevlineOnebookEldInternalHttpxDtoErrorBody._defaults(this);
  }

  GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _details = $v.details?.toBuilder();
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GithubComDevlineOnebookEldInternalHttpxDtoErrorBody other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalHttpxDtoErrorBody;
  }

  @override
  void update(
      void Function(GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalHttpxDtoErrorBody build() => _build();

  _$GithubComDevlineOnebookEldInternalHttpxDtoErrorBody _build() {
    _$GithubComDevlineOnebookEldInternalHttpxDtoErrorBody _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalHttpxDtoErrorBody._(
            code: code,
            details: _details?.build(),
            message: message,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'details';
        _details?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalHttpxDtoErrorBody',
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
