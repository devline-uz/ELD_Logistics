// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_support_dto_ticket_status_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum
    _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum_new_ =
    const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum
        ._('new_');
const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum
    _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum_inProgress =
    const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum
        ._('inProgress');
const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum
    _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum_resolved =
    const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum
        ._('resolved');
const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum
    _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum
    _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnumValueOf(
        String name) {
  switch (name) {
    case 'new_':
      return _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum_new_;
    case 'inProgress':
      return _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum_inProgress;
    case 'resolved':
      return _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum_resolved;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum>(const <GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum>[
  _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum_new_,
  _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum_inProgress,
  _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum_resolved,
  _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'new_': 'new',
    'inProgress': 'in_progress',
    'resolved': 'resolved',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'new': 'new_',
    'in_progress': 'inProgress',
    'resolved': 'resolved',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate
    extends GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate {
  @override
  final GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum
      status;

  factory _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate._(
      {required this.status})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate')
          ..add('status', status))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate,
            GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate? _$v;

  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum?
      _status;
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum?
      get status => _$this._status;
  set status(
          GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum?
              status) =>
      _$this._status = status;

  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateBuilder() {
    GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate
      _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate
            ._(
          status: BuiltValueNullFieldError.checkNotNull(
              status,
              r'GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate',
              'status'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
