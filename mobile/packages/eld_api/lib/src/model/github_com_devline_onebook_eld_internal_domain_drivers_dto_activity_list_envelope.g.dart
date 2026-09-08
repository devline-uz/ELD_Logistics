// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_drivers_dto_activity_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainDriversDtoActivityListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainDriversDtoActivityListEnvelope {
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainDriversDtoActivity>?
      data;
  @override
  final GithubComDevlineOnebookEldInternalDomainDriversDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainDriversDtoActivityListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDriversDtoActivityListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDriversDtoActivityListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDriversDtoActivityListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoActivityListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDriversDtoActivityListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoActivityListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainDriversDtoActivityListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainDriversDtoActivityListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainDriversDtoActivityListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDriversDtoActivityListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainDriversDtoActivityListEnvelope,
            GithubComDevlineOnebookEldInternalDomainDriversDtoActivityListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDriversDtoActivityListEnvelope? _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainDriversDtoActivity>?
      _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainDriversDtoActivity>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainDriversDtoActivity>();
  set data(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainDriversDtoActivity>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainDriversDtoMetaBuilder? _meta;
  GithubComDevlineOnebookEldInternalDomainDriversDtoMetaBuilder get meta =>
      _$this._meta ??=
          GithubComDevlineOnebookEldInternalDomainDriversDtoMetaBuilder();
  set meta(
          GithubComDevlineOnebookEldInternalDomainDriversDtoMetaBuilder?
              meta) =>
      _$this._meta = meta;

  GithubComDevlineOnebookEldInternalDomainDriversDtoActivityListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainDriversDtoActivityListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainDriversDtoActivityListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainDriversDtoActivityListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainDriversDtoActivityListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDriversDtoActivityListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoActivityListEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainDriversDtoActivityListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainDriversDtoActivityListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainDriversDtoActivityListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainDriversDtoActivityListEnvelope',
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
