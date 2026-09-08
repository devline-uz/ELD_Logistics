// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_fleet_dto_shipping_document_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentEnvelope
    extends GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocument? data;

  factory _$GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentEnvelope &&
        data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentEnvelope,
            GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentEnvelope?
      _$v;

  GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentBuilder?
      _data;
  GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentBuilder
      get data => _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentEnvelopeBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentEnvelope
              ._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentEnvelope',
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
