// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_support_dto_ticket.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum
    _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum_new_ =
    const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum._(
        'new_');
const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum
    _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum_inProgress =
    const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum._(
        'inProgress');
const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum
    _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum_resolved =
    const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum._(
        'resolved');
const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum
    _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum_closed =
    const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum._(
        'closed');
const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum
    _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum._(
        'unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum
    _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnumValueOf(
        String name) {
  switch (name) {
    case 'new_':
      return _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum_new_;
    case 'inProgress':
      return _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum_inProgress;
    case 'resolved':
      return _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum_resolved;
    case 'closed':
      return _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum_closed;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum>(const <GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum>[
  _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum_new_,
  _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum_inProgress,
  _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum_resolved,
  _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum_closed,
  _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum_unknownDefaultOpenApi,
]);

Serializer<GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'new_': 'new',
    'inProgress': 'in_progress',
    'resolved': 'resolved',
    'closed': 'closed',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'new': 'new_',
    'in_progress': 'inProgress',
    'resolved': 'resolved',
    'closed': 'closed',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicket
    extends GithubComDevlineOnebookEldInternalDomainSupportDtoTicket {
  @override
  final BuiltList<String>? attachments;
  @override
  final String? contactOn;
  @override
  final DateTime? createdAt;
  @override
  final String? createdBy;
  @override
  final String? creatorName;
  @override
  final String? description;
  @override
  final String? driverId;
  @override
  final String? driverName;
  @override
  final String? id;
  @override
  final int? messageCount;
  @override
  final DateTime? resolvedAt;
  @override
  final GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum?
      status;
  @override
  final String? subject;
  @override
  final DateTime? updatedAt;

  factory _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicket(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainSupportDtoTicketBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicket._(
      {this.attachments,
      this.contactOn,
      this.createdAt,
      this.createdBy,
      this.creatorName,
      this.description,
      this.driverId,
      this.driverName,
      this.id,
      this.messageCount,
      this.resolvedAt,
      this.status,
      this.subject,
      this.updatedAt})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicket rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketBuilder toBuilder() =>
      GithubComDevlineOnebookEldInternalDomainSupportDtoTicketBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainSupportDtoTicket &&
        attachments == other.attachments &&
        contactOn == other.contactOn &&
        createdAt == other.createdAt &&
        createdBy == other.createdBy &&
        creatorName == other.creatorName &&
        description == other.description &&
        driverId == other.driverId &&
        driverName == other.driverName &&
        id == other.id &&
        messageCount == other.messageCount &&
        resolvedAt == other.resolvedAt &&
        status == other.status &&
        subject == other.subject &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, attachments.hashCode);
    _$hash = $jc(_$hash, contactOn.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, createdBy.hashCode);
    _$hash = $jc(_$hash, creatorName.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, driverName.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, messageCount.hashCode);
    _$hash = $jc(_$hash, resolvedAt.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, subject.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainSupportDtoTicket')
          ..add('attachments', attachments)
          ..add('contactOn', contactOn)
          ..add('createdAt', createdAt)
          ..add('createdBy', createdBy)
          ..add('creatorName', creatorName)
          ..add('description', description)
          ..add('driverId', driverId)
          ..add('driverName', driverName)
          ..add('id', id)
          ..add('messageCount', messageCount)
          ..add('resolvedAt', resolvedAt)
          ..add('status', status)
          ..add('subject', subject)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainSupportDtoTicketBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainSupportDtoTicket,
            GithubComDevlineOnebookEldInternalDomainSupportDtoTicketBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicket? _$v;

  ListBuilder<String>? _attachments;
  ListBuilder<String> get attachments =>
      _$this._attachments ??= ListBuilder<String>();
  set attachments(ListBuilder<String>? attachments) =>
      _$this._attachments = attachments;

  String? _contactOn;
  String? get contactOn => _$this._contactOn;
  set contactOn(String? contactOn) => _$this._contactOn = contactOn;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _createdBy;
  String? get createdBy => _$this._createdBy;
  set createdBy(String? createdBy) => _$this._createdBy = createdBy;

  String? _creatorName;
  String? get creatorName => _$this._creatorName;
  set creatorName(String? creatorName) => _$this._creatorName = creatorName;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  String? _driverName;
  String? get driverName => _$this._driverName;
  set driverName(String? driverName) => _$this._driverName = driverName;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  int? _messageCount;
  int? get messageCount => _$this._messageCount;
  set messageCount(int? messageCount) => _$this._messageCount = messageCount;

  DateTime? _resolvedAt;
  DateTime? get resolvedAt => _$this._resolvedAt;
  set resolvedAt(DateTime? resolvedAt) => _$this._resolvedAt = resolvedAt;

  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum? _status;
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum?
      get status => _$this._status;
  set status(
          GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum?
              status) =>
      _$this._status = status;

  String? _subject;
  String? get subject => _$this._subject;
  set subject(String? subject) => _$this._subject = subject;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketBuilder() {
    GithubComDevlineOnebookEldInternalDomainSupportDtoTicket._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _attachments = $v.attachments?.toBuilder();
      _contactOn = $v.contactOn;
      _createdAt = $v.createdAt;
      _createdBy = $v.createdBy;
      _creatorName = $v.creatorName;
      _description = $v.description;
      _driverId = $v.driverId;
      _driverName = $v.driverName;
      _id = $v.id;
      _messageCount = $v.messageCount;
      _resolvedAt = $v.resolvedAt;
      _status = $v.status;
      _subject = $v.subject;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GithubComDevlineOnebookEldInternalDomainSupportDtoTicket other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicket;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainSupportDtoTicketBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicket build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicket _build() {
    _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicket _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicket._(
            attachments: _attachments?.build(),
            contactOn: contactOn,
            createdAt: createdAt,
            createdBy: createdBy,
            creatorName: creatorName,
            description: description,
            driverId: driverId,
            driverName: driverName,
            id: id,
            messageCount: messageCount,
            resolvedAt: resolvedAt,
            status: status,
            subject: subject,
            updatedAt: updatedAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'attachments';
        _attachments?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainSupportDtoTicket',
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
