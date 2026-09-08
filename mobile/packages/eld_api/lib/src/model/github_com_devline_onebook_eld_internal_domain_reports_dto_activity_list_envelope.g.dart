// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_reports_dto_activity_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope {
  @override
  final BuiltList<
      GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow>? data;
  @override
  final GithubComDevlineOnebookEldInternalDomainReportsDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope,
            GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope? _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow>?
      _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow>();
  set data(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow>?
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

  GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope',
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
