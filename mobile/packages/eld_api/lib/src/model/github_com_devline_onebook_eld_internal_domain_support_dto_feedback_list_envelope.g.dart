// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_support_dto_feedback_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope {
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback>?
      data;
  @override
  final GithubComDevlineOnebookEldInternalDomainSupportDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope,
            GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope? _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback>?
      _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback>();
  set data(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainSupportDtoMetaBuilder? _meta;
  GithubComDevlineOnebookEldInternalDomainSupportDtoMetaBuilder get meta =>
      _$this._meta ??=
          GithubComDevlineOnebookEldInternalDomainSupportDtoMetaBuilder();
  set meta(
          GithubComDevlineOnebookEldInternalDomainSupportDtoMetaBuilder?
              meta) =>
      _$this._meta = meta;

  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope',
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
