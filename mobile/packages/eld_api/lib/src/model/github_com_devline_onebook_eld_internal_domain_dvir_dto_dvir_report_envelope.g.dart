// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_dvir_dto_dvir_report_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope
    extends GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReport? data;

  factory _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope,
            GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope',
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
