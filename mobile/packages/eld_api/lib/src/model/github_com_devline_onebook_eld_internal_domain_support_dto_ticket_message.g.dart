// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_support_dto_ticket_message.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessage
    extends GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessage {
  @override
  final BuiltList<String>? attachments;
  @override
  final DateTime? createdAt;
  @override
  final String? id;
  @override
  final String? senderId;
  @override
  final String? senderName;
  @override
  final String? text;
  @override
  final String? ticketId;

  factory _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessage(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessage._(
      {this.attachments,
      this.createdAt,
      this.id,
      this.senderId,
      this.senderName,
      this.text,
      this.ticketId})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessage rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessage &&
        attachments == other.attachments &&
        createdAt == other.createdAt &&
        id == other.id &&
        senderId == other.senderId &&
        senderName == other.senderName &&
        text == other.text &&
        ticketId == other.ticketId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, attachments.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, senderId.hashCode);
    _$hash = $jc(_$hash, senderName.hashCode);
    _$hash = $jc(_$hash, text.hashCode);
    _$hash = $jc(_$hash, ticketId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessage')
          ..add('attachments', attachments)
          ..add('createdAt', createdAt)
          ..add('id', id)
          ..add('senderId', senderId)
          ..add('senderName', senderName)
          ..add('text', text)
          ..add('ticketId', ticketId))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessage,
            GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessage? _$v;

  ListBuilder<String>? _attachments;
  ListBuilder<String> get attachments =>
      _$this._attachments ??= ListBuilder<String>();
  set attachments(ListBuilder<String>? attachments) =>
      _$this._attachments = attachments;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _senderId;
  String? get senderId => _$this._senderId;
  set senderId(String? senderId) => _$this._senderId = senderId;

  String? _senderName;
  String? get senderName => _$this._senderName;
  set senderName(String? senderName) => _$this._senderName = senderName;

  String? _text;
  String? get text => _$this._text;
  set text(String? text) => _$this._text = text;

  String? _ticketId;
  String? get ticketId => _$this._ticketId;
  set ticketId(String? ticketId) => _$this._ticketId = ticketId;

  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageBuilder() {
    GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessage._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _attachments = $v.attachments?.toBuilder();
      _createdAt = $v.createdAt;
      _id = $v.id;
      _senderId = $v.senderId;
      _senderName = $v.senderName;
      _text = $v.text;
      _ticketId = $v.ticketId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessage other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessage;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessage build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessage _build() {
    _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessage _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessage._(
            attachments: _attachments?.build(),
            createdAt: createdAt,
            id: id,
            senderId: senderId,
            senderName: senderName,
            text: text,
            ticketId: ticketId,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'attachments';
        _attachments?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessage',
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
