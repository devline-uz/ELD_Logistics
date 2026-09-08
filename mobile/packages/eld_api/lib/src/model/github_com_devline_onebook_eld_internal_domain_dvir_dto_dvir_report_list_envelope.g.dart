// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_dvir_dto_dvir_report_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelope {
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReport>?
      data;
  @override
  final GithubComDevlineOnebookEldInternalDomainDvirDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelope,
            GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelope? _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReport>? _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReport>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReport>();
  set data(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReport>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainDvirDtoMetaBuilder? _meta;
  GithubComDevlineOnebookEldInternalDomainDvirDtoMetaBuilder get meta =>
      _$this._meta ??=
          GithubComDevlineOnebookEldInternalDomainDvirDtoMetaBuilder();
  set meta(GithubComDevlineOnebookEldInternalDomainDvirDtoMetaBuilder? meta) =>
      _$this._meta = meta;

  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelope',
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
