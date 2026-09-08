// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_chat_dto_message_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope {
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainChatDtoMessage>? data;
  @override
  final GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope,
            GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope? _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainChatDtoMessage>? _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainChatDtoMessage>
      get data => _$this._data ??=
          ListBuilder<GithubComDevlineOnebookEldInternalDomainChatDtoMessage>();
  set data(
          ListBuilder<GithubComDevlineOnebookEldInternalDomainChatDtoMessage>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainChatDtoCursorMetaBuilder? _meta;
  GithubComDevlineOnebookEldInternalDomainChatDtoCursorMetaBuilder get meta =>
      _$this._meta ??=
          GithubComDevlineOnebookEldInternalDomainChatDtoCursorMetaBuilder();
  set meta(
          GithubComDevlineOnebookEldInternalDomainChatDtoCursorMetaBuilder?
              meta) =>
      _$this._meta = meta;

  GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope',
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
