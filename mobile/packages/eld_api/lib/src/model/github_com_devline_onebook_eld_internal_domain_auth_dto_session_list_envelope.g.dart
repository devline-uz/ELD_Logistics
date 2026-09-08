// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_auth_dto_session_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope {
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainAuthDtoSession>? data;
  @override
  final GithubComDevlineOnebookEldInternalDomainAuthDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope &&
        data == other.data &&
        meta == other.meta;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, meta.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope,
            GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope? _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainAuthDtoSession>? _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainAuthDtoSession>
      get data => _$this._data ??=
          ListBuilder<GithubComDevlineOnebookEldInternalDomainAuthDtoSession>();
  set data(
          ListBuilder<GithubComDevlineOnebookEldInternalDomainAuthDtoSession>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainAuthDtoMetaBuilder? _meta;
  GithubComDevlineOnebookEldInternalDomainAuthDtoMetaBuilder get meta =>
      _$this._meta ??=
          GithubComDevlineOnebookEldInternalDomainAuthDtoMetaBuilder();
  set meta(GithubComDevlineOnebookEldInternalDomainAuthDtoMetaBuilder? meta) =>
      _$this._meta = meta;

  GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelopeBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data?.toBuilder();
      _meta = $v.meta?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope
              ._(
            data: _data?.build(),
            meta: _meta?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
        _$failedField = 'meta';
        _meta?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope',
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
