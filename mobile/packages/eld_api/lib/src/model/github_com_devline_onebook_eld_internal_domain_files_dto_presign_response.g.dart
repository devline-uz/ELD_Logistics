// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_files_dto_presign_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponse
    extends GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponse {
  @override
  final DateTime? expiresAt;
  @override
  final BuiltMap<String, String>? headers;
  @override
  final String? key;
  @override
  final int? maxBytes;
  @override
  final String? method;
  @override
  final String? uploadUrl;

  factory _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponse(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponseBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponseBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponse._(
      {this.expiresAt,
      this.headers,
      this.key,
      this.maxBytes,
      this.method,
      this.uploadUrl})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponse rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponseBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponseBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponse &&
        expiresAt == other.expiresAt &&
        headers == other.headers &&
        key == other.key &&
        maxBytes == other.maxBytes &&
        method == other.method &&
        uploadUrl == other.uploadUrl;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, headers.hashCode);
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, maxBytes.hashCode);
    _$hash = $jc(_$hash, method.hashCode);
    _$hash = $jc(_$hash, uploadUrl.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponse')
          ..add('expiresAt', expiresAt)
          ..add('headers', headers)
          ..add('key', key)
          ..add('maxBytes', maxBytes)
          ..add('method', method)
          ..add('uploadUrl', uploadUrl))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponseBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponse,
            GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponseBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponse? _$v;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  MapBuilder<String, String>? _headers;
  MapBuilder<String, String> get headers =>
      _$this._headers ??= MapBuilder<String, String>();
  set headers(MapBuilder<String, String>? headers) => _$this._headers = headers;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  int? _maxBytes;
  int? get maxBytes => _$this._maxBytes;
  set maxBytes(int? maxBytes) => _$this._maxBytes = maxBytes;

  String? _method;
  String? get method => _$this._method;
  set method(String? method) => _$this._method = method;

  String? _uploadUrl;
  String? get uploadUrl => _$this._uploadUrl;
  set uploadUrl(String? uploadUrl) => _$this._uploadUrl = uploadUrl;

  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponseBuilder() {
    GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponse._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponseBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _expiresAt = $v.expiresAt;
      _headers = $v.headers?.toBuilder();
      _key = $v.key;
      _maxBytes = $v.maxBytes;
      _method = $v.method;
      _uploadUrl = $v.uploadUrl;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponse other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponse;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponse build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponse _build() {
    _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponse _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponse._(
            expiresAt: expiresAt,
            headers: _headers?.build(),
            key: key,
            maxBytes: maxBytes,
            method: method,
            uploadUrl: uploadUrl,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'headers';
        _headers?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponse',
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
