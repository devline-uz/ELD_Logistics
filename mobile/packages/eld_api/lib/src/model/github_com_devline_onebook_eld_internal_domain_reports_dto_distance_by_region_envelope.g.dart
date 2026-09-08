// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_reports_dto_distance_by_region_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope
    extends GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope {
  @override
  final BuiltList<
          GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow>?
      data;
  @override
  final GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta?
      meta;

  factory _$GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope
      rebuild(
              void Function(
                      GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelopeBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope,
            GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope?
      _$v;

  ListBuilder<
          GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow>?
      _data;
  ListBuilder<
          GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow>();
  set data(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaBuilder?
      _meta;
  GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaBuilder
      get meta => _$this._meta ??=
          GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaBuilder();
  set meta(
          GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaBuilder?
              meta) =>
      _$this._meta = meta;

  GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope',
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
