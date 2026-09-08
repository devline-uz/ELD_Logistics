// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_dashboard_dto_summary_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope
    extends GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainDashboardDtoSummary? data;

  factory _$GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope,
            GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope',
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
