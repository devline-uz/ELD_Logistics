// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_routes_dto_route_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope {
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainRoutesDtoRoute>? data;
  @override
  final GithubComDevlineOnebookEldInternalDomainRoutesDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope,
            GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope? _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainRoutesDtoRoute>? _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainRoutesDtoRoute>
      get data => _$this._data ??=
          ListBuilder<GithubComDevlineOnebookEldInternalDomainRoutesDtoRoute>();
  set data(
          ListBuilder<GithubComDevlineOnebookEldInternalDomainRoutesDtoRoute>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainRoutesDtoMetaBuilder? _meta;
  GithubComDevlineOnebookEldInternalDomainRoutesDtoMetaBuilder get meta =>
      _$this._meta ??=
          GithubComDevlineOnebookEldInternalDomainRoutesDtoMetaBuilder();
  set meta(
          GithubComDevlineOnebookEldInternalDomainRoutesDtoMetaBuilder? meta) =>
      _$this._meta = meta;

  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope',
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
