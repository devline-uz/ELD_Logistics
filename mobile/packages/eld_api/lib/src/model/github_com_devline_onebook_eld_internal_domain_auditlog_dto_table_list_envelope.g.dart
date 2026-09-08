// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_auditlog_dto_table_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope {
  @override
  final BuiltList<String>? data;

  factory _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope,
            GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope? _$v;

  ListBuilder<String>? _data;
  ListBuilder<String> get data => _$this._data ??= ListBuilder<String>();
  set data(ListBuilder<String>? data) => _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope',
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
