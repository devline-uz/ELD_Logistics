// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_maintenance_dto_record_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordListEnvelope {
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord>?
      data;
  @override
  final GithubComDevlineOnebookEldInternalDomainMaintenanceDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordListEnvelope,
            GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordListEnvelope?
      _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord>?
      _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord>();
  set data(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoMetaBuilder? _meta;
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoMetaBuilder get meta =>
      _$this._meta ??=
          GithubComDevlineOnebookEldInternalDomainMaintenanceDtoMetaBuilder();
  set meta(
          GithubComDevlineOnebookEldInternalDomainMaintenanceDtoMetaBuilder?
              meta) =>
      _$this._meta = meta;

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordListEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordListEnvelope',
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
