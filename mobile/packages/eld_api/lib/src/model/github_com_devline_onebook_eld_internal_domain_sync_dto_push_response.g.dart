// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_sync_dto_push_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse
    extends GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse {
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult>?
      chat;
  @override
  final GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdict? clock;
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult>?
      dvir;
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult>?
      events;
  @override
  final DateTime? serverTime;
  @override
  final GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult?
      telemetry;

  factory _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponseBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponseBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse._(
      {this.chat,
      this.clock,
      this.dvir,
      this.events,
      this.serverTime,
      this.telemetry})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponseBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponseBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse &&
        chat == other.chat &&
        clock == other.clock &&
        dvir == other.dvir &&
        events == other.events &&
        serverTime == other.serverTime &&
        telemetry == other.telemetry;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, chat.hashCode);
    _$hash = $jc(_$hash, clock.hashCode);
    _$hash = $jc(_$hash, dvir.hashCode);
    _$hash = $jc(_$hash, events.hashCode);
    _$hash = $jc(_$hash, serverTime.hashCode);
    _$hash = $jc(_$hash, telemetry.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse')
          ..add('chat', chat)
          ..add('clock', clock)
          ..add('dvir', dvir)
          ..add('events', events)
          ..add('serverTime', serverTime)
          ..add('telemetry', telemetry))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponseBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse,
            GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponseBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse? _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult>?
      _chat;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult>
      get chat => _$this._chat ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult>();
  set chat(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult>?
              chat) =>
      _$this._chat = chat;

  GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictBuilder? _clock;
  GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictBuilder
      get clock => _$this._clock ??=
          GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictBuilder();
  set clock(
          GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdictBuilder?
              clock) =>
      _$this._clock = clock;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult>?
      _dvir;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult>
      get dvir => _$this._dvir ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult>();
  set dvir(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult>?
              dvir) =>
      _$this._dvir = dvir;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult>?
      _events;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult>
      get events => _$this._events ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult>();
  set events(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult>?
              events) =>
      _$this._events = events;

  DateTime? _serverTime;
  DateTime? get serverTime => _$this._serverTime;
  set serverTime(DateTime? serverTime) => _$this._serverTime = serverTime;

  GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResultBuilder?
      _telemetry;
  GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResultBuilder
      get telemetry => _$this._telemetry ??=
          GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResultBuilder();
  set telemetry(
          GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResultBuilder?
              telemetry) =>
      _$this._telemetry = telemetry;

  GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponseBuilder() {
    GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponseBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _chat = $v.chat?.toBuilder();
      _clock = $v.clock?.toBuilder();
      _dvir = $v.dvir?.toBuilder();
      _events = $v.events?.toBuilder();
      _serverTime = $v.serverTime;
      _telemetry = $v.telemetry?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse other) {
    _$v =
        other as _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse _build() {
    _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse._(
            chat: _chat?.build(),
            clock: _clock?.build(),
            dvir: _dvir?.build(),
            events: _events?.build(),
            serverTime: serverTime,
            telemetry: _telemetry?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'chat';
        _chat?.build();
        _$failedField = 'clock';
        _clock?.build();
        _$failedField = 'dvir';
        _dvir?.build();
        _$failedField = 'events';
        _events?.build();

        _$failedField = 'telemetry';
        _telemetry?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse',
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
