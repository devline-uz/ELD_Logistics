// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_logs_dto_log_edit_request_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope {
  @override
  final BuiltList<
      GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequest>? data;
  @override
  final GithubComDevlineOnebookEldInternalDomainLogsDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope,
            GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope?
      _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequest>?
      _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequest>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequest>();
  set data(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequest>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainLogsDtoMetaBuilder? _meta;
  GithubComDevlineOnebookEldInternalDomainLogsDtoMetaBuilder get meta =>
      _$this._meta ??=
          GithubComDevlineOnebookEldInternalDomainLogsDtoMetaBuilder();
  set meta(GithubComDevlineOnebookEldInternalDomainLogsDtoMetaBuilder? meta) =>
      _$this._meta = meta;

  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope',
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
