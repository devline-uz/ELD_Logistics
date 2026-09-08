// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_duty_dto_duty_status_event_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope {
  @override
  final BuiltList<
      GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEvent>? data;
  @override
  final GithubComDevlineOnebookEldInternalDomainDutyDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope
      rebuild(
              void Function(
                      GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelopeBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope,
            GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope?
      _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEvent>?
      _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEvent>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEvent>();
  set data(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEvent>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainDutyDtoMetaBuilder? _meta;
  GithubComDevlineOnebookEldInternalDomainDutyDtoMetaBuilder get meta =>
      _$this._meta ??=
          GithubComDevlineOnebookEldInternalDomainDutyDtoMetaBuilder();
  set meta(GithubComDevlineOnebookEldInternalDomainDutyDtoMetaBuilder? meta) =>
      _$this._meta = meta;

  GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope',
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
