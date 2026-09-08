// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_company_dto_history_entry.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum
    _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum_create =
    const GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum
        ._('create');
const GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum
    _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum_update =
    const GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum
        ._('update');
const GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum
    _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum_delete =
    const GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum
        ._('delete');
const GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum
    _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum_softDelete =
    const GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum
        ._('softDelete');
const GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum
    _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum_hosPolicyChange =
    const GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum
        ._('hosPolicyChange');
const GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum
    _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum_subscriptionChange =
    const GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum
        ._('subscriptionChange');
const GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum
    _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum
    _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnumValueOf(
        String name) {
  switch (name) {
    case 'create':
      return _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum_create;
    case 'update':
      return _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum_update;
    case 'delete':
      return _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum_delete;
    case 'softDelete':
      return _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum_softDelete;
    case 'hosPolicyChange':
      return _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum_hosPolicyChange;
    case 'subscriptionChange':
      return _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum_subscriptionChange;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum>
    _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum>(const <GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum>[
  _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum_create,
  _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum_update,
  _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum_delete,
  _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum_softDelete,
  _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum_hosPolicyChange,
  _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum_subscriptionChange,
  _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum>
    _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'create': 'create',
    'update': 'update',
    'delete': 'delete',
    'softDelete': 'soft_delete',
    'hosPolicyChange': 'hos_policy_change',
    'subscriptionChange': 'subscription_change',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'create': 'create',
    'update': 'update',
    'delete': 'delete',
    'soft_delete': 'softDelete',
    'hos_policy_change': 'hosPolicyChange',
    'subscription_change': 'subscriptionChange',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry
    extends GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry {
  @override
  final GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum?
      action;
  @override
  final String? editedBy;
  @override
  final String? editedByName;
  @override
  final String? field;
  @override
  final String? id;
  @override
  final String? newValue;
  @override
  final String? oldValue;
  @override
  final String? recordId;
  @override
  final String? tableName;
  @override
  final DateTime? ts;

  factory _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry._(
      {this.action,
      this.editedBy,
      this.editedByName,
      this.field,
      this.id,
      this.newValue,
      this.oldValue,
      this.recordId,
      this.tableName,
      this.ts})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry &&
        action == other.action &&
        editedBy == other.editedBy &&
        editedByName == other.editedByName &&
        field == other.field &&
        id == other.id &&
        newValue == other.newValue &&
        oldValue == other.oldValue &&
        recordId == other.recordId &&
        tableName == other.tableName &&
        ts == other.ts;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, editedBy.hashCode);
    _$hash = $jc(_$hash, editedByName.hashCode);
    _$hash = $jc(_$hash, field.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, newValue.hashCode);
    _$hash = $jc(_$hash, oldValue.hashCode);
    _$hash = $jc(_$hash, recordId.hashCode);
    _$hash = $jc(_$hash, tableName.hashCode);
    _$hash = $jc(_$hash, ts.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry')
          ..add('action', action)
          ..add('editedBy', editedBy)
          ..add('editedByName', editedByName)
          ..add('field', field)
          ..add('id', id)
          ..add('newValue', newValue)
          ..add('oldValue', oldValue)
          ..add('recordId', recordId)
          ..add('tableName', tableName)
          ..add('ts', ts))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry,
            GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry? _$v;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum?
      _action;
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum?
      get action => _$this._action;
  set action(
          GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum?
              action) =>
      _$this._action = action;

  String? _editedBy;
  String? get editedBy => _$this._editedBy;
  set editedBy(String? editedBy) => _$this._editedBy = editedBy;

  String? _editedByName;
  String? get editedByName => _$this._editedByName;
  set editedByName(String? editedByName) => _$this._editedByName = editedByName;

  String? _field;
  String? get field => _$this._field;
  set field(String? field) => _$this._field = field;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _newValue;
  String? get newValue => _$this._newValue;
  set newValue(String? newValue) => _$this._newValue = newValue;

  String? _oldValue;
  String? get oldValue => _$this._oldValue;
  set oldValue(String? oldValue) => _$this._oldValue = oldValue;

  String? _recordId;
  String? get recordId => _$this._recordId;
  set recordId(String? recordId) => _$this._recordId = recordId;

  String? _tableName;
  String? get tableName => _$this._tableName;
  set tableName(String? tableName) => _$this._tableName = tableName;

  DateTime? _ts;
  DateTime? get ts => _$this._ts;
  set ts(DateTime? ts) => _$this._ts = ts;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryBuilder() {
    GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _action = $v.action;
      _editedBy = $v.editedBy;
      _editedByName = $v.editedByName;
      _field = $v.field;
      _id = $v.id;
      _newValue = $v.newValue;
      _oldValue = $v.oldValue;
      _recordId = $v.recordId;
      _tableName = $v.tableName;
      _ts = $v.ts;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry._(
          action: action,
          editedBy: editedBy,
          editedByName: editedByName,
          field: field,
          id: id,
          newValue: newValue,
          oldValue: oldValue,
          recordId: recordId,
          tableName: tableName,
          ts: ts,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
