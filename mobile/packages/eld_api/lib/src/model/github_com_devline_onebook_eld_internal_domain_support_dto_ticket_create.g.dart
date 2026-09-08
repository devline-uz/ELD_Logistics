// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_support_dto_ticket_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum
    _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum_email =
    const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum
        ._('email');
const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum
    _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum_phone =
    const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum
        ._('phone');
const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum
    _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum_sms =
    const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum
        ._('sms');
const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum
    _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum_inApp =
    const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum
        ._('inApp');
const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum
    _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum
    _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnumValueOf(
        String name) {
  switch (name) {
    case 'email':
      return _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum_email;
    case 'phone':
      return _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum_phone;
    case 'sms':
      return _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum_sms;
    case 'inApp':
      return _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum_inApp;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum>
    _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum>(const <GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum>[
  _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum_email,
  _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum_phone,
  _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum_sms,
  _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum_inApp,
  _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum>
    _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'email': 'email',
    'phone': 'phone',
    'sms': 'sms',
    'inApp': 'in_app',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'email': 'email',
    'phone': 'phone',
    'sms': 'sms',
    'in_app': 'inApp',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate
    extends GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate {
  @override
  final BuiltList<String> attachments;
  @override
  final GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum?
      contactOn;
  @override
  final String? description;
  @override
  final String subject;

  factory _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate._(
      {required this.attachments,
      this.contactOn,
      this.description,
      required this.subject})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate &&
        attachments == other.attachments &&
        contactOn == other.contactOn &&
        description == other.description &&
        subject == other.subject;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, attachments.hashCode);
    _$hash = $jc(_$hash, contactOn.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, subject.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate')
          ..add('attachments', attachments)
          ..add('contactOn', contactOn)
          ..add('description', description)
          ..add('subject', subject))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate,
            GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate? _$v;

  ListBuilder<String>? _attachments;
  ListBuilder<String> get attachments =>
      _$this._attachments ??= ListBuilder<String>();
  set attachments(ListBuilder<String>? attachments) =>
      _$this._attachments = attachments;

  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum?
      _contactOn;
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum?
      get contactOn => _$this._contactOn;
  set contactOn(
          GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum?
              contactOn) =>
      _$this._contactOn = contactOn;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  String? _subject;
  String? get subject => _$this._subject;
  set subject(String? subject) => _$this._subject = subject;

  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateBuilder() {
    GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _attachments = $v.attachments.toBuilder();
      _contactOn = $v.contactOn;
      _description = $v.description;
      _subject = $v.subject;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate _build() {
    _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate._(
            attachments: attachments.build(),
            contactOn: contactOn,
            description: description,
            subject: BuiltValueNullFieldError.checkNotNull(
                subject,
                r'GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate',
                'subject'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'attachments';
        attachments.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate',
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
