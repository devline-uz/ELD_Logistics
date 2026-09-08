// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_logs_dto_inspection_report_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportEnvelope
    extends GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReport? data;

  factory _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportEnvelope,
            GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportEnvelope?
      _$v;

  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportBuilder
      get data => _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportEnvelope',
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
