// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_logs_dto_certify_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequest
    extends GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequest {
  @override
  final String? deviceId;
  @override
  final String? signatureId;
  @override
  final String? signatureKey;

  factory _$GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequest(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequestBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequestBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequest._(
      {this.deviceId, this.signatureId, this.signatureKey})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequest rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequestBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequestBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequest &&
        deviceId == other.deviceId &&
        signatureId == other.signatureId &&
        signatureKey == other.signatureKey;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, signatureId.hashCode);
    _$hash = $jc(_$hash, signatureKey.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequest')
          ..add('deviceId', deviceId)
          ..add('signatureId', signatureId)
          ..add('signatureKey', signatureKey))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequestBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequest,
            GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequestBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequest? _$v;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  String? _signatureId;
  String? get signatureId => _$this._signatureId;
  set signatureId(String? signatureId) => _$this._signatureId = signatureId;

  String? _signatureKey;
  String? get signatureKey => _$this._signatureKey;
  set signatureKey(String? signatureKey) => _$this._signatureKey = signatureKey;

  GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequestBuilder() {
    GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequest._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequestBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _deviceId = $v.deviceId;
      _signatureId = $v.signatureId;
      _signatureKey = $v.signatureKey;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequest other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequest;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequest build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequest _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequest._(
          deviceId: deviceId,
          signatureId: signatureId,
          signatureKey: signatureKey,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
