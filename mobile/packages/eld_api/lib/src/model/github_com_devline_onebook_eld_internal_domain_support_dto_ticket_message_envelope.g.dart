// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_support_dto_ticket_message_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageEnvelope
    extends GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessage? data;

  factory _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageEnvelope,
            GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageEnvelope?
      _$v;

  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageBuilder
      get data => _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageEnvelope',
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
