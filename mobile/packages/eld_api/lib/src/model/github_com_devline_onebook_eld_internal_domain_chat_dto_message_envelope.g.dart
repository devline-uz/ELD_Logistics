// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_chat_dto_message_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope
    extends GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainChatDtoMessage? data;

  factory _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelopeBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope,
            GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainChatDtoMessageBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainChatDtoMessageBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainChatDtoMessageBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainChatDtoMessageBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope',
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
