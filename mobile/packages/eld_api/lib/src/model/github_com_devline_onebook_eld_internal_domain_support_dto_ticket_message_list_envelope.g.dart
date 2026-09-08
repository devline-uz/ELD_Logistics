// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_support_dto_ticket_message_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope {
  @override
  final BuiltList<
      GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessage>? data;
  @override
  final GithubComDevlineOnebookEldInternalDomainSupportDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope
      rebuild(
              void Function(
                      GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelopeBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope,
            GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope?
      _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessage>?
      _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessage>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessage>();
  set data(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessage>?
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

  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope',
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
