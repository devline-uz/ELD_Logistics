// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_tracking_dto_trip_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelope {
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip>?
      data;
  @override
  final GithubComDevlineOnebookEldInternalDomainTrackingDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelope,
            GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelope? _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip>? _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip>();
  set data(
          ListBuilder<GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip>?
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

  GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelope',
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
