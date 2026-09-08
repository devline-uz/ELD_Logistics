// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_logs_dto_daily_log_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope {
  @override
  final BuiltList<
      GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummary>? data;
  @override
  final GithubComDevlineOnebookEldInternalDomainLogsDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope,
            GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope? _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummary>?
      _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummary>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummary>();
  set data(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummary>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainLogsDtoMetaBuilder? _meta;
  GithubComDevlineOnebookEldInternalDomainLogsDtoMetaBuilder get meta =>
      _$this._meta ??=
          GithubComDevlineOnebookEldInternalDomainLogsDtoMetaBuilder();
  set meta(GithubComDevlineOnebookEldInternalDomainLogsDtoMetaBuilder? meta) =>
      _$this._meta = meta;

  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope',
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
