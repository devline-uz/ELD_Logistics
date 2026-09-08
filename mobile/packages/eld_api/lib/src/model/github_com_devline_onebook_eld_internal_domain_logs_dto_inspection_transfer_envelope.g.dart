// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_logs_dto_inspection_transfer_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope
    extends GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResult?
      data;

  factory _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope,
            GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope?
      _$v;

  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultBuilder?
      _data;
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultBuilder
      get data => _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope',
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
