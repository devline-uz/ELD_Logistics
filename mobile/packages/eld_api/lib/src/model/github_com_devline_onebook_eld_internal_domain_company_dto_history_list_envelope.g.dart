// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_company_dto_history_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope {
  @override
  final BuiltList<
      GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry>? data;
  @override
  final GithubComDevlineOnebookEldInternalDomainCompanyDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope,
            GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope? _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry>?
      _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry>();
  set data(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoMetaBuilder? _meta;
  GithubComDevlineOnebookEldInternalDomainCompanyDtoMetaBuilder get meta =>
      _$this._meta ??=
          GithubComDevlineOnebookEldInternalDomainCompanyDtoMetaBuilder();
  set meta(
          GithubComDevlineOnebookEldInternalDomainCompanyDtoMetaBuilder?
              meta) =>
      _$this._meta = meta;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope',
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
