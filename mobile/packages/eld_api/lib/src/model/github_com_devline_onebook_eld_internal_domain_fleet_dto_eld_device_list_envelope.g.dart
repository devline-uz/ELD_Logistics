// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_fleet_dto_eld_device_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceListEnvelope {
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDevice>?
      data;
  @override
  final GithubComDevlineOnebookEldInternalDomainFleetDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceListEnvelope,
            GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceListEnvelope? _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDevice>? _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDevice>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainFleetDtoEldDevice>();
  set data(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDevice>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainFleetDtoMetaBuilder? _meta;
  GithubComDevlineOnebookEldInternalDomainFleetDtoMetaBuilder get meta =>
      _$this._meta ??=
          GithubComDevlineOnebookEldInternalDomainFleetDtoMetaBuilder();
  set meta(GithubComDevlineOnebookEldInternalDomainFleetDtoMetaBuilder? meta) =>
      _$this._meta = meta;

  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceListEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceListEnvelope',
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
