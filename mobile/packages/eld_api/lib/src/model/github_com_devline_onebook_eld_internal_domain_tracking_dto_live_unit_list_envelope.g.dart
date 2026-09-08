// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_tracking_dto_live_unit_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelope {
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnit>?
      data;
  @override
  final GithubComDevlineOnebookEldInternalDomainTrackingDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelope,
            GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelope?
      _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnit>?
      _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnit>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnit>();
  set data(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnit>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainTrackingDtoMetaBuilder? _meta;
  GithubComDevlineOnebookEldInternalDomainTrackingDtoMetaBuilder get meta =>
      _$this._meta ??=
          GithubComDevlineOnebookEldInternalDomainTrackingDtoMetaBuilder();
  set meta(
          GithubComDevlineOnebookEldInternalDomainTrackingDtoMetaBuilder?
              meta) =>
      _$this._meta = meta;

  GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelope',
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
