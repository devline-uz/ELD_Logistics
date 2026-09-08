// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_sync_dto_push_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest
    extends GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest {
  @override
  final String? appVersion;
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoChatPush>?
      chat;
  @override
  final GithubComDevlineOnebookEldInternalDomainSyncDtoClock? clock;
  @override
  final String deviceId;
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPush>?
      dvir;
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoEventPush>?
      events;
  @override
  final BuiltList<
      GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint>? telemetry;
  @override
  final String? unitId;

  factory _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequestBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequestBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest._(
      {this.appVersion,
      this.chat,
      this.clock,
      required this.deviceId,
      this.dvir,
      this.events,
      this.telemetry,
      this.unitId})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequestBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequestBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest &&
        appVersion == other.appVersion &&
        chat == other.chat &&
        clock == other.clock &&
        deviceId == other.deviceId &&
        dvir == other.dvir &&
        events == other.events &&
        telemetry == other.telemetry &&
        unitId == other.unitId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, appVersion.hashCode);
    _$hash = $jc(_$hash, chat.hashCode);
    _$hash = $jc(_$hash, clock.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, dvir.hashCode);
    _$hash = $jc(_$hash, events.hashCode);
    _$hash = $jc(_$hash, telemetry.hashCode);
    _$hash = $jc(_$hash, unitId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest')
          ..add('appVersion', appVersion)
          ..add('chat', chat)
          ..add('clock', clock)
          ..add('deviceId', deviceId)
          ..add('dvir', dvir)
          ..add('events', events)
          ..add('telemetry', telemetry)
          ..add('unitId', unitId))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequestBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest,
            GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequestBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest? _$v;

  String? _appVersion;
  String? get appVersion => _$this._appVersion;
  set appVersion(String? appVersion) => _$this._appVersion = appVersion;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainSyncDtoChatPush>? _chat;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainSyncDtoChatPush>
      get chat => _$this._chat ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainSyncDtoChatPush>();
  set chat(
          ListBuilder<GithubComDevlineOnebookEldInternalDomainSyncDtoChatPush>?
              chat) =>
      _$this._chat = chat;

  GithubComDevlineOnebookEldInternalDomainSyncDtoClockBuilder? _clock;
  GithubComDevlineOnebookEldInternalDomainSyncDtoClockBuilder get clock =>
      _$this._clock ??=
          GithubComDevlineOnebookEldInternalDomainSyncDtoClockBuilder();
  set clock(
          GithubComDevlineOnebookEldInternalDomainSyncDtoClockBuilder? clock) =>
      _$this._clock = clock;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPush>? _dvir;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPush>
      get dvir => _$this._dvir ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPush>();
  set dvir(
          ListBuilder<GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPush>?
              dvir) =>
      _$this._dvir = dvir;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainSyncDtoEventPush>?
      _events;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainSyncDtoEventPush>
      get events => _$this._events ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainSyncDtoEventPush>();
  set events(
          ListBuilder<GithubComDevlineOnebookEldInternalDomainSyncDtoEventPush>?
              events) =>
      _$this._events = events;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint>?
      _telemetry;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint>
      get telemetry => _$this._telemetry ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint>();
  set telemetry(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint>?
              telemetry) =>
      _$this._telemetry = telemetry;

  String? _unitId;
  String? get unitId => _$this._unitId;
  set unitId(String? unitId) => _$this._unitId = unitId;

  GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequestBuilder() {
    GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _appVersion = $v.appVersion;
      _chat = $v.chat?.toBuilder();
      _clock = $v.clock?.toBuilder();
      _deviceId = $v.deviceId;
      _dvir = $v.dvir?.toBuilder();
      _events = $v.events?.toBuilder();
      _telemetry = $v.telemetry?.toBuilder();
      _unitId = $v.unitId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest _build() {
    _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest._(
            appVersion: appVersion,
            chat: _chat?.build(),
            clock: _clock?.build(),
            deviceId: BuiltValueNullFieldError.checkNotNull(
                deviceId,
                r'GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest',
                'deviceId'),
            dvir: _dvir?.build(),
            events: _events?.build(),
            telemetry: _telemetry?.build(),
            unitId: unitId,
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
            r'GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest',
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
