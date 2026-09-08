// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_fleet_dto_trailer_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerListEnvelope {
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainFleetDtoTrailer>?
      data;
  @override
  final GithubComDevlineOnebookEldInternalDomainFleetDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerListEnvelope,
            GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerListEnvelope? _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainFleetDtoTrailer>? _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainFleetDtoTrailer>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainFleetDtoTrailer>();
  set data(
          ListBuilder<GithubComDevlineOnebookEldInternalDomainFleetDtoTrailer>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainFleetDtoMetaBuilder? _meta;
  GithubComDevlineOnebookEldInternalDomainFleetDtoMetaBuilder get meta =>
      _$this._meta ??=
          GithubComDevlineOnebookEldInternalDomainFleetDtoMetaBuilder();
  set meta(GithubComDevlineOnebookEldInternalDomainFleetDtoMetaBuilder? meta) =>
      _$this._meta = meta;

  GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerListEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerListEnvelope',
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
