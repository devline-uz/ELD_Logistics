// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_dvir_dto_defect_type_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope {
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType>?
      data;
  @override
  final GithubComDevlineOnebookEldInternalDomainDvirDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope,
            GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope? _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType>? _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType>();
  set data(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainDvirDtoMetaBuilder? _meta;
  GithubComDevlineOnebookEldInternalDomainDvirDtoMetaBuilder get meta =>
      _$this._meta ??=
          GithubComDevlineOnebookEldInternalDomainDvirDtoMetaBuilder();
  set meta(GithubComDevlineOnebookEldInternalDomainDvirDtoMetaBuilder? meta) =>
      _$this._meta = meta;

  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope',
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
