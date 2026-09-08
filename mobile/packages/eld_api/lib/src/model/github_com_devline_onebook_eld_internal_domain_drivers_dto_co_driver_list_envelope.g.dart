// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_drivers_dto_co_driver_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope {
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver>?
      data;
  @override
  final GithubComDevlineOnebookEldInternalDomainDriversDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope,
            GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope? _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver>?
      _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver>();
  set data(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver>?
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

  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope',
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
