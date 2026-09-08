// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_tracking_dto_unidentified_event_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope {
  @override
  final BuiltList<
          GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent>?
      data;
  @override
  final GithubComDevlineOnebookEldInternalDomainTrackingDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope
      rebuild(
              void Function(
                      GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelopeBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope,
            GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope?
      _$v;

  ListBuilder<
          GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent>?
      _data;
  ListBuilder<
          GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent>();
  set data(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent>?
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

  GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope',
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
