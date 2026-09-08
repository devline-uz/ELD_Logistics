// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_reports_dto_export_job_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope {
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainReportsDtoExportJob>?
      data;
  @override
  final GithubComDevlineOnebookEldInternalDomainReportsDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope,
            GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope?
      _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainReportsDtoExportJob>?
      _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainReportsDtoExportJob>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainReportsDtoExportJob>();
  set data(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJob>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainReportsDtoMetaBuilder? _meta;
  GithubComDevlineOnebookEldInternalDomainReportsDtoMetaBuilder get meta =>
      _$this._meta ??=
          GithubComDevlineOnebookEldInternalDomainReportsDtoMetaBuilder();
  set meta(
          GithubComDevlineOnebookEldInternalDomainReportsDtoMetaBuilder?
              meta) =>
      _$this._meta = meta;

  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope',
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
