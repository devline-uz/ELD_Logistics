// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_company_dto_hos_policy_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope
    extends GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy? data;

  factory _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope,
            GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope',
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
