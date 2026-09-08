// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_support_dto_ticket_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketEnvelope
    extends GithubComDevlineOnebookEldInternalDomainSupportDtoTicketEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainSupportDtoTicket? data;

  factory _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainSupportDtoTicketEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainSupportDtoTicketEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainSupportDtoTicketEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainSupportDtoTicketEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainSupportDtoTicketEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainSupportDtoTicketEnvelope,
            GithubComDevlineOnebookEldInternalDomainSupportDtoTicketEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainSupportDtoTicketBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainSupportDtoTicketBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainSupportDtoTicketEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainSupportDtoTicketEnvelope other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainSupportDtoTicketEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketEnvelope _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketEnvelope._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainSupportDtoTicketEnvelope',
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
