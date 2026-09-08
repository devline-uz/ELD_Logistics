// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_companies_dto_company_created.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum
    _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum_email =
    const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum
        ._('email');
const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum
    _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum_sms =
    const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum
        ._('sms');
const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum
    _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum_telegram =
    const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum
        ._('telegram');
const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum
    _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum
    _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnumValueOf(
        String name) {
  switch (name) {
    case 'email':
      return _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum_email;
    case 'sms':
      return _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum_sms;
    case 'telegram':
      return _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum_telegram;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum>
    _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum>(const <GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum>[
  _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum_email,
  _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum_sms,
  _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum_telegram,
  _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum>
    _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'email': 'email',
    'sms': 'sms',
    'telegram': 'telegram',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'email': 'email',
    'sms': 'sms',
    'telegram': 'telegram',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated
    extends GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated {
  @override
  final String? administratorRoleId;
  @override
  final String? administratorUserId;
  @override
  final GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany? company;
  @override
  final GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum?
      invitationChannel;
  @override
  final DateTime? invitationExpiresAt;
  @override
  final int? rolesCreated;

  factory _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated._(
      {this.administratorRoleId,
      this.administratorUserId,
      this.company,
      this.invitationChannel,
      this.invitationExpiresAt,
      this.rolesCreated})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated &&
        administratorRoleId == other.administratorRoleId &&
        administratorUserId == other.administratorUserId &&
        company == other.company &&
        invitationChannel == other.invitationChannel &&
        invitationExpiresAt == other.invitationExpiresAt &&
        rolesCreated == other.rolesCreated;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, administratorRoleId.hashCode);
    _$hash = $jc(_$hash, administratorUserId.hashCode);
    _$hash = $jc(_$hash, company.hashCode);
    _$hash = $jc(_$hash, invitationChannel.hashCode);
    _$hash = $jc(_$hash, invitationExpiresAt.hashCode);
    _$hash = $jc(_$hash, rolesCreated.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated')
          ..add('administratorRoleId', administratorRoleId)
          ..add('administratorUserId', administratorUserId)
          ..add('company', company)
          ..add('invitationChannel', invitationChannel)
          ..add('invitationExpiresAt', invitationExpiresAt)
          ..add('rolesCreated', rolesCreated))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated,
            GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated? _$v;

  String? _administratorRoleId;
  String? get administratorRoleId => _$this._administratorRoleId;
  set administratorRoleId(String? administratorRoleId) =>
      _$this._administratorRoleId = administratorRoleId;

  String? _administratorUserId;
  String? get administratorUserId => _$this._administratorUserId;
  set administratorUserId(String? administratorUserId) =>
      _$this._administratorUserId = administratorUserId;

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyBuilder? _company;
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyBuilder
      get company => _$this._company ??=
          GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyBuilder();
  set company(
          GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyBuilder?
              company) =>
      _$this._company = company;

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum?
      _invitationChannel;
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum?
      get invitationChannel => _$this._invitationChannel;
  set invitationChannel(
          GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum?
              invitationChannel) =>
      _$this._invitationChannel = invitationChannel;

  DateTime? _invitationExpiresAt;
  DateTime? get invitationExpiresAt => _$this._invitationExpiresAt;
  set invitationExpiresAt(DateTime? invitationExpiresAt) =>
      _$this._invitationExpiresAt = invitationExpiresAt;

  int? _rolesCreated;
  int? get rolesCreated => _$this._rolesCreated;
  set rolesCreated(int? rolesCreated) => _$this._rolesCreated = rolesCreated;

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedBuilder() {
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _administratorRoleId = $v.administratorRoleId;
      _administratorUserId = $v.administratorUserId;
      _company = $v.company?.toBuilder();
      _invitationChannel = $v.invitationChannel;
      _invitationExpiresAt = $v.invitationExpiresAt;
      _rolesCreated = $v.rolesCreated;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated
              ._(
            administratorRoleId: administratorRoleId,
            administratorUserId: administratorUserId,
            company: _company?.build(),
            invitationChannel: invitationChannel,
            invitationExpiresAt: invitationExpiresAt,
            rolesCreated: rolesCreated,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'company';
        _company?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated',
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
