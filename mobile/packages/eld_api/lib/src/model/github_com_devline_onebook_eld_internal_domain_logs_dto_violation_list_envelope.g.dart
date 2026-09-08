// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_logs_dto_violation_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolationListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainLogsDtoViolationListEnvelope {
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainLogsDtoViolation>?
      data;
  @override
  final GithubComDevlineOnebookEldInternalDomainLogsDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolationListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoViolationListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainLogsDtoViolationListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolationListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoViolationListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoViolationListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoViolationListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainLogsDtoViolationListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainLogsDtoViolationListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoViolationListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoViolationListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainLogsDtoViolationListEnvelope,
            GithubComDevlineOnebookEldInternalDomainLogsDtoViolationListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolationListEnvelope? _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainLogsDtoViolation>? _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainLogsDtoViolation>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainLogsDtoViolation>();
  set data(
          ListBuilder<GithubComDevlineOnebookEldInternalDomainLogsDtoViolation>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainLogsDtoMetaBuilder? _meta;
  GithubComDevlineOnebookEldInternalDomainLogsDtoMetaBuilder get meta =>
      _$this._meta ??=
          GithubComDevlineOnebookEldInternalDomainLogsDtoMetaBuilder();
  set meta(GithubComDevlineOnebookEldInternalDomainLogsDtoMetaBuilder? meta) =>
      _$this._meta = meta;

  GithubComDevlineOnebookEldInternalDomainLogsDtoViolationListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainLogsDtoViolationListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainLogsDtoViolationListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainLogsDtoViolationListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolationListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainLogsDtoViolationListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoViolationListEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolationListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolationListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolationListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoViolationListEnvelope',
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
