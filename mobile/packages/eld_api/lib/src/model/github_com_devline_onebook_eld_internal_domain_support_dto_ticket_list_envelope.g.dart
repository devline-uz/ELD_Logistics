// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_support_dto_ticket_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainSupportDtoTicketListEnvelope {
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainSupportDtoTicket>?
      data;
  @override
  final GithubComDevlineOnebookEldInternalDomainSupportDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainSupportDtoTicketListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainSupportDtoTicketListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainSupportDtoTicketListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainSupportDtoTicketListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainSupportDtoTicketListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainSupportDtoTicketListEnvelope,
            GithubComDevlineOnebookEldInternalDomainSupportDtoTicketListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketListEnvelope? _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainSupportDtoTicket>? _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainSupportDtoTicket>
      get data => _$this._data ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainSupportDtoTicket>();
  set data(
          ListBuilder<GithubComDevlineOnebookEldInternalDomainSupportDtoTicket>?
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

  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainSupportDtoTicketListEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainSupportDtoTicketListEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainSupportDtoTicketListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketListEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketListEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketListEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketListEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainSupportDtoTicketListEnvelope',
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
