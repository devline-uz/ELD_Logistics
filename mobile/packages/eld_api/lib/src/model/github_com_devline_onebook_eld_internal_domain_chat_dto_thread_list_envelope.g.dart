// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_chat_dto_thread_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope {
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainChatDtoThread>? data;
  @override
  final GithubComDevlineOnebookEldInternalDomainChatDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope,
            GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope? _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainChatDtoThread>? _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainChatDtoThread> get data =>
      _$this._data ??=
          ListBuilder<GithubComDevlineOnebookEldInternalDomainChatDtoThread>();
  set data(
          ListBuilder<GithubComDevlineOnebookEldInternalDomainChatDtoThread>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainChatDtoMetaBuilder? _meta;
  GithubComDevlineOnebookEldInternalDomainChatDtoMetaBuilder get meta =>
      _$this._meta ??=
          GithubComDevlineOnebookEldInternalDomainChatDtoMetaBuilder();
  set meta(GithubComDevlineOnebookEldInternalDomainChatDtoMetaBuilder? meta) =>
      _$this._meta = meta;

  GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope._(
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
            r'GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope',
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
