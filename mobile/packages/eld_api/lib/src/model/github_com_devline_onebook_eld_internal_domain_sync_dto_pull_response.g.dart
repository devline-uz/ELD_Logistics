// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_sync_dto_pull_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse
    extends GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse {
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage>?
      chat;
  @override
  final BuiltList<
          GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary>?
      dailyLogs;
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType>?
      defectTypes;
  @override
  final BuiltList<
      GithubComDevlineOnebookEldInternalDomainSyncDtoDutyStatusEvent>? events;
  @override
  final GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicy? hosPolicy;
  @override
  final BuiltList<
          GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequest>?
      logEditRequests;
  @override
  final DateTime? nextSince;
  @override
  final BuiltList<String>? quickNotes;
  @override
  final DateTime? serverTime;
  @override
  final bool? truncated;
  @override
  final BuiltList<
          GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent>?
      unidentifiedEvents;

  factory _$GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponseBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponseBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse._(
      {this.chat,
      this.dailyLogs,
      this.defectTypes,
      this.events,
      this.hosPolicy,
      this.logEditRequests,
      this.nextSince,
      this.quickNotes,
      this.serverTime,
      this.truncated,
      this.unidentifiedEvents})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponseBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponseBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse &&
        chat == other.chat &&
        dailyLogs == other.dailyLogs &&
        defectTypes == other.defectTypes &&
        events == other.events &&
        hosPolicy == other.hosPolicy &&
        logEditRequests == other.logEditRequests &&
        nextSince == other.nextSince &&
        quickNotes == other.quickNotes &&
        serverTime == other.serverTime &&
        truncated == other.truncated &&
        unidentifiedEvents == other.unidentifiedEvents;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, chat.hashCode);
    _$hash = $jc(_$hash, dailyLogs.hashCode);
    _$hash = $jc(_$hash, defectTypes.hashCode);
    _$hash = $jc(_$hash, events.hashCode);
    _$hash = $jc(_$hash, hosPolicy.hashCode);
    _$hash = $jc(_$hash, logEditRequests.hashCode);
    _$hash = $jc(_$hash, nextSince.hashCode);
    _$hash = $jc(_$hash, quickNotes.hashCode);
    _$hash = $jc(_$hash, serverTime.hashCode);
    _$hash = $jc(_$hash, truncated.hashCode);
    _$hash = $jc(_$hash, unidentifiedEvents.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse')
          ..add('chat', chat)
          ..add('dailyLogs', dailyLogs)
          ..add('defectTypes', defectTypes)
          ..add('events', events)
          ..add('hosPolicy', hosPolicy)
          ..add('logEditRequests', logEditRequests)
          ..add('nextSince', nextSince)
          ..add('quickNotes', quickNotes)
          ..add('serverTime', serverTime)
          ..add('truncated', truncated)
          ..add('unidentifiedEvents', unidentifiedEvents))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponseBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse,
            GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponseBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse? _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage>?
      _chat;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage>
      get chat => _$this._chat ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage>();
  set chat(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage>?
              chat) =>
      _$this._chat = chat;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary>?
      _dailyLogs;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary>
      get dailyLogs => _$this._dailyLogs ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary>();
  set dailyLogs(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary>?
              dailyLogs) =>
      _$this._dailyLogs = dailyLogs;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType>?
      _defectTypes;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType>
      get defectTypes => _$this._defectTypes ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType>();
  set defectTypes(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType>?
              defectTypes) =>
      _$this._defectTypes = defectTypes;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainSyncDtoDutyStatusEvent>?
      _events;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainSyncDtoDutyStatusEvent>
      get events => _$this._events ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainSyncDtoDutyStatusEvent>();
  set events(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainSyncDtoDutyStatusEvent>?
              events) =>
      _$this._events = events;

  GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBuilder? _hosPolicy;
  GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBuilder
      get hosPolicy => _$this._hosPolicy ??=
          GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBuilder();
  set hosPolicy(
          GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBuilder?
              hosPolicy) =>
      _$this._hosPolicy = hosPolicy;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequest>?
      _logEditRequests;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequest>
      get logEditRequests => _$this._logEditRequests ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequest>();
  set logEditRequests(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequest>?
              logEditRequests) =>
      _$this._logEditRequests = logEditRequests;

  DateTime? _nextSince;
  DateTime? get nextSince => _$this._nextSince;
  set nextSince(DateTime? nextSince) => _$this._nextSince = nextSince;

  ListBuilder<String>? _quickNotes;
  ListBuilder<String> get quickNotes =>
      _$this._quickNotes ??= ListBuilder<String>();
  set quickNotes(ListBuilder<String>? quickNotes) =>
      _$this._quickNotes = quickNotes;

  DateTime? _serverTime;
  DateTime? get serverTime => _$this._serverTime;
  set serverTime(DateTime? serverTime) => _$this._serverTime = serverTime;

  bool? _truncated;
  bool? get truncated => _$this._truncated;
  set truncated(bool? truncated) => _$this._truncated = truncated;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent>?
      _unidentifiedEvents;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent>
      get unidentifiedEvents => _$this._unidentifiedEvents ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent>();
  set unidentifiedEvents(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent>?
              unidentifiedEvents) =>
      _$this._unidentifiedEvents = unidentifiedEvents;

  GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponseBuilder() {
    GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponseBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _chat = $v.chat?.toBuilder();
      _dailyLogs = $v.dailyLogs?.toBuilder();
      _defectTypes = $v.defectTypes?.toBuilder();
      _events = $v.events?.toBuilder();
      _hosPolicy = $v.hosPolicy?.toBuilder();
      _logEditRequests = $v.logEditRequests?.toBuilder();
      _nextSince = $v.nextSince;
      _quickNotes = $v.quickNotes?.toBuilder();
      _serverTime = $v.serverTime;
      _truncated = $v.truncated;
      _unidentifiedEvents = $v.unidentifiedEvents?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse other) {
    _$v =
        other as _$GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse _build() {
    _$GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse._(
            chat: _chat?.build(),
            dailyLogs: _dailyLogs?.build(),
            defectTypes: _defectTypes?.build(),
            events: _events?.build(),
            hosPolicy: _hosPolicy?.build(),
            logEditRequests: _logEditRequests?.build(),
            nextSince: nextSince,
            quickNotes: _quickNotes?.build(),
            serverTime: serverTime,
            truncated: truncated,
            unidentifiedEvents: _unidentifiedEvents?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'chat';
        _chat?.build();
        _$failedField = 'dailyLogs';
        _dailyLogs?.build();
        _$failedField = 'defectTypes';
        _defectTypes?.build();
        _$failedField = 'events';
        _events?.build();
        _$failedField = 'hosPolicy';
        _hosPolicy?.build();
        _$failedField = 'logEditRequests';
        _logEditRequests?.build();

        _$failedField = 'quickNotes';
        _quickNotes?.build();

        _$failedField = 'unidentifiedEvents';
        _unidentifiedEvents?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse',
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
