// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_logs_dto_log_edit_request_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate
    extends GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate {
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChange>
      changes;
  @override
  final String dailyLogId;
  @override
  final String driverId;

  factory _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreateBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreateBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate._(
      {required this.changes, required this.dailyLogId, required this.driverId})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreateBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreateBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreateBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate &&
        changes == other.changes &&
        dailyLogId == other.dailyLogId &&
        driverId == other.driverId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, changes.hashCode);
    _$hash = $jc(_$hash, dailyLogId.hashCode);
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate')
          ..add('changes', changes)
          ..add('dailyLogId', dailyLogId)
          ..add('driverId', driverId))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreateBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate,
            GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreateBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate? _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChange>?
      _changes;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChange>
      get changes => _$this._changes ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChange>();
  set changes(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChange>?
              changes) =>
      _$this._changes = changes;

  String? _dailyLogId;
  String? get dailyLogId => _$this._dailyLogId;
  set dailyLogId(String? dailyLogId) => _$this._dailyLogId = dailyLogId;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreateBuilder() {
    GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreateBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _changes = $v.changes.toBuilder();
      _dailyLogId = $v.dailyLogId;
      _driverId = $v.driverId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreateBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate
              ._(
            changes: changes.build(),
            dailyLogId: BuiltValueNullFieldError.checkNotNull(
                dailyLogId,
                r'GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate',
                'dailyLogId'),
            driverId: BuiltValueNullFieldError.checkNotNull(
                driverId,
                r'GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate',
                'driverId'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'changes';
        changes.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate',
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
