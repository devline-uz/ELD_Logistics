// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_duty_dto_hos_summary_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope
    extends GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary? data;

  factory _$GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope,
            GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope',
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
