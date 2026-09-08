// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_reports_dto_export_job_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope
    extends GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainReportsDtoExportJob? data;

  factory _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope &&
        data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope,
            GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelopeBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope
              ._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope',
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
