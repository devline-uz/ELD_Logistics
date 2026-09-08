// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_support_dto_feedback_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope
    extends GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback? data;

  factory _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope,
            GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope',
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
