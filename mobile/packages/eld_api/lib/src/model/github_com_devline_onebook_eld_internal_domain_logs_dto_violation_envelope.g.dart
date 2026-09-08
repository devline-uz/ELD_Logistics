// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_logs_dto_violation_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolationEnvelope
    extends GithubComDevlineOnebookEldInternalDomainLogsDtoViolationEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainLogsDtoViolation? data;

  factory _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolationEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoViolationEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainLogsDtoViolationEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolationEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoViolationEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoViolationEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoViolationEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainLogsDtoViolationEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainLogsDtoViolationEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoViolationEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoViolationEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainLogsDtoViolationEnvelope,
            GithubComDevlineOnebookEldInternalDomainLogsDtoViolationEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolationEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainLogsDtoViolationBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainLogsDtoViolationBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainLogsDtoViolationBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainLogsDtoViolationBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainLogsDtoViolationEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainLogsDtoViolationEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainLogsDtoViolationEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainLogsDtoViolationEnvelope other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolationEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainLogsDtoViolationEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoViolationEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolationEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolationEnvelope _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolationEnvelope._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoViolationEnvelope',
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
