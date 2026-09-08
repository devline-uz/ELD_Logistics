// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_logs_dto_daily_log_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelope
    extends GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail? data;

  factory _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelopeBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelope,
            GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailBuilder
      get data => _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelope other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelope _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelope._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelope',
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
