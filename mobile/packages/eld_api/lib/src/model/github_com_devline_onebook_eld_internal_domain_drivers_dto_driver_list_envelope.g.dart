// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_drivers_dto_driver_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainDriversDtoDriverListEnvelope {
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainDriversDtoDriver>?
      data;
  @override
  final GithubComDevlineOnebookEldInternalDomainDriversDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDriversDtoDriverListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainDriversDtoDriverListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainDriversDtoDriverListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainDriversDtoDriverListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDriversDtoDriverListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainDriversDtoDriverListEnvelope,
            GithubComDevlineOnebookEldInternalDomainDriversDtoDriverListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverListEnvelope? _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainDriversDtoDriver>? _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainDriversDtoDriver>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainDriversDtoDriver>();
  set data(
          ListBuilder<GithubComDevlineOnebookEldInternalDomainDriversDtoDriver>?
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

  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainDriversDtoDriverListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainDriversDtoDriverListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDriversDtoDriverListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverListEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainDriversDtoDriverListEnvelope',
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
