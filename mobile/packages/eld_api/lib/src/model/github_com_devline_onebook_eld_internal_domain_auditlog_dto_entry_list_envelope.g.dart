// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_auditlog_dto_entry_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope {
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntry>?
      data;
  @override
  final GithubComDevlineOnebookEldInternalDomainAuditlogDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope,
            GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope? _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntry>? _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntry>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntry>();
  set data(
          ListBuilder<GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntry>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainAuditlogDtoMetaBuilder? _meta;
  GithubComDevlineOnebookEldInternalDomainAuditlogDtoMetaBuilder get meta =>
      _$this._meta ??=
          GithubComDevlineOnebookEldInternalDomainAuditlogDtoMetaBuilder();
  set meta(
          GithubComDevlineOnebookEldInternalDomainAuditlogDtoMetaBuilder?
              meta) =>
      _$this._meta = meta;

  GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope',
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
