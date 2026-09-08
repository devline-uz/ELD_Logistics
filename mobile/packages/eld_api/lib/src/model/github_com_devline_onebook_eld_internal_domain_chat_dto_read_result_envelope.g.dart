// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_chat_dto_read_result_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainChatDtoReadResultEnvelope
    extends GithubComDevlineOnebookEldInternalDomainChatDtoReadResultEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainChatDtoReadResult? data;

  factory _$GithubComDevlineOnebookEldInternalDomainChatDtoReadResultEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainChatDtoReadResultEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainChatDtoReadResultEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainChatDtoReadResultEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoReadResultEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainChatDtoReadResultEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoReadResultEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainChatDtoReadResultEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainChatDtoReadResultEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainChatDtoReadResultEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainChatDtoReadResultEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainChatDtoReadResultEnvelope,
            GithubComDevlineOnebookEldInternalDomainChatDtoReadResultEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainChatDtoReadResultEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainChatDtoReadResultBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainChatDtoReadResultBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainChatDtoReadResultBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainChatDtoReadResultBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainChatDtoReadResultEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainChatDtoReadResultEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainChatDtoReadResultEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainChatDtoReadResultEnvelope other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainChatDtoReadResultEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainChatDtoReadResultEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoReadResultEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainChatDtoReadResultEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainChatDtoReadResultEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainChatDtoReadResultEnvelope._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainChatDtoReadResultEnvelope',
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
