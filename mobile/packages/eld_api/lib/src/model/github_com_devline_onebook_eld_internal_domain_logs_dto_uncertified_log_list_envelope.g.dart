// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_logs_dto_uncertified_log_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogListEnvelope {
  @override
  final BuiltList<
      GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog>? data;
  @override
  final GithubComDevlineOnebookEldInternalDomainLogsDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogListEnvelope,
            GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogListEnvelope?
      _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog>?
      _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog>();
  set data(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainLogsDtoMetaBuilder? _meta;
  GithubComDevlineOnebookEldInternalDomainLogsDtoMetaBuilder get meta =>
      _$this._meta ??=
          GithubComDevlineOnebookEldInternalDomainLogsDtoMetaBuilder();
  set meta(GithubComDevlineOnebookEldInternalDomainLogsDtoMetaBuilder? meta) =>
      _$this._meta = meta;

  GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogListEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogListEnvelope',
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
