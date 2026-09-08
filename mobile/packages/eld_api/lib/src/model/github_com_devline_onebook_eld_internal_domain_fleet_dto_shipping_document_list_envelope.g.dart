// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_fleet_dto_shipping_document_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope {
  @override
  final BuiltList<
      GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocument>? data;
  @override
  final GithubComDevlineOnebookEldInternalDomainFleetDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope
      rebuild(
              void Function(
                      GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelopeBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope,
            GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope?
      _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocument>?
      _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocument>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocument>();
  set data(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocument>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainFleetDtoMetaBuilder? _meta;
  GithubComDevlineOnebookEldInternalDomainFleetDtoMetaBuilder get meta =>
      _$this._meta ??=
          GithubComDevlineOnebookEldInternalDomainFleetDtoMetaBuilder();
  set meta(GithubComDevlineOnebookEldInternalDomainFleetDtoMetaBuilder? meta) =>
      _$this._meta = meta;

  GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope',
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
