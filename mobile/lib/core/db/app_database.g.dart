// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $OutboxItemsTable extends OutboxItems with TableInfo<$OutboxItemsTable, OutboxItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 32),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 64),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceSeqMeta = const VerificationMeta('deviceSeq');
  @override
  late final GeneratedColumn<int> deviceSeq = GeneratedColumn<int>(
    'device_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionSlotMeta = const VerificationMeta('sessionSlot');
  @override
  late final GeneratedColumn<int> sessionSlot = GeneratedColumn<int>(
    'session_slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta('nextAttemptAt');
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt = GeneratedColumn<DateTime>(
    'next_attempt_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('pending'),
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta('idempotencyKey');
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rejectReasonMeta = const VerificationMeta('rejectReason');
  @override
  late final GeneratedColumn<String> rejectReason = GeneratedColumn<String>(
    'reject_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rejectSeenMeta = const VerificationMeta('rejectSeen');
  @override
  late final GeneratedColumn<bool> rejectSeen = GeneratedColumn<bool>(
    'reject_seen',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("reject_seen" IN (0, 1))'),
    defaultValue: const Constant<bool>(false),
  );
  static const VerificationMeta _supersededByMeta = const VerificationMeta('supersededBy');
  @override
  late final GeneratedColumn<String> supersededBy = GeneratedColumn<String>(
    'superseded_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    payload,
    clientId,
    deviceSeq,
    sessionSlot,
    userId,
    createdAt,
    attempts,
    nextAttemptAt,
    state,
    idempotencyKey,
    rejectReason,
    rejectSeen,
    supersededBy,
    lastError,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(_kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta, payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('device_seq')) {
      context.handle(
        _deviceSeqMeta,
        deviceSeq.isAcceptableOrUnknown(data['device_seq']!, _deviceSeqMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceSeqMeta);
    }
    if (data.containsKey('session_slot')) {
      context.handle(
        _sessionSlotMeta,
        sessionSlot.isAcceptableOrUnknown(data['session_slot']!, _sessionSlotMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(data['next_attempt_at']!, _nextAttemptAtMeta),
      );
    } else if (isInserting) {
      context.missing(_nextAttemptAtMeta);
    }
    if (data.containsKey('state')) {
      context.handle(_stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(data['idempotency_key']!, _idempotencyKeyMeta),
      );
    }
    if (data.containsKey('reject_reason')) {
      context.handle(
        _rejectReasonMeta,
        rejectReason.isAcceptableOrUnknown(data['reject_reason']!, _rejectReasonMeta),
      );
    }
    if (data.containsKey('reject_seen')) {
      context.handle(
        _rejectSeenMeta,
        rejectSeen.isAcceptableOrUnknown(data['reject_seen']!, _rejectSeenMeta),
      );
    }
    if (data.containsKey('superseded_by')) {
      context.handle(
        _supersededByMeta,
        supersededBy.isAcceptableOrUnknown(data['superseded_by']!, _supersededByMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {kind, clientId},
  ];
  @override
  OutboxItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxItemRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      kind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      deviceSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}device_seq'],
      )!,
      sessionSlot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_slot'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      ),
      rejectReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reject_reason'],
      ),
      rejectSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reject_seen'],
      )!,
      supersededBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}superseded_by'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $OutboxItemsTable createAlias(String alias) {
    return $OutboxItemsTable(attachedDatabase, alias);
  }
}

class OutboxItemRow extends DataClass implements Insertable<OutboxItemRow> {
  final int id;

  /// `event`/`telemetry`/`dvir`/`chat`/`certify`/`claim`/`log_edit`/
  /// `push_token`/`feedback`/`support` — `OutboxKind.wire`.
  final String kind;

  /// Serializatsiya qilingan so'rov tanasi.
  final String payload;

  /// Qurilmada generatsiya qilingan barqaror UUID v4 (M19).
  final String clientId;

  /// Yuborish tartibi shu ustun bo'yicha (M20, M25).
  final int deviceSeq;

  /// 0 — asosiy haydovchi, 1 — co-driver (§3).
  final int sessionSlot;
  final String? userId;
  final DateTime createdAt;
  final int attempts;
  final DateTime nextAttemptAt;

  /// `pending`/`inflight`/`acked`/`rejected` — `OutboxState.wire`.
  final String state;

  /// M33.6: batch kaliti saqlanadi, timeout dan keyin **aynan o'sha** kalit ketadi.
  final String? idempotencyKey;

  /// §5.6 `reason`; `superseded` bo'lsa element `acked` bo'ladi (M29).
  final String? rejectReason;

  /// `M-55` da qizil nuqta uchun (M30).
  final bool rejectSeen;

  /// `superseded` natijadagi yutgan event server id si.
  final String? supersededBy;

  /// Oxirgi transport xatosi kodi (diagnostika, `M-54`).
  final String? lastError;
  final DateTime updatedAt;
  const OutboxItemRow({
    required this.id,
    required this.kind,
    required this.payload,
    required this.clientId,
    required this.deviceSeq,
    required this.sessionSlot,
    this.userId,
    required this.createdAt,
    required this.attempts,
    required this.nextAttemptAt,
    required this.state,
    this.idempotencyKey,
    this.rejectReason,
    required this.rejectSeen,
    this.supersededBy,
    this.lastError,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    map['payload'] = Variable<String>(payload);
    map['client_id'] = Variable<String>(clientId);
    map['device_seq'] = Variable<int>(deviceSeq);
    map['session_slot'] = Variable<int>(sessionSlot);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempts'] = Variable<int>(attempts);
    map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || idempotencyKey != null) {
      map['idempotency_key'] = Variable<String>(idempotencyKey);
    }
    if (!nullToAbsent || rejectReason != null) {
      map['reject_reason'] = Variable<String>(rejectReason);
    }
    map['reject_seen'] = Variable<bool>(rejectSeen);
    if (!nullToAbsent || supersededBy != null) {
      map['superseded_by'] = Variable<String>(supersededBy);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  OutboxItemsCompanion toCompanion(bool nullToAbsent) {
    return OutboxItemsCompanion(
      id: Value(id),
      kind: Value(kind),
      payload: Value(payload),
      clientId: Value(clientId),
      deviceSeq: Value(deviceSeq),
      sessionSlot: Value(sessionSlot),
      userId: userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      createdAt: Value(createdAt),
      attempts: Value(attempts),
      nextAttemptAt: Value(nextAttemptAt),
      state: Value(state),
      idempotencyKey: idempotencyKey == null && nullToAbsent
          ? const Value.absent()
          : Value(idempotencyKey),
      rejectReason: rejectReason == null && nullToAbsent
          ? const Value.absent()
          : Value(rejectReason),
      rejectSeen: Value(rejectSeen),
      supersededBy: supersededBy == null && nullToAbsent
          ? const Value.absent()
          : Value(supersededBy),
      lastError: lastError == null && nullToAbsent ? const Value.absent() : Value(lastError),
      updatedAt: Value(updatedAt),
    );
  }

  factory OutboxItemRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxItemRow(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      payload: serializer.fromJson<String>(json['payload']),
      clientId: serializer.fromJson<String>(json['clientId']),
      deviceSeq: serializer.fromJson<int>(json['deviceSeq']),
      sessionSlot: serializer.fromJson<int>(json['sessionSlot']),
      userId: serializer.fromJson<String?>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextAttemptAt: serializer.fromJson<DateTime>(json['nextAttemptAt']),
      state: serializer.fromJson<String>(json['state']),
      idempotencyKey: serializer.fromJson<String?>(json['idempotencyKey']),
      rejectReason: serializer.fromJson<String?>(json['rejectReason']),
      rejectSeen: serializer.fromJson<bool>(json['rejectSeen']),
      supersededBy: serializer.fromJson<String?>(json['supersededBy']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
      'payload': serializer.toJson<String>(payload),
      'clientId': serializer.toJson<String>(clientId),
      'deviceSeq': serializer.toJson<int>(deviceSeq),
      'sessionSlot': serializer.toJson<int>(sessionSlot),
      'userId': serializer.toJson<String?>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attempts': serializer.toJson<int>(attempts),
      'nextAttemptAt': serializer.toJson<DateTime>(nextAttemptAt),
      'state': serializer.toJson<String>(state),
      'idempotencyKey': serializer.toJson<String?>(idempotencyKey),
      'rejectReason': serializer.toJson<String?>(rejectReason),
      'rejectSeen': serializer.toJson<bool>(rejectSeen),
      'supersededBy': serializer.toJson<String?>(supersededBy),
      'lastError': serializer.toJson<String?>(lastError),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  OutboxItemRow copyWith({
    int? id,
    String? kind,
    String? payload,
    String? clientId,
    int? deviceSeq,
    int? sessionSlot,
    Value<String?> userId = const Value.absent(),
    DateTime? createdAt,
    int? attempts,
    DateTime? nextAttemptAt,
    String? state,
    Value<String?> idempotencyKey = const Value.absent(),
    Value<String?> rejectReason = const Value.absent(),
    bool? rejectSeen,
    Value<String?> supersededBy = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    DateTime? updatedAt,
  }) => OutboxItemRow(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    payload: payload ?? this.payload,
    clientId: clientId ?? this.clientId,
    deviceSeq: deviceSeq ?? this.deviceSeq,
    sessionSlot: sessionSlot ?? this.sessionSlot,
    userId: userId.present ? userId.value : this.userId,
    createdAt: createdAt ?? this.createdAt,
    attempts: attempts ?? this.attempts,
    nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
    state: state ?? this.state,
    idempotencyKey: idempotencyKey.present ? idempotencyKey.value : this.idempotencyKey,
    rejectReason: rejectReason.present ? rejectReason.value : this.rejectReason,
    rejectSeen: rejectSeen ?? this.rejectSeen,
    supersededBy: supersededBy.present ? supersededBy.value : this.supersededBy,
    lastError: lastError.present ? lastError.value : this.lastError,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  OutboxItemRow copyWithCompanion(OutboxItemsCompanion data) {
    return OutboxItemRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      payload: data.payload.present ? data.payload.value : this.payload,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      deviceSeq: data.deviceSeq.present ? data.deviceSeq.value : this.deviceSeq,
      sessionSlot: data.sessionSlot.present ? data.sessionSlot.value : this.sessionSlot,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextAttemptAt: data.nextAttemptAt.present ? data.nextAttemptAt.value : this.nextAttemptAt,
      state: data.state.present ? data.state.value : this.state,
      idempotencyKey: data.idempotencyKey.present ? data.idempotencyKey.value : this.idempotencyKey,
      rejectReason: data.rejectReason.present ? data.rejectReason.value : this.rejectReason,
      rejectSeen: data.rejectSeen.present ? data.rejectSeen.value : this.rejectSeen,
      supersededBy: data.supersededBy.present ? data.supersededBy.value : this.supersededBy,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxItemRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('payload: $payload, ')
          ..write('clientId: $clientId, ')
          ..write('deviceSeq: $deviceSeq, ')
          ..write('sessionSlot: $sessionSlot, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('state: $state, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('rejectReason: $rejectReason, ')
          ..write('rejectSeen: $rejectSeen, ')
          ..write('supersededBy: $supersededBy, ')
          ..write('lastError: $lastError, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    payload,
    clientId,
    deviceSeq,
    sessionSlot,
    userId,
    createdAt,
    attempts,
    nextAttemptAt,
    state,
    idempotencyKey,
    rejectReason,
    rejectSeen,
    supersededBy,
    lastError,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxItemRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.payload == this.payload &&
          other.clientId == this.clientId &&
          other.deviceSeq == this.deviceSeq &&
          other.sessionSlot == this.sessionSlot &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.state == this.state &&
          other.idempotencyKey == this.idempotencyKey &&
          other.rejectReason == this.rejectReason &&
          other.rejectSeen == this.rejectSeen &&
          other.supersededBy == this.supersededBy &&
          other.lastError == this.lastError &&
          other.updatedAt == this.updatedAt);
}

class OutboxItemsCompanion extends UpdateCompanion<OutboxItemRow> {
  final Value<int> id;
  final Value<String> kind;
  final Value<String> payload;
  final Value<String> clientId;
  final Value<int> deviceSeq;
  final Value<int> sessionSlot;
  final Value<String?> userId;
  final Value<DateTime> createdAt;
  final Value<int> attempts;
  final Value<DateTime> nextAttemptAt;
  final Value<String> state;
  final Value<String?> idempotencyKey;
  final Value<String?> rejectReason;
  final Value<bool> rejectSeen;
  final Value<String?> supersededBy;
  final Value<String?> lastError;
  final Value<DateTime> updatedAt;
  const OutboxItemsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.payload = const Value.absent(),
    this.clientId = const Value.absent(),
    this.deviceSeq = const Value.absent(),
    this.sessionSlot = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.state = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.rejectReason = const Value.absent(),
    this.rejectSeen = const Value.absent(),
    this.supersededBy = const Value.absent(),
    this.lastError = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  OutboxItemsCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
    required String payload,
    required String clientId,
    required int deviceSeq,
    this.sessionSlot = const Value.absent(),
    this.userId = const Value.absent(),
    required DateTime createdAt,
    this.attempts = const Value.absent(),
    required DateTime nextAttemptAt,
    this.state = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.rejectReason = const Value.absent(),
    this.rejectSeen = const Value.absent(),
    this.supersededBy = const Value.absent(),
    this.lastError = const Value.absent(),
    required DateTime updatedAt,
  }) : kind = Value(kind),
       payload = Value(payload),
       clientId = Value(clientId),
       deviceSeq = Value(deviceSeq),
       createdAt = Value(createdAt),
       nextAttemptAt = Value(nextAttemptAt),
       updatedAt = Value(updatedAt);
  static Insertable<OutboxItemRow> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<String>? payload,
    Expression<String>? clientId,
    Expression<int>? deviceSeq,
    Expression<int>? sessionSlot,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
    Expression<int>? attempts,
    Expression<DateTime>? nextAttemptAt,
    Expression<String>? state,
    Expression<String>? idempotencyKey,
    Expression<String>? rejectReason,
    Expression<bool>? rejectSeen,
    Expression<String>? supersededBy,
    Expression<String>? lastError,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (payload != null) 'payload': payload,
      if (clientId != null) 'client_id': clientId,
      if (deviceSeq != null) 'device_seq': deviceSeq,
      if (sessionSlot != null) 'session_slot': sessionSlot,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (state != null) 'state': state,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (rejectReason != null) 'reject_reason': rejectReason,
      if (rejectSeen != null) 'reject_seen': rejectSeen,
      if (supersededBy != null) 'superseded_by': supersededBy,
      if (lastError != null) 'last_error': lastError,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  OutboxItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? kind,
    Value<String>? payload,
    Value<String>? clientId,
    Value<int>? deviceSeq,
    Value<int>? sessionSlot,
    Value<String?>? userId,
    Value<DateTime>? createdAt,
    Value<int>? attempts,
    Value<DateTime>? nextAttemptAt,
    Value<String>? state,
    Value<String?>? idempotencyKey,
    Value<String?>? rejectReason,
    Value<bool>? rejectSeen,
    Value<String?>? supersededBy,
    Value<String?>? lastError,
    Value<DateTime>? updatedAt,
  }) {
    return OutboxItemsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      payload: payload ?? this.payload,
      clientId: clientId ?? this.clientId,
      deviceSeq: deviceSeq ?? this.deviceSeq,
      sessionSlot: sessionSlot ?? this.sessionSlot,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      state: state ?? this.state,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      rejectReason: rejectReason ?? this.rejectReason,
      rejectSeen: rejectSeen ?? this.rejectSeen,
      supersededBy: supersededBy ?? this.supersededBy,
      lastError: lastError ?? this.lastError,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (deviceSeq.present) {
      map['device_seq'] = Variable<int>(deviceSeq.value);
    }
    if (sessionSlot.present) {
      map['session_slot'] = Variable<int>(sessionSlot.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (rejectReason.present) {
      map['reject_reason'] = Variable<String>(rejectReason.value);
    }
    if (rejectSeen.present) {
      map['reject_seen'] = Variable<bool>(rejectSeen.value);
    }
    if (supersededBy.present) {
      map['superseded_by'] = Variable<String>(supersededBy.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxItemsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('payload: $payload, ')
          ..write('clientId: $clientId, ')
          ..write('deviceSeq: $deviceSeq, ')
          ..write('sessionSlot: $sessionSlot, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('state: $state, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('rejectReason: $rejectReason, ')
          ..write('rejectSeen: $rejectSeen, ')
          ..write('supersededBy: $supersededBy, ')
          ..write('lastError: $lastError, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $DutyEventsTable extends DutyEvents with TableInfo<$DutyEventsTable, DutyEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DutyEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _clientEventIdMeta = const VerificationMeta('clientEventId');
  @override
  late final GeneratedColumn<String> clientEventId = GeneratedColumn<String>(
    'client_event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _specialMeta = const VerificationMeta('special');
  @override
  late final GeneratedColumn<String> special = GeneratedColumn<String>(
    'special',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('none'),
  );
  static const VerificationMeta _eventTimeMeta = const VerificationMeta('eventTime');
  @override
  late final GeneratedColumn<DateTime> eventTime = GeneratedColumn<DateTime>(
    'event_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeSourceMeta = const VerificationMeta('timeSource');
  @override
  late final GeneratedColumn<String> timeSource = GeneratedColumn<String>(
    'time_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('phone'),
  );
  static const VerificationMeta _timeUnverifiedMeta = const VerificationMeta('timeUnverified');
  @override
  late final GeneratedColumn<bool> timeUnverified = GeneratedColumn<bool>(
    'time_unverified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("time_unverified" IN (0, 1))'),
    defaultValue: const Constant<bool>(false),
  );
  static const VerificationMeta _clockSkewSecMeta = const VerificationMeta('clockSkewSec');
  @override
  late final GeneratedColumn<int> clockSkewSec = GeneratedColumn<int>(
    'clock_skew_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
  );
  static const VerificationMeta _deviceSeqMeta = const VerificationMeta('deviceSeq');
  @override
  late final GeneratedColumn<int> deviceSeq = GeneratedColumn<int>(
    'device_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('driver'),
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gpsAccuracyMMeta = const VerificationMeta('gpsAccuracyM');
  @override
  late final GeneratedColumn<double> gpsAccuracyM = GeneratedColumn<double>(
    'gps_accuracy_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationTextMeta = const VerificationMeta('locationText');
  @override
  late final GeneratedColumn<String> locationText = GeneratedColumn<String>(
    'location_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _odometerMMeta = const VerificationMeta('odometerM');
  @override
  late final GeneratedColumn<int> odometerM = GeneratedColumn<int>(
    'odometer_m',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _engineHoursMeta = const VerificationMeta('engineHours');
  @override
  late final GeneratedColumn<double> engineHours = GeneratedColumn<double>(
    'engine_hours',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speedKmhMeta = const VerificationMeta('speedKmh');
  @override
  late final GeneratedColumn<double> speedKmh = GeneratedColumn<double>(
    'speed_kmh',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<String> unitId = GeneratedColumn<String>(
    'unit_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eldDeviceIdMeta = const VerificationMeta('eldDeviceId');
  @override
  late final GeneratedColumn<String> eldDeviceId = GeneratedColumn<String>(
    'eld_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _driverIdMeta = const VerificationMeta('driverId');
  @override
  late final GeneratedColumn<String> driverId = GeneratedColumn<String>(
    'driver_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> trailerIds =
      GeneratedColumn<String>(
        'trailer_ids',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant<String>('[]'),
      ).withConverter<List<String>>($DutyEventsTable.$convertertrailerIds);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> shippingDocIds =
      GeneratedColumn<String>(
        'shipping_doc_ids',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant<String>('[]'),
      ).withConverter<List<String>>($DutyEventsTable.$convertershippingDocIds);
  static const VerificationMeta _syncStateMeta = const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('pending'),
  );
  static const VerificationMeta _supersededByMeta = const VerificationMeta('supersededBy');
  @override
  late final GeneratedColumn<String> supersededBy = GeneratedColumn<String>(
    'superseded_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lockedMeta = const VerificationMeta('locked');
  @override
  late final GeneratedColumn<bool> locked = GeneratedColumn<bool>(
    'locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("locked" IN (0, 1))'),
    defaultValue: const Constant<bool>(false),
  );
  static const VerificationMeta _logDateMeta = const VerificationMeta('logDate');
  @override
  late final GeneratedColumn<String> logDate = GeneratedColumn<String>(
    'log_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clientEventId,
    serverId,
    eventType,
    status,
    special,
    eventTime,
    timeSource,
    timeUnverified,
    clockSkewSec,
    deviceSeq,
    origin,
    lat,
    lng,
    gpsAccuracyM,
    locationText,
    odometerM,
    engineHours,
    speedKmh,
    notes,
    unitId,
    eldDeviceId,
    driverId,
    trailerIds,
    shippingDocIds,
    syncState,
    supersededBy,
    locked,
    logDate,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'duty_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<DutyEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('client_event_id')) {
      context.handle(
        _clientEventIdMeta,
        clientEventId.isAcceptableOrUnknown(data['client_event_id']!, _clientEventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientEventIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('special')) {
      context.handle(_specialMeta, special.isAcceptableOrUnknown(data['special']!, _specialMeta));
    }
    if (data.containsKey('event_time')) {
      context.handle(
        _eventTimeMeta,
        eventTime.isAcceptableOrUnknown(data['event_time']!, _eventTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTimeMeta);
    }
    if (data.containsKey('time_source')) {
      context.handle(
        _timeSourceMeta,
        timeSource.isAcceptableOrUnknown(data['time_source']!, _timeSourceMeta),
      );
    }
    if (data.containsKey('time_unverified')) {
      context.handle(
        _timeUnverifiedMeta,
        timeUnverified.isAcceptableOrUnknown(data['time_unverified']!, _timeUnverifiedMeta),
      );
    }
    if (data.containsKey('clock_skew_sec')) {
      context.handle(
        _clockSkewSecMeta,
        clockSkewSec.isAcceptableOrUnknown(data['clock_skew_sec']!, _clockSkewSecMeta),
      );
    }
    if (data.containsKey('device_seq')) {
      context.handle(
        _deviceSeqMeta,
        deviceSeq.isAcceptableOrUnknown(data['device_seq']!, _deviceSeqMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceSeqMeta);
    }
    if (data.containsKey('origin')) {
      context.handle(_originMeta, origin.isAcceptableOrUnknown(data['origin']!, _originMeta));
    }
    if (data.containsKey('lat')) {
      context.handle(_latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    }
    if (data.containsKey('lng')) {
      context.handle(_lngMeta, lng.isAcceptableOrUnknown(data['lng']!, _lngMeta));
    }
    if (data.containsKey('gps_accuracy_m')) {
      context.handle(
        _gpsAccuracyMMeta,
        gpsAccuracyM.isAcceptableOrUnknown(data['gps_accuracy_m']!, _gpsAccuracyMMeta),
      );
    }
    if (data.containsKey('location_text')) {
      context.handle(
        _locationTextMeta,
        locationText.isAcceptableOrUnknown(data['location_text']!, _locationTextMeta),
      );
    }
    if (data.containsKey('odometer_m')) {
      context.handle(
        _odometerMMeta,
        odometerM.isAcceptableOrUnknown(data['odometer_m']!, _odometerMMeta),
      );
    }
    if (data.containsKey('engine_hours')) {
      context.handle(
        _engineHoursMeta,
        engineHours.isAcceptableOrUnknown(data['engine_hours']!, _engineHoursMeta),
      );
    }
    if (data.containsKey('speed_kmh')) {
      context.handle(
        _speedKmhMeta,
        speedKmh.isAcceptableOrUnknown(data['speed_kmh']!, _speedKmhMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('unit_id')) {
      context.handle(_unitIdMeta, unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta));
    }
    if (data.containsKey('eld_device_id')) {
      context.handle(
        _eldDeviceIdMeta,
        eldDeviceId.isAcceptableOrUnknown(data['eld_device_id']!, _eldDeviceIdMeta),
      );
    }
    if (data.containsKey('driver_id')) {
      context.handle(
        _driverIdMeta,
        driverId.isAcceptableOrUnknown(data['driver_id']!, _driverIdMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('superseded_by')) {
      context.handle(
        _supersededByMeta,
        supersededBy.isAcceptableOrUnknown(data['superseded_by']!, _supersededByMeta),
      );
    }
    if (data.containsKey('locked')) {
      context.handle(_lockedMeta, locked.isAcceptableOrUnknown(data['locked']!, _lockedMeta));
    }
    if (data.containsKey('log_date')) {
      context.handle(_logDateMeta, logDate.isAcceptableOrUnknown(data['log_date']!, _logDateMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DutyEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DutyEventRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      clientEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_event_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      special: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}special'],
      )!,
      eventTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}event_time'],
      )!,
      timeSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_source'],
      )!,
      timeUnverified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}time_unverified'],
      )!,
      clockSkewSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}clock_skew_sec'],
      )!,
      deviceSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}device_seq'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      lat: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}lat']),
      lng: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}lng']),
      gpsAccuracyM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gps_accuracy_m'],
      ),
      locationText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_text'],
      ),
      odometerM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odometer_m'],
      ),
      engineHours: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}engine_hours'],
      ),
      speedKmh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed_kmh'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      unitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_id'],
      ),
      eldDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}eld_device_id'],
      ),
      driverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}driver_id'],
      ),
      trailerIds: $DutyEventsTable.$convertertrailerIds.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}trailer_ids'],
        )!,
      ),
      shippingDocIds: $DutyEventsTable.$convertershippingDocIds.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}shipping_doc_ids'],
        )!,
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      supersededBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}superseded_by'],
      ),
      locked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}locked'],
      )!,
      logDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}log_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DutyEventsTable createAlias(String alias) {
    return $DutyEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<List<String>, String, Object?> $convertertrailerIds =
      const StringListConverter();
  static JsonTypeConverter2<List<String>, String, Object?> $convertershippingDocIds =
      const StringListConverter();
}

class DutyEventRow extends DataClass implements Insertable<DutyEventRow> {
  final int id;

  /// M19: idempotentlikning yagona kaliti, hech qachon o'zgarmaydi.
  final String clientEventId;
  final String? serverId;

  /// M32 enum: `status_change`, `intermediate`, `login`, … .
  final String eventType;

  /// `OFF`/`SB`/`DR`/`ON` — `status_change` uchun.
  final String? status;

  /// `none`/`pc`/`ym`.
  final String special;

  /// UTC. Kunga ajratish faqat Home Terminal TZ da (M42).
  final DateTime eventTime;

  /// `eld_rtc`/`server`/`phone` (§7.1).
  final String timeSource;
  final bool timeUnverified;
  final int clockSkewSec;
  final int deviceSeq;

  /// `auto`/`driver`/`manual_no_eld`/`assigned` (M40).
  final String origin;
  final double? lat;
  final double? lng;
  final double? gpsAccuracyM;
  final String? locationText;

  /// Metrlarda (§5.1 "masofa `_m`").
  final int? odometerM;
  final double? engineHours;
  final double? speedKmh;
  final String? notes;
  final String? unitId;
  final String? eldDeviceId;
  final String? driverId;
  final List<String> trailerIds;
  final List<String> shippingDocIds;

  /// `pending`/`inflight`/`acked`/`rejected` — outbox natijasining ko'zgusi.
  final String syncState;
  final String? supersededBy;

  /// Kun sertifikatlangan bo'lsa `true` — yangi event faqat edit-request orqali.
  final bool locked;

  /// Home Terminal TZ dagi kun (`YYYY-MM-DD`, M42).
  final String? logDate;
  final DateTime createdAt;
  const DutyEventRow({
    required this.id,
    required this.clientEventId,
    this.serverId,
    required this.eventType,
    this.status,
    required this.special,
    required this.eventTime,
    required this.timeSource,
    required this.timeUnverified,
    required this.clockSkewSec,
    required this.deviceSeq,
    required this.origin,
    this.lat,
    this.lng,
    this.gpsAccuracyM,
    this.locationText,
    this.odometerM,
    this.engineHours,
    this.speedKmh,
    this.notes,
    this.unitId,
    this.eldDeviceId,
    this.driverId,
    required this.trailerIds,
    required this.shippingDocIds,
    required this.syncState,
    this.supersededBy,
    required this.locked,
    this.logDate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['client_event_id'] = Variable<String>(clientEventId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['event_type'] = Variable<String>(eventType);
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    map['special'] = Variable<String>(special);
    map['event_time'] = Variable<DateTime>(eventTime);
    map['time_source'] = Variable<String>(timeSource);
    map['time_unverified'] = Variable<bool>(timeUnverified);
    map['clock_skew_sec'] = Variable<int>(clockSkewSec);
    map['device_seq'] = Variable<int>(deviceSeq);
    map['origin'] = Variable<String>(origin);
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lng != null) {
      map['lng'] = Variable<double>(lng);
    }
    if (!nullToAbsent || gpsAccuracyM != null) {
      map['gps_accuracy_m'] = Variable<double>(gpsAccuracyM);
    }
    if (!nullToAbsent || locationText != null) {
      map['location_text'] = Variable<String>(locationText);
    }
    if (!nullToAbsent || odometerM != null) {
      map['odometer_m'] = Variable<int>(odometerM);
    }
    if (!nullToAbsent || engineHours != null) {
      map['engine_hours'] = Variable<double>(engineHours);
    }
    if (!nullToAbsent || speedKmh != null) {
      map['speed_kmh'] = Variable<double>(speedKmh);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || unitId != null) {
      map['unit_id'] = Variable<String>(unitId);
    }
    if (!nullToAbsent || eldDeviceId != null) {
      map['eld_device_id'] = Variable<String>(eldDeviceId);
    }
    if (!nullToAbsent || driverId != null) {
      map['driver_id'] = Variable<String>(driverId);
    }
    {
      map['trailer_ids'] = Variable<String>(
        $DutyEventsTable.$convertertrailerIds.toSql(trailerIds),
      );
    }
    {
      map['shipping_doc_ids'] = Variable<String>(
        $DutyEventsTable.$convertershippingDocIds.toSql(shippingDocIds),
      );
    }
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || supersededBy != null) {
      map['superseded_by'] = Variable<String>(supersededBy);
    }
    map['locked'] = Variable<bool>(locked);
    if (!nullToAbsent || logDate != null) {
      map['log_date'] = Variable<String>(logDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DutyEventsCompanion toCompanion(bool nullToAbsent) {
    return DutyEventsCompanion(
      id: Value(id),
      clientEventId: Value(clientEventId),
      serverId: serverId == null && nullToAbsent ? const Value.absent() : Value(serverId),
      eventType: Value(eventType),
      status: status == null && nullToAbsent ? const Value.absent() : Value(status),
      special: Value(special),
      eventTime: Value(eventTime),
      timeSource: Value(timeSource),
      timeUnverified: Value(timeUnverified),
      clockSkewSec: Value(clockSkewSec),
      deviceSeq: Value(deviceSeq),
      origin: Value(origin),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
      gpsAccuracyM: gpsAccuracyM == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsAccuracyM),
      locationText: locationText == null && nullToAbsent
          ? const Value.absent()
          : Value(locationText),
      odometerM: odometerM == null && nullToAbsent ? const Value.absent() : Value(odometerM),
      engineHours: engineHours == null && nullToAbsent ? const Value.absent() : Value(engineHours),
      speedKmh: speedKmh == null && nullToAbsent ? const Value.absent() : Value(speedKmh),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      unitId: unitId == null && nullToAbsent ? const Value.absent() : Value(unitId),
      eldDeviceId: eldDeviceId == null && nullToAbsent ? const Value.absent() : Value(eldDeviceId),
      driverId: driverId == null && nullToAbsent ? const Value.absent() : Value(driverId),
      trailerIds: Value(trailerIds),
      shippingDocIds: Value(shippingDocIds),
      syncState: Value(syncState),
      supersededBy: supersededBy == null && nullToAbsent
          ? const Value.absent()
          : Value(supersededBy),
      locked: Value(locked),
      logDate: logDate == null && nullToAbsent ? const Value.absent() : Value(logDate),
      createdAt: Value(createdAt),
    );
  }

  factory DutyEventRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DutyEventRow(
      id: serializer.fromJson<int>(json['id']),
      clientEventId: serializer.fromJson<String>(json['clientEventId']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      status: serializer.fromJson<String?>(json['status']),
      special: serializer.fromJson<String>(json['special']),
      eventTime: serializer.fromJson<DateTime>(json['eventTime']),
      timeSource: serializer.fromJson<String>(json['timeSource']),
      timeUnverified: serializer.fromJson<bool>(json['timeUnverified']),
      clockSkewSec: serializer.fromJson<int>(json['clockSkewSec']),
      deviceSeq: serializer.fromJson<int>(json['deviceSeq']),
      origin: serializer.fromJson<String>(json['origin']),
      lat: serializer.fromJson<double?>(json['lat']),
      lng: serializer.fromJson<double?>(json['lng']),
      gpsAccuracyM: serializer.fromJson<double?>(json['gpsAccuracyM']),
      locationText: serializer.fromJson<String?>(json['locationText']),
      odometerM: serializer.fromJson<int?>(json['odometerM']),
      engineHours: serializer.fromJson<double?>(json['engineHours']),
      speedKmh: serializer.fromJson<double?>(json['speedKmh']),
      notes: serializer.fromJson<String?>(json['notes']),
      unitId: serializer.fromJson<String?>(json['unitId']),
      eldDeviceId: serializer.fromJson<String?>(json['eldDeviceId']),
      driverId: serializer.fromJson<String?>(json['driverId']),
      trailerIds: $DutyEventsTable.$convertertrailerIds.fromJson(
        serializer.fromJson<Object?>(json['trailerIds']),
      ),
      shippingDocIds: $DutyEventsTable.$convertershippingDocIds.fromJson(
        serializer.fromJson<Object?>(json['shippingDocIds']),
      ),
      syncState: serializer.fromJson<String>(json['syncState']),
      supersededBy: serializer.fromJson<String?>(json['supersededBy']),
      locked: serializer.fromJson<bool>(json['locked']),
      logDate: serializer.fromJson<String?>(json['logDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clientEventId': serializer.toJson<String>(clientEventId),
      'serverId': serializer.toJson<String?>(serverId),
      'eventType': serializer.toJson<String>(eventType),
      'status': serializer.toJson<String?>(status),
      'special': serializer.toJson<String>(special),
      'eventTime': serializer.toJson<DateTime>(eventTime),
      'timeSource': serializer.toJson<String>(timeSource),
      'timeUnverified': serializer.toJson<bool>(timeUnverified),
      'clockSkewSec': serializer.toJson<int>(clockSkewSec),
      'deviceSeq': serializer.toJson<int>(deviceSeq),
      'origin': serializer.toJson<String>(origin),
      'lat': serializer.toJson<double?>(lat),
      'lng': serializer.toJson<double?>(lng),
      'gpsAccuracyM': serializer.toJson<double?>(gpsAccuracyM),
      'locationText': serializer.toJson<String?>(locationText),
      'odometerM': serializer.toJson<int?>(odometerM),
      'engineHours': serializer.toJson<double?>(engineHours),
      'speedKmh': serializer.toJson<double?>(speedKmh),
      'notes': serializer.toJson<String?>(notes),
      'unitId': serializer.toJson<String?>(unitId),
      'eldDeviceId': serializer.toJson<String?>(eldDeviceId),
      'driverId': serializer.toJson<String?>(driverId),
      'trailerIds': serializer.toJson<Object?>(
        $DutyEventsTable.$convertertrailerIds.toJson(trailerIds),
      ),
      'shippingDocIds': serializer.toJson<Object?>(
        $DutyEventsTable.$convertershippingDocIds.toJson(shippingDocIds),
      ),
      'syncState': serializer.toJson<String>(syncState),
      'supersededBy': serializer.toJson<String?>(supersededBy),
      'locked': serializer.toJson<bool>(locked),
      'logDate': serializer.toJson<String?>(logDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DutyEventRow copyWith({
    int? id,
    String? clientEventId,
    Value<String?> serverId = const Value.absent(),
    String? eventType,
    Value<String?> status = const Value.absent(),
    String? special,
    DateTime? eventTime,
    String? timeSource,
    bool? timeUnverified,
    int? clockSkewSec,
    int? deviceSeq,
    String? origin,
    Value<double?> lat = const Value.absent(),
    Value<double?> lng = const Value.absent(),
    Value<double?> gpsAccuracyM = const Value.absent(),
    Value<String?> locationText = const Value.absent(),
    Value<int?> odometerM = const Value.absent(),
    Value<double?> engineHours = const Value.absent(),
    Value<double?> speedKmh = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> unitId = const Value.absent(),
    Value<String?> eldDeviceId = const Value.absent(),
    Value<String?> driverId = const Value.absent(),
    List<String>? trailerIds,
    List<String>? shippingDocIds,
    String? syncState,
    Value<String?> supersededBy = const Value.absent(),
    bool? locked,
    Value<String?> logDate = const Value.absent(),
    DateTime? createdAt,
  }) => DutyEventRow(
    id: id ?? this.id,
    clientEventId: clientEventId ?? this.clientEventId,
    serverId: serverId.present ? serverId.value : this.serverId,
    eventType: eventType ?? this.eventType,
    status: status.present ? status.value : this.status,
    special: special ?? this.special,
    eventTime: eventTime ?? this.eventTime,
    timeSource: timeSource ?? this.timeSource,
    timeUnverified: timeUnverified ?? this.timeUnverified,
    clockSkewSec: clockSkewSec ?? this.clockSkewSec,
    deviceSeq: deviceSeq ?? this.deviceSeq,
    origin: origin ?? this.origin,
    lat: lat.present ? lat.value : this.lat,
    lng: lng.present ? lng.value : this.lng,
    gpsAccuracyM: gpsAccuracyM.present ? gpsAccuracyM.value : this.gpsAccuracyM,
    locationText: locationText.present ? locationText.value : this.locationText,
    odometerM: odometerM.present ? odometerM.value : this.odometerM,
    engineHours: engineHours.present ? engineHours.value : this.engineHours,
    speedKmh: speedKmh.present ? speedKmh.value : this.speedKmh,
    notes: notes.present ? notes.value : this.notes,
    unitId: unitId.present ? unitId.value : this.unitId,
    eldDeviceId: eldDeviceId.present ? eldDeviceId.value : this.eldDeviceId,
    driverId: driverId.present ? driverId.value : this.driverId,
    trailerIds: trailerIds ?? this.trailerIds,
    shippingDocIds: shippingDocIds ?? this.shippingDocIds,
    syncState: syncState ?? this.syncState,
    supersededBy: supersededBy.present ? supersededBy.value : this.supersededBy,
    locked: locked ?? this.locked,
    logDate: logDate.present ? logDate.value : this.logDate,
    createdAt: createdAt ?? this.createdAt,
  );
  DutyEventRow copyWithCompanion(DutyEventsCompanion data) {
    return DutyEventRow(
      id: data.id.present ? data.id.value : this.id,
      clientEventId: data.clientEventId.present ? data.clientEventId.value : this.clientEventId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      status: data.status.present ? data.status.value : this.status,
      special: data.special.present ? data.special.value : this.special,
      eventTime: data.eventTime.present ? data.eventTime.value : this.eventTime,
      timeSource: data.timeSource.present ? data.timeSource.value : this.timeSource,
      timeUnverified: data.timeUnverified.present ? data.timeUnverified.value : this.timeUnverified,
      clockSkewSec: data.clockSkewSec.present ? data.clockSkewSec.value : this.clockSkewSec,
      deviceSeq: data.deviceSeq.present ? data.deviceSeq.value : this.deviceSeq,
      origin: data.origin.present ? data.origin.value : this.origin,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      gpsAccuracyM: data.gpsAccuracyM.present ? data.gpsAccuracyM.value : this.gpsAccuracyM,
      locationText: data.locationText.present ? data.locationText.value : this.locationText,
      odometerM: data.odometerM.present ? data.odometerM.value : this.odometerM,
      engineHours: data.engineHours.present ? data.engineHours.value : this.engineHours,
      speedKmh: data.speedKmh.present ? data.speedKmh.value : this.speedKmh,
      notes: data.notes.present ? data.notes.value : this.notes,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      eldDeviceId: data.eldDeviceId.present ? data.eldDeviceId.value : this.eldDeviceId,
      driverId: data.driverId.present ? data.driverId.value : this.driverId,
      trailerIds: data.trailerIds.present ? data.trailerIds.value : this.trailerIds,
      shippingDocIds: data.shippingDocIds.present ? data.shippingDocIds.value : this.shippingDocIds,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      supersededBy: data.supersededBy.present ? data.supersededBy.value : this.supersededBy,
      locked: data.locked.present ? data.locked.value : this.locked,
      logDate: data.logDate.present ? data.logDate.value : this.logDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DutyEventRow(')
          ..write('id: $id, ')
          ..write('clientEventId: $clientEventId, ')
          ..write('serverId: $serverId, ')
          ..write('eventType: $eventType, ')
          ..write('status: $status, ')
          ..write('special: $special, ')
          ..write('eventTime: $eventTime, ')
          ..write('timeSource: $timeSource, ')
          ..write('timeUnverified: $timeUnverified, ')
          ..write('clockSkewSec: $clockSkewSec, ')
          ..write('deviceSeq: $deviceSeq, ')
          ..write('origin: $origin, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('gpsAccuracyM: $gpsAccuracyM, ')
          ..write('locationText: $locationText, ')
          ..write('odometerM: $odometerM, ')
          ..write('engineHours: $engineHours, ')
          ..write('speedKmh: $speedKmh, ')
          ..write('notes: $notes, ')
          ..write('unitId: $unitId, ')
          ..write('eldDeviceId: $eldDeviceId, ')
          ..write('driverId: $driverId, ')
          ..write('trailerIds: $trailerIds, ')
          ..write('shippingDocIds: $shippingDocIds, ')
          ..write('syncState: $syncState, ')
          ..write('supersededBy: $supersededBy, ')
          ..write('locked: $locked, ')
          ..write('logDate: $logDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    clientEventId,
    serverId,
    eventType,
    status,
    special,
    eventTime,
    timeSource,
    timeUnverified,
    clockSkewSec,
    deviceSeq,
    origin,
    lat,
    lng,
    gpsAccuracyM,
    locationText,
    odometerM,
    engineHours,
    speedKmh,
    notes,
    unitId,
    eldDeviceId,
    driverId,
    trailerIds,
    shippingDocIds,
    syncState,
    supersededBy,
    locked,
    logDate,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DutyEventRow &&
          other.id == this.id &&
          other.clientEventId == this.clientEventId &&
          other.serverId == this.serverId &&
          other.eventType == this.eventType &&
          other.status == this.status &&
          other.special == this.special &&
          other.eventTime == this.eventTime &&
          other.timeSource == this.timeSource &&
          other.timeUnverified == this.timeUnverified &&
          other.clockSkewSec == this.clockSkewSec &&
          other.deviceSeq == this.deviceSeq &&
          other.origin == this.origin &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.gpsAccuracyM == this.gpsAccuracyM &&
          other.locationText == this.locationText &&
          other.odometerM == this.odometerM &&
          other.engineHours == this.engineHours &&
          other.speedKmh == this.speedKmh &&
          other.notes == this.notes &&
          other.unitId == this.unitId &&
          other.eldDeviceId == this.eldDeviceId &&
          other.driverId == this.driverId &&
          other.trailerIds == this.trailerIds &&
          other.shippingDocIds == this.shippingDocIds &&
          other.syncState == this.syncState &&
          other.supersededBy == this.supersededBy &&
          other.locked == this.locked &&
          other.logDate == this.logDate &&
          other.createdAt == this.createdAt);
}

class DutyEventsCompanion extends UpdateCompanion<DutyEventRow> {
  final Value<int> id;
  final Value<String> clientEventId;
  final Value<String?> serverId;
  final Value<String> eventType;
  final Value<String?> status;
  final Value<String> special;
  final Value<DateTime> eventTime;
  final Value<String> timeSource;
  final Value<bool> timeUnverified;
  final Value<int> clockSkewSec;
  final Value<int> deviceSeq;
  final Value<String> origin;
  final Value<double?> lat;
  final Value<double?> lng;
  final Value<double?> gpsAccuracyM;
  final Value<String?> locationText;
  final Value<int?> odometerM;
  final Value<double?> engineHours;
  final Value<double?> speedKmh;
  final Value<String?> notes;
  final Value<String?> unitId;
  final Value<String?> eldDeviceId;
  final Value<String?> driverId;
  final Value<List<String>> trailerIds;
  final Value<List<String>> shippingDocIds;
  final Value<String> syncState;
  final Value<String?> supersededBy;
  final Value<bool> locked;
  final Value<String?> logDate;
  final Value<DateTime> createdAt;
  const DutyEventsCompanion({
    this.id = const Value.absent(),
    this.clientEventId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.status = const Value.absent(),
    this.special = const Value.absent(),
    this.eventTime = const Value.absent(),
    this.timeSource = const Value.absent(),
    this.timeUnverified = const Value.absent(),
    this.clockSkewSec = const Value.absent(),
    this.deviceSeq = const Value.absent(),
    this.origin = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.gpsAccuracyM = const Value.absent(),
    this.locationText = const Value.absent(),
    this.odometerM = const Value.absent(),
    this.engineHours = const Value.absent(),
    this.speedKmh = const Value.absent(),
    this.notes = const Value.absent(),
    this.unitId = const Value.absent(),
    this.eldDeviceId = const Value.absent(),
    this.driverId = const Value.absent(),
    this.trailerIds = const Value.absent(),
    this.shippingDocIds = const Value.absent(),
    this.syncState = const Value.absent(),
    this.supersededBy = const Value.absent(),
    this.locked = const Value.absent(),
    this.logDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DutyEventsCompanion.insert({
    this.id = const Value.absent(),
    required String clientEventId,
    this.serverId = const Value.absent(),
    required String eventType,
    this.status = const Value.absent(),
    this.special = const Value.absent(),
    required DateTime eventTime,
    this.timeSource = const Value.absent(),
    this.timeUnverified = const Value.absent(),
    this.clockSkewSec = const Value.absent(),
    required int deviceSeq,
    this.origin = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.gpsAccuracyM = const Value.absent(),
    this.locationText = const Value.absent(),
    this.odometerM = const Value.absent(),
    this.engineHours = const Value.absent(),
    this.speedKmh = const Value.absent(),
    this.notes = const Value.absent(),
    this.unitId = const Value.absent(),
    this.eldDeviceId = const Value.absent(),
    this.driverId = const Value.absent(),
    this.trailerIds = const Value.absent(),
    this.shippingDocIds = const Value.absent(),
    this.syncState = const Value.absent(),
    this.supersededBy = const Value.absent(),
    this.locked = const Value.absent(),
    this.logDate = const Value.absent(),
    required DateTime createdAt,
  }) : clientEventId = Value(clientEventId),
       eventType = Value(eventType),
       eventTime = Value(eventTime),
       deviceSeq = Value(deviceSeq),
       createdAt = Value(createdAt);
  static Insertable<DutyEventRow> custom({
    Expression<int>? id,
    Expression<String>? clientEventId,
    Expression<String>? serverId,
    Expression<String>? eventType,
    Expression<String>? status,
    Expression<String>? special,
    Expression<DateTime>? eventTime,
    Expression<String>? timeSource,
    Expression<bool>? timeUnverified,
    Expression<int>? clockSkewSec,
    Expression<int>? deviceSeq,
    Expression<String>? origin,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<double>? gpsAccuracyM,
    Expression<String>? locationText,
    Expression<int>? odometerM,
    Expression<double>? engineHours,
    Expression<double>? speedKmh,
    Expression<String>? notes,
    Expression<String>? unitId,
    Expression<String>? eldDeviceId,
    Expression<String>? driverId,
    Expression<String>? trailerIds,
    Expression<String>? shippingDocIds,
    Expression<String>? syncState,
    Expression<String>? supersededBy,
    Expression<bool>? locked,
    Expression<String>? logDate,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientEventId != null) 'client_event_id': clientEventId,
      if (serverId != null) 'server_id': serverId,
      if (eventType != null) 'event_type': eventType,
      if (status != null) 'status': status,
      if (special != null) 'special': special,
      if (eventTime != null) 'event_time': eventTime,
      if (timeSource != null) 'time_source': timeSource,
      if (timeUnverified != null) 'time_unverified': timeUnverified,
      if (clockSkewSec != null) 'clock_skew_sec': clockSkewSec,
      if (deviceSeq != null) 'device_seq': deviceSeq,
      if (origin != null) 'origin': origin,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (gpsAccuracyM != null) 'gps_accuracy_m': gpsAccuracyM,
      if (locationText != null) 'location_text': locationText,
      if (odometerM != null) 'odometer_m': odometerM,
      if (engineHours != null) 'engine_hours': engineHours,
      if (speedKmh != null) 'speed_kmh': speedKmh,
      if (notes != null) 'notes': notes,
      if (unitId != null) 'unit_id': unitId,
      if (eldDeviceId != null) 'eld_device_id': eldDeviceId,
      if (driverId != null) 'driver_id': driverId,
      if (trailerIds != null) 'trailer_ids': trailerIds,
      if (shippingDocIds != null) 'shipping_doc_ids': shippingDocIds,
      if (syncState != null) 'sync_state': syncState,
      if (supersededBy != null) 'superseded_by': supersededBy,
      if (locked != null) 'locked': locked,
      if (logDate != null) 'log_date': logDate,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DutyEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? clientEventId,
    Value<String?>? serverId,
    Value<String>? eventType,
    Value<String?>? status,
    Value<String>? special,
    Value<DateTime>? eventTime,
    Value<String>? timeSource,
    Value<bool>? timeUnverified,
    Value<int>? clockSkewSec,
    Value<int>? deviceSeq,
    Value<String>? origin,
    Value<double?>? lat,
    Value<double?>? lng,
    Value<double?>? gpsAccuracyM,
    Value<String?>? locationText,
    Value<int?>? odometerM,
    Value<double?>? engineHours,
    Value<double?>? speedKmh,
    Value<String?>? notes,
    Value<String?>? unitId,
    Value<String?>? eldDeviceId,
    Value<String?>? driverId,
    Value<List<String>>? trailerIds,
    Value<List<String>>? shippingDocIds,
    Value<String>? syncState,
    Value<String?>? supersededBy,
    Value<bool>? locked,
    Value<String?>? logDate,
    Value<DateTime>? createdAt,
  }) {
    return DutyEventsCompanion(
      id: id ?? this.id,
      clientEventId: clientEventId ?? this.clientEventId,
      serverId: serverId ?? this.serverId,
      eventType: eventType ?? this.eventType,
      status: status ?? this.status,
      special: special ?? this.special,
      eventTime: eventTime ?? this.eventTime,
      timeSource: timeSource ?? this.timeSource,
      timeUnverified: timeUnverified ?? this.timeUnverified,
      clockSkewSec: clockSkewSec ?? this.clockSkewSec,
      deviceSeq: deviceSeq ?? this.deviceSeq,
      origin: origin ?? this.origin,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      gpsAccuracyM: gpsAccuracyM ?? this.gpsAccuracyM,
      locationText: locationText ?? this.locationText,
      odometerM: odometerM ?? this.odometerM,
      engineHours: engineHours ?? this.engineHours,
      speedKmh: speedKmh ?? this.speedKmh,
      notes: notes ?? this.notes,
      unitId: unitId ?? this.unitId,
      eldDeviceId: eldDeviceId ?? this.eldDeviceId,
      driverId: driverId ?? this.driverId,
      trailerIds: trailerIds ?? this.trailerIds,
      shippingDocIds: shippingDocIds ?? this.shippingDocIds,
      syncState: syncState ?? this.syncState,
      supersededBy: supersededBy ?? this.supersededBy,
      locked: locked ?? this.locked,
      logDate: logDate ?? this.logDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clientEventId.present) {
      map['client_event_id'] = Variable<String>(clientEventId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (special.present) {
      map['special'] = Variable<String>(special.value);
    }
    if (eventTime.present) {
      map['event_time'] = Variable<DateTime>(eventTime.value);
    }
    if (timeSource.present) {
      map['time_source'] = Variable<String>(timeSource.value);
    }
    if (timeUnverified.present) {
      map['time_unverified'] = Variable<bool>(timeUnverified.value);
    }
    if (clockSkewSec.present) {
      map['clock_skew_sec'] = Variable<int>(clockSkewSec.value);
    }
    if (deviceSeq.present) {
      map['device_seq'] = Variable<int>(deviceSeq.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (gpsAccuracyM.present) {
      map['gps_accuracy_m'] = Variable<double>(gpsAccuracyM.value);
    }
    if (locationText.present) {
      map['location_text'] = Variable<String>(locationText.value);
    }
    if (odometerM.present) {
      map['odometer_m'] = Variable<int>(odometerM.value);
    }
    if (engineHours.present) {
      map['engine_hours'] = Variable<double>(engineHours.value);
    }
    if (speedKmh.present) {
      map['speed_kmh'] = Variable<double>(speedKmh.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (unitId.present) {
      map['unit_id'] = Variable<String>(unitId.value);
    }
    if (eldDeviceId.present) {
      map['eld_device_id'] = Variable<String>(eldDeviceId.value);
    }
    if (driverId.present) {
      map['driver_id'] = Variable<String>(driverId.value);
    }
    if (trailerIds.present) {
      map['trailer_ids'] = Variable<String>(
        $DutyEventsTable.$convertertrailerIds.toSql(trailerIds.value),
      );
    }
    if (shippingDocIds.present) {
      map['shipping_doc_ids'] = Variable<String>(
        $DutyEventsTable.$convertershippingDocIds.toSql(shippingDocIds.value),
      );
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (supersededBy.present) {
      map['superseded_by'] = Variable<String>(supersededBy.value);
    }
    if (locked.present) {
      map['locked'] = Variable<bool>(locked.value);
    }
    if (logDate.present) {
      map['log_date'] = Variable<String>(logDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DutyEventsCompanion(')
          ..write('id: $id, ')
          ..write('clientEventId: $clientEventId, ')
          ..write('serverId: $serverId, ')
          ..write('eventType: $eventType, ')
          ..write('status: $status, ')
          ..write('special: $special, ')
          ..write('eventTime: $eventTime, ')
          ..write('timeSource: $timeSource, ')
          ..write('timeUnverified: $timeUnverified, ')
          ..write('clockSkewSec: $clockSkewSec, ')
          ..write('deviceSeq: $deviceSeq, ')
          ..write('origin: $origin, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('gpsAccuracyM: $gpsAccuracyM, ')
          ..write('locationText: $locationText, ')
          ..write('odometerM: $odometerM, ')
          ..write('engineHours: $engineHours, ')
          ..write('speedKmh: $speedKmh, ')
          ..write('notes: $notes, ')
          ..write('unitId: $unitId, ')
          ..write('eldDeviceId: $eldDeviceId, ')
          ..write('driverId: $driverId, ')
          ..write('trailerIds: $trailerIds, ')
          ..write('shippingDocIds: $shippingDocIds, ')
          ..write('syncState: $syncState, ')
          ..write('supersededBy: $supersededBy, ')
          ..write('locked: $locked, ')
          ..write('logDate: $logDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TelemetryBufferTable extends TelemetryBuffer
    with TableInfo<$TelemetryBufferTable, TelemetryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TelemetryBufferTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<String> unitId = GeneratedColumn<String>(
    'unit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<DateTime> ts = GeneratedColumn<DateTime>(
    'ts',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speedKmhMeta = const VerificationMeta('speedKmh');
  @override
  late final GeneratedColumn<double> speedKmh = GeneratedColumn<double>(
    'speed_kmh',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _headingDegMeta = const VerificationMeta('headingDeg');
  @override
  late final GeneratedColumn<double> headingDeg = GeneratedColumn<double>(
    'heading_deg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _odometerMMeta = const VerificationMeta('odometerM');
  @override
  late final GeneratedColumn<int> odometerM = GeneratedColumn<int>(
    'odometer_m',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _engineHoursMeta = const VerificationMeta('engineHours');
  @override
  late final GeneratedColumn<double> engineHours = GeneratedColumn<double>(
    'engine_hours',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ignitionMeta = const VerificationMeta('ignition');
  @override
  late final GeneratedColumn<bool> ignition = GeneratedColumn<bool>(
    'ignition',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("ignition" IN (0, 1))'),
  );
  static const VerificationMeta _fuelPctMeta = const VerificationMeta('fuelPct');
  @override
  late final GeneratedColumn<double> fuelPct = GeneratedColumn<double>(
    'fuel_pct',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coolantTempCMeta = const VerificationMeta('coolantTempC');
  @override
  late final GeneratedColumn<double> coolantTempC = GeneratedColumn<double>(
    'coolant_temp_c',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coolantLevelPctMeta = const VerificationMeta('coolantLevelPct');
  @override
  late final GeneratedColumn<double> coolantLevelPct = GeneratedColumn<double>(
    'coolant_level_pct',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oilLevelPctMeta = const VerificationMeta('oilLevelPct');
  @override
  late final GeneratedColumn<double> oilLevelPct = GeneratedColumn<double>(
    'oil_level_pct',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batteryVoltageMeta = const VerificationMeta('batteryVoltage');
  @override
  late final GeneratedColumn<double> batteryVoltage = GeneratedColumn<double>(
    'battery_voltage',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batteryPctMeta = const VerificationMeta('batteryPct');
  @override
  late final GeneratedColumn<double> batteryPct = GeneratedColumn<double>(
    'battery_pct',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, Object?>?, String> diagnostics =
      GeneratedColumn<String>(
        'diagnostics',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Map<String, Object?>?>($TelemetryBufferTable.$converterdiagnosticsn);
  static const VerificationMeta _disconnectedMeta = const VerificationMeta('disconnected');
  @override
  late final GeneratedColumn<bool> disconnected = GeneratedColumn<bool>(
    'disconnected',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("disconnected" IN (0, 1))'),
    defaultValue: const Constant<bool>(false),
  );
  static const VerificationMeta _dutyStatusMeta = const VerificationMeta('dutyStatus');
  @override
  late final GeneratedColumn<String> dutyStatus = GeneratedColumn<String>(
    'duty_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _driverIdMeta = const VerificationMeta('driverId');
  @override
  late final GeneratedColumn<String> driverId = GeneratedColumn<String>(
    'driver_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sentMeta = const VerificationMeta('sent');
  @override
  late final GeneratedColumn<bool> sent = GeneratedColumn<bool>(
    'sent',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("sent" IN (0, 1))'),
    defaultValue: const Constant<bool>(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    unitId,
    ts,
    lat,
    lng,
    speedKmh,
    headingDeg,
    odometerM,
    engineHours,
    ignition,
    fuelPct,
    coolantTempC,
    coolantLevelPct,
    oilLevelPct,
    batteryVoltage,
    batteryPct,
    diagnostics,
    disconnected,
    dutyStatus,
    driverId,
    sent,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'telemetry_buffer';
  @override
  VerificationContext validateIntegrity(
    Insertable<TelemetryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('unit_id')) {
      context.handle(_unitIdMeta, unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta));
    } else if (isInserting) {
      context.missing(_unitIdMeta);
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(_latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    }
    if (data.containsKey('lng')) {
      context.handle(_lngMeta, lng.isAcceptableOrUnknown(data['lng']!, _lngMeta));
    }
    if (data.containsKey('speed_kmh')) {
      context.handle(
        _speedKmhMeta,
        speedKmh.isAcceptableOrUnknown(data['speed_kmh']!, _speedKmhMeta),
      );
    }
    if (data.containsKey('heading_deg')) {
      context.handle(
        _headingDegMeta,
        headingDeg.isAcceptableOrUnknown(data['heading_deg']!, _headingDegMeta),
      );
    }
    if (data.containsKey('odometer_m')) {
      context.handle(
        _odometerMMeta,
        odometerM.isAcceptableOrUnknown(data['odometer_m']!, _odometerMMeta),
      );
    }
    if (data.containsKey('engine_hours')) {
      context.handle(
        _engineHoursMeta,
        engineHours.isAcceptableOrUnknown(data['engine_hours']!, _engineHoursMeta),
      );
    }
    if (data.containsKey('ignition')) {
      context.handle(
        _ignitionMeta,
        ignition.isAcceptableOrUnknown(data['ignition']!, _ignitionMeta),
      );
    }
    if (data.containsKey('fuel_pct')) {
      context.handle(_fuelPctMeta, fuelPct.isAcceptableOrUnknown(data['fuel_pct']!, _fuelPctMeta));
    }
    if (data.containsKey('coolant_temp_c')) {
      context.handle(
        _coolantTempCMeta,
        coolantTempC.isAcceptableOrUnknown(data['coolant_temp_c']!, _coolantTempCMeta),
      );
    }
    if (data.containsKey('coolant_level_pct')) {
      context.handle(
        _coolantLevelPctMeta,
        coolantLevelPct.isAcceptableOrUnknown(data['coolant_level_pct']!, _coolantLevelPctMeta),
      );
    }
    if (data.containsKey('oil_level_pct')) {
      context.handle(
        _oilLevelPctMeta,
        oilLevelPct.isAcceptableOrUnknown(data['oil_level_pct']!, _oilLevelPctMeta),
      );
    }
    if (data.containsKey('battery_voltage')) {
      context.handle(
        _batteryVoltageMeta,
        batteryVoltage.isAcceptableOrUnknown(data['battery_voltage']!, _batteryVoltageMeta),
      );
    }
    if (data.containsKey('battery_pct')) {
      context.handle(
        _batteryPctMeta,
        batteryPct.isAcceptableOrUnknown(data['battery_pct']!, _batteryPctMeta),
      );
    }
    if (data.containsKey('disconnected')) {
      context.handle(
        _disconnectedMeta,
        disconnected.isAcceptableOrUnknown(data['disconnected']!, _disconnectedMeta),
      );
    }
    if (data.containsKey('duty_status')) {
      context.handle(
        _dutyStatusMeta,
        dutyStatus.isAcceptableOrUnknown(data['duty_status']!, _dutyStatusMeta),
      );
    }
    if (data.containsKey('driver_id')) {
      context.handle(
        _driverIdMeta,
        driverId.isAcceptableOrUnknown(data['driver_id']!, _driverIdMeta),
      );
    }
    if (data.containsKey('sent')) {
      context.handle(_sentMeta, sent.isAcceptableOrUnknown(data['sent']!, _sentMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {unitId, ts},
  ];
  @override
  TelemetryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TelemetryRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      unitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_id'],
      )!,
      ts: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}ts'])!,
      lat: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}lat']),
      lng: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}lng']),
      speedKmh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed_kmh'],
      ),
      headingDeg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}heading_deg'],
      ),
      odometerM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odometer_m'],
      ),
      engineHours: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}engine_hours'],
      ),
      ignition: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ignition'],
      ),
      fuelPct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fuel_pct'],
      ),
      coolantTempC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}coolant_temp_c'],
      ),
      coolantLevelPct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}coolant_level_pct'],
      ),
      oilLevelPct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}oil_level_pct'],
      ),
      batteryVoltage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}battery_voltage'],
      ),
      batteryPct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}battery_pct'],
      ),
      diagnostics: $TelemetryBufferTable.$converterdiagnosticsn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}diagnostics'],
        ),
      ),
      disconnected: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}disconnected'],
      )!,
      dutyStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}duty_status'],
      ),
      driverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}driver_id'],
      ),
      sent: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}sent'])!,
    );
  }

  @override
  $TelemetryBufferTable createAlias(String alias) {
    return $TelemetryBufferTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Map<String, Object?>, String, Object?> $converterdiagnostics =
      const JsonMapConverter();
  static JsonTypeConverter2<Map<String, Object?>?, String?, Object?> $converterdiagnosticsn =
      JsonTypeConverter2.asNullable($converterdiagnostics);
}

class TelemetryRow extends DataClass implements Insertable<TelemetryRow> {
  final int id;
  final String unitId;

  /// UTC nuqta vaqti; `(unit_id, ts)` — dublikat kaliti (eld-sync #4).
  final DateTime ts;
  final double? lat;
  final double? lng;
  final double? speedKmh;
  final double? headingDeg;
  final int? odometerM;
  final double? engineHours;
  final bool? ignition;
  final double? fuelPct;
  final double? coolantTempC;
  final double? coolantLevelPct;
  final double? oilLevelPct;
  final double? batteryVoltage;
  final double? batteryPct;
  final Map<String, Object?>? diagnostics;

  /// ELD uzilgan paytda yozilgan nuqta.
  final bool disconnected;
  final String? dutyStatus;
  final String? driverId;
  final bool sent;
  const TelemetryRow({
    required this.id,
    required this.unitId,
    required this.ts,
    this.lat,
    this.lng,
    this.speedKmh,
    this.headingDeg,
    this.odometerM,
    this.engineHours,
    this.ignition,
    this.fuelPct,
    this.coolantTempC,
    this.coolantLevelPct,
    this.oilLevelPct,
    this.batteryVoltage,
    this.batteryPct,
    this.diagnostics,
    required this.disconnected,
    this.dutyStatus,
    this.driverId,
    required this.sent,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['unit_id'] = Variable<String>(unitId);
    map['ts'] = Variable<DateTime>(ts);
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lng != null) {
      map['lng'] = Variable<double>(lng);
    }
    if (!nullToAbsent || speedKmh != null) {
      map['speed_kmh'] = Variable<double>(speedKmh);
    }
    if (!nullToAbsent || headingDeg != null) {
      map['heading_deg'] = Variable<double>(headingDeg);
    }
    if (!nullToAbsent || odometerM != null) {
      map['odometer_m'] = Variable<int>(odometerM);
    }
    if (!nullToAbsent || engineHours != null) {
      map['engine_hours'] = Variable<double>(engineHours);
    }
    if (!nullToAbsent || ignition != null) {
      map['ignition'] = Variable<bool>(ignition);
    }
    if (!nullToAbsent || fuelPct != null) {
      map['fuel_pct'] = Variable<double>(fuelPct);
    }
    if (!nullToAbsent || coolantTempC != null) {
      map['coolant_temp_c'] = Variable<double>(coolantTempC);
    }
    if (!nullToAbsent || coolantLevelPct != null) {
      map['coolant_level_pct'] = Variable<double>(coolantLevelPct);
    }
    if (!nullToAbsent || oilLevelPct != null) {
      map['oil_level_pct'] = Variable<double>(oilLevelPct);
    }
    if (!nullToAbsent || batteryVoltage != null) {
      map['battery_voltage'] = Variable<double>(batteryVoltage);
    }
    if (!nullToAbsent || batteryPct != null) {
      map['battery_pct'] = Variable<double>(batteryPct);
    }
    if (!nullToAbsent || diagnostics != null) {
      map['diagnostics'] = Variable<String>(
        $TelemetryBufferTable.$converterdiagnosticsn.toSql(diagnostics),
      );
    }
    map['disconnected'] = Variable<bool>(disconnected);
    if (!nullToAbsent || dutyStatus != null) {
      map['duty_status'] = Variable<String>(dutyStatus);
    }
    if (!nullToAbsent || driverId != null) {
      map['driver_id'] = Variable<String>(driverId);
    }
    map['sent'] = Variable<bool>(sent);
    return map;
  }

  TelemetryBufferCompanion toCompanion(bool nullToAbsent) {
    return TelemetryBufferCompanion(
      id: Value(id),
      unitId: Value(unitId),
      ts: Value(ts),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
      speedKmh: speedKmh == null && nullToAbsent ? const Value.absent() : Value(speedKmh),
      headingDeg: headingDeg == null && nullToAbsent ? const Value.absent() : Value(headingDeg),
      odometerM: odometerM == null && nullToAbsent ? const Value.absent() : Value(odometerM),
      engineHours: engineHours == null && nullToAbsent ? const Value.absent() : Value(engineHours),
      ignition: ignition == null && nullToAbsent ? const Value.absent() : Value(ignition),
      fuelPct: fuelPct == null && nullToAbsent ? const Value.absent() : Value(fuelPct),
      coolantTempC: coolantTempC == null && nullToAbsent
          ? const Value.absent()
          : Value(coolantTempC),
      coolantLevelPct: coolantLevelPct == null && nullToAbsent
          ? const Value.absent()
          : Value(coolantLevelPct),
      oilLevelPct: oilLevelPct == null && nullToAbsent ? const Value.absent() : Value(oilLevelPct),
      batteryVoltage: batteryVoltage == null && nullToAbsent
          ? const Value.absent()
          : Value(batteryVoltage),
      batteryPct: batteryPct == null && nullToAbsent ? const Value.absent() : Value(batteryPct),
      diagnostics: diagnostics == null && nullToAbsent ? const Value.absent() : Value(diagnostics),
      disconnected: Value(disconnected),
      dutyStatus: dutyStatus == null && nullToAbsent ? const Value.absent() : Value(dutyStatus),
      driverId: driverId == null && nullToAbsent ? const Value.absent() : Value(driverId),
      sent: Value(sent),
    );
  }

  factory TelemetryRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TelemetryRow(
      id: serializer.fromJson<int>(json['id']),
      unitId: serializer.fromJson<String>(json['unitId']),
      ts: serializer.fromJson<DateTime>(json['ts']),
      lat: serializer.fromJson<double?>(json['lat']),
      lng: serializer.fromJson<double?>(json['lng']),
      speedKmh: serializer.fromJson<double?>(json['speedKmh']),
      headingDeg: serializer.fromJson<double?>(json['headingDeg']),
      odometerM: serializer.fromJson<int?>(json['odometerM']),
      engineHours: serializer.fromJson<double?>(json['engineHours']),
      ignition: serializer.fromJson<bool?>(json['ignition']),
      fuelPct: serializer.fromJson<double?>(json['fuelPct']),
      coolantTempC: serializer.fromJson<double?>(json['coolantTempC']),
      coolantLevelPct: serializer.fromJson<double?>(json['coolantLevelPct']),
      oilLevelPct: serializer.fromJson<double?>(json['oilLevelPct']),
      batteryVoltage: serializer.fromJson<double?>(json['batteryVoltage']),
      batteryPct: serializer.fromJson<double?>(json['batteryPct']),
      diagnostics: $TelemetryBufferTable.$converterdiagnosticsn.fromJson(
        serializer.fromJson<Object?>(json['diagnostics']),
      ),
      disconnected: serializer.fromJson<bool>(json['disconnected']),
      dutyStatus: serializer.fromJson<String?>(json['dutyStatus']),
      driverId: serializer.fromJson<String?>(json['driverId']),
      sent: serializer.fromJson<bool>(json['sent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'unitId': serializer.toJson<String>(unitId),
      'ts': serializer.toJson<DateTime>(ts),
      'lat': serializer.toJson<double?>(lat),
      'lng': serializer.toJson<double?>(lng),
      'speedKmh': serializer.toJson<double?>(speedKmh),
      'headingDeg': serializer.toJson<double?>(headingDeg),
      'odometerM': serializer.toJson<int?>(odometerM),
      'engineHours': serializer.toJson<double?>(engineHours),
      'ignition': serializer.toJson<bool?>(ignition),
      'fuelPct': serializer.toJson<double?>(fuelPct),
      'coolantTempC': serializer.toJson<double?>(coolantTempC),
      'coolantLevelPct': serializer.toJson<double?>(coolantLevelPct),
      'oilLevelPct': serializer.toJson<double?>(oilLevelPct),
      'batteryVoltage': serializer.toJson<double?>(batteryVoltage),
      'batteryPct': serializer.toJson<double?>(batteryPct),
      'diagnostics': serializer.toJson<Object?>(
        $TelemetryBufferTable.$converterdiagnosticsn.toJson(diagnostics),
      ),
      'disconnected': serializer.toJson<bool>(disconnected),
      'dutyStatus': serializer.toJson<String?>(dutyStatus),
      'driverId': serializer.toJson<String?>(driverId),
      'sent': serializer.toJson<bool>(sent),
    };
  }

  TelemetryRow copyWith({
    int? id,
    String? unitId,
    DateTime? ts,
    Value<double?> lat = const Value.absent(),
    Value<double?> lng = const Value.absent(),
    Value<double?> speedKmh = const Value.absent(),
    Value<double?> headingDeg = const Value.absent(),
    Value<int?> odometerM = const Value.absent(),
    Value<double?> engineHours = const Value.absent(),
    Value<bool?> ignition = const Value.absent(),
    Value<double?> fuelPct = const Value.absent(),
    Value<double?> coolantTempC = const Value.absent(),
    Value<double?> coolantLevelPct = const Value.absent(),
    Value<double?> oilLevelPct = const Value.absent(),
    Value<double?> batteryVoltage = const Value.absent(),
    Value<double?> batteryPct = const Value.absent(),
    Value<Map<String, Object?>?> diagnostics = const Value.absent(),
    bool? disconnected,
    Value<String?> dutyStatus = const Value.absent(),
    Value<String?> driverId = const Value.absent(),
    bool? sent,
  }) => TelemetryRow(
    id: id ?? this.id,
    unitId: unitId ?? this.unitId,
    ts: ts ?? this.ts,
    lat: lat.present ? lat.value : this.lat,
    lng: lng.present ? lng.value : this.lng,
    speedKmh: speedKmh.present ? speedKmh.value : this.speedKmh,
    headingDeg: headingDeg.present ? headingDeg.value : this.headingDeg,
    odometerM: odometerM.present ? odometerM.value : this.odometerM,
    engineHours: engineHours.present ? engineHours.value : this.engineHours,
    ignition: ignition.present ? ignition.value : this.ignition,
    fuelPct: fuelPct.present ? fuelPct.value : this.fuelPct,
    coolantTempC: coolantTempC.present ? coolantTempC.value : this.coolantTempC,
    coolantLevelPct: coolantLevelPct.present ? coolantLevelPct.value : this.coolantLevelPct,
    oilLevelPct: oilLevelPct.present ? oilLevelPct.value : this.oilLevelPct,
    batteryVoltage: batteryVoltage.present ? batteryVoltage.value : this.batteryVoltage,
    batteryPct: batteryPct.present ? batteryPct.value : this.batteryPct,
    diagnostics: diagnostics.present ? diagnostics.value : this.diagnostics,
    disconnected: disconnected ?? this.disconnected,
    dutyStatus: dutyStatus.present ? dutyStatus.value : this.dutyStatus,
    driverId: driverId.present ? driverId.value : this.driverId,
    sent: sent ?? this.sent,
  );
  TelemetryRow copyWithCompanion(TelemetryBufferCompanion data) {
    return TelemetryRow(
      id: data.id.present ? data.id.value : this.id,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      ts: data.ts.present ? data.ts.value : this.ts,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      speedKmh: data.speedKmh.present ? data.speedKmh.value : this.speedKmh,
      headingDeg: data.headingDeg.present ? data.headingDeg.value : this.headingDeg,
      odometerM: data.odometerM.present ? data.odometerM.value : this.odometerM,
      engineHours: data.engineHours.present ? data.engineHours.value : this.engineHours,
      ignition: data.ignition.present ? data.ignition.value : this.ignition,
      fuelPct: data.fuelPct.present ? data.fuelPct.value : this.fuelPct,
      coolantTempC: data.coolantTempC.present ? data.coolantTempC.value : this.coolantTempC,
      coolantLevelPct: data.coolantLevelPct.present
          ? data.coolantLevelPct.value
          : this.coolantLevelPct,
      oilLevelPct: data.oilLevelPct.present ? data.oilLevelPct.value : this.oilLevelPct,
      batteryVoltage: data.batteryVoltage.present ? data.batteryVoltage.value : this.batteryVoltage,
      batteryPct: data.batteryPct.present ? data.batteryPct.value : this.batteryPct,
      diagnostics: data.diagnostics.present ? data.diagnostics.value : this.diagnostics,
      disconnected: data.disconnected.present ? data.disconnected.value : this.disconnected,
      dutyStatus: data.dutyStatus.present ? data.dutyStatus.value : this.dutyStatus,
      driverId: data.driverId.present ? data.driverId.value : this.driverId,
      sent: data.sent.present ? data.sent.value : this.sent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TelemetryRow(')
          ..write('id: $id, ')
          ..write('unitId: $unitId, ')
          ..write('ts: $ts, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('speedKmh: $speedKmh, ')
          ..write('headingDeg: $headingDeg, ')
          ..write('odometerM: $odometerM, ')
          ..write('engineHours: $engineHours, ')
          ..write('ignition: $ignition, ')
          ..write('fuelPct: $fuelPct, ')
          ..write('coolantTempC: $coolantTempC, ')
          ..write('coolantLevelPct: $coolantLevelPct, ')
          ..write('oilLevelPct: $oilLevelPct, ')
          ..write('batteryVoltage: $batteryVoltage, ')
          ..write('batteryPct: $batteryPct, ')
          ..write('diagnostics: $diagnostics, ')
          ..write('disconnected: $disconnected, ')
          ..write('dutyStatus: $dutyStatus, ')
          ..write('driverId: $driverId, ')
          ..write('sent: $sent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    unitId,
    ts,
    lat,
    lng,
    speedKmh,
    headingDeg,
    odometerM,
    engineHours,
    ignition,
    fuelPct,
    coolantTempC,
    coolantLevelPct,
    oilLevelPct,
    batteryVoltage,
    batteryPct,
    diagnostics,
    disconnected,
    dutyStatus,
    driverId,
    sent,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TelemetryRow &&
          other.id == this.id &&
          other.unitId == this.unitId &&
          other.ts == this.ts &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.speedKmh == this.speedKmh &&
          other.headingDeg == this.headingDeg &&
          other.odometerM == this.odometerM &&
          other.engineHours == this.engineHours &&
          other.ignition == this.ignition &&
          other.fuelPct == this.fuelPct &&
          other.coolantTempC == this.coolantTempC &&
          other.coolantLevelPct == this.coolantLevelPct &&
          other.oilLevelPct == this.oilLevelPct &&
          other.batteryVoltage == this.batteryVoltage &&
          other.batteryPct == this.batteryPct &&
          other.diagnostics == this.diagnostics &&
          other.disconnected == this.disconnected &&
          other.dutyStatus == this.dutyStatus &&
          other.driverId == this.driverId &&
          other.sent == this.sent);
}

class TelemetryBufferCompanion extends UpdateCompanion<TelemetryRow> {
  final Value<int> id;
  final Value<String> unitId;
  final Value<DateTime> ts;
  final Value<double?> lat;
  final Value<double?> lng;
  final Value<double?> speedKmh;
  final Value<double?> headingDeg;
  final Value<int?> odometerM;
  final Value<double?> engineHours;
  final Value<bool?> ignition;
  final Value<double?> fuelPct;
  final Value<double?> coolantTempC;
  final Value<double?> coolantLevelPct;
  final Value<double?> oilLevelPct;
  final Value<double?> batteryVoltage;
  final Value<double?> batteryPct;
  final Value<Map<String, Object?>?> diagnostics;
  final Value<bool> disconnected;
  final Value<String?> dutyStatus;
  final Value<String?> driverId;
  final Value<bool> sent;
  const TelemetryBufferCompanion({
    this.id = const Value.absent(),
    this.unitId = const Value.absent(),
    this.ts = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.speedKmh = const Value.absent(),
    this.headingDeg = const Value.absent(),
    this.odometerM = const Value.absent(),
    this.engineHours = const Value.absent(),
    this.ignition = const Value.absent(),
    this.fuelPct = const Value.absent(),
    this.coolantTempC = const Value.absent(),
    this.coolantLevelPct = const Value.absent(),
    this.oilLevelPct = const Value.absent(),
    this.batteryVoltage = const Value.absent(),
    this.batteryPct = const Value.absent(),
    this.diagnostics = const Value.absent(),
    this.disconnected = const Value.absent(),
    this.dutyStatus = const Value.absent(),
    this.driverId = const Value.absent(),
    this.sent = const Value.absent(),
  });
  TelemetryBufferCompanion.insert({
    this.id = const Value.absent(),
    required String unitId,
    required DateTime ts,
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.speedKmh = const Value.absent(),
    this.headingDeg = const Value.absent(),
    this.odometerM = const Value.absent(),
    this.engineHours = const Value.absent(),
    this.ignition = const Value.absent(),
    this.fuelPct = const Value.absent(),
    this.coolantTempC = const Value.absent(),
    this.coolantLevelPct = const Value.absent(),
    this.oilLevelPct = const Value.absent(),
    this.batteryVoltage = const Value.absent(),
    this.batteryPct = const Value.absent(),
    this.diagnostics = const Value.absent(),
    this.disconnected = const Value.absent(),
    this.dutyStatus = const Value.absent(),
    this.driverId = const Value.absent(),
    this.sent = const Value.absent(),
  }) : unitId = Value(unitId),
       ts = Value(ts);
  static Insertable<TelemetryRow> custom({
    Expression<int>? id,
    Expression<String>? unitId,
    Expression<DateTime>? ts,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<double>? speedKmh,
    Expression<double>? headingDeg,
    Expression<int>? odometerM,
    Expression<double>? engineHours,
    Expression<bool>? ignition,
    Expression<double>? fuelPct,
    Expression<double>? coolantTempC,
    Expression<double>? coolantLevelPct,
    Expression<double>? oilLevelPct,
    Expression<double>? batteryVoltage,
    Expression<double>? batteryPct,
    Expression<String>? diagnostics,
    Expression<bool>? disconnected,
    Expression<String>? dutyStatus,
    Expression<String>? driverId,
    Expression<bool>? sent,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (unitId != null) 'unit_id': unitId,
      if (ts != null) 'ts': ts,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (speedKmh != null) 'speed_kmh': speedKmh,
      if (headingDeg != null) 'heading_deg': headingDeg,
      if (odometerM != null) 'odometer_m': odometerM,
      if (engineHours != null) 'engine_hours': engineHours,
      if (ignition != null) 'ignition': ignition,
      if (fuelPct != null) 'fuel_pct': fuelPct,
      if (coolantTempC != null) 'coolant_temp_c': coolantTempC,
      if (coolantLevelPct != null) 'coolant_level_pct': coolantLevelPct,
      if (oilLevelPct != null) 'oil_level_pct': oilLevelPct,
      if (batteryVoltage != null) 'battery_voltage': batteryVoltage,
      if (batteryPct != null) 'battery_pct': batteryPct,
      if (diagnostics != null) 'diagnostics': diagnostics,
      if (disconnected != null) 'disconnected': disconnected,
      if (dutyStatus != null) 'duty_status': dutyStatus,
      if (driverId != null) 'driver_id': driverId,
      if (sent != null) 'sent': sent,
    });
  }

  TelemetryBufferCompanion copyWith({
    Value<int>? id,
    Value<String>? unitId,
    Value<DateTime>? ts,
    Value<double?>? lat,
    Value<double?>? lng,
    Value<double?>? speedKmh,
    Value<double?>? headingDeg,
    Value<int?>? odometerM,
    Value<double?>? engineHours,
    Value<bool?>? ignition,
    Value<double?>? fuelPct,
    Value<double?>? coolantTempC,
    Value<double?>? coolantLevelPct,
    Value<double?>? oilLevelPct,
    Value<double?>? batteryVoltage,
    Value<double?>? batteryPct,
    Value<Map<String, Object?>?>? diagnostics,
    Value<bool>? disconnected,
    Value<String?>? dutyStatus,
    Value<String?>? driverId,
    Value<bool>? sent,
  }) {
    return TelemetryBufferCompanion(
      id: id ?? this.id,
      unitId: unitId ?? this.unitId,
      ts: ts ?? this.ts,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      speedKmh: speedKmh ?? this.speedKmh,
      headingDeg: headingDeg ?? this.headingDeg,
      odometerM: odometerM ?? this.odometerM,
      engineHours: engineHours ?? this.engineHours,
      ignition: ignition ?? this.ignition,
      fuelPct: fuelPct ?? this.fuelPct,
      coolantTempC: coolantTempC ?? this.coolantTempC,
      coolantLevelPct: coolantLevelPct ?? this.coolantLevelPct,
      oilLevelPct: oilLevelPct ?? this.oilLevelPct,
      batteryVoltage: batteryVoltage ?? this.batteryVoltage,
      batteryPct: batteryPct ?? this.batteryPct,
      diagnostics: diagnostics ?? this.diagnostics,
      disconnected: disconnected ?? this.disconnected,
      dutyStatus: dutyStatus ?? this.dutyStatus,
      driverId: driverId ?? this.driverId,
      sent: sent ?? this.sent,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (unitId.present) {
      map['unit_id'] = Variable<String>(unitId.value);
    }
    if (ts.present) {
      map['ts'] = Variable<DateTime>(ts.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (speedKmh.present) {
      map['speed_kmh'] = Variable<double>(speedKmh.value);
    }
    if (headingDeg.present) {
      map['heading_deg'] = Variable<double>(headingDeg.value);
    }
    if (odometerM.present) {
      map['odometer_m'] = Variable<int>(odometerM.value);
    }
    if (engineHours.present) {
      map['engine_hours'] = Variable<double>(engineHours.value);
    }
    if (ignition.present) {
      map['ignition'] = Variable<bool>(ignition.value);
    }
    if (fuelPct.present) {
      map['fuel_pct'] = Variable<double>(fuelPct.value);
    }
    if (coolantTempC.present) {
      map['coolant_temp_c'] = Variable<double>(coolantTempC.value);
    }
    if (coolantLevelPct.present) {
      map['coolant_level_pct'] = Variable<double>(coolantLevelPct.value);
    }
    if (oilLevelPct.present) {
      map['oil_level_pct'] = Variable<double>(oilLevelPct.value);
    }
    if (batteryVoltage.present) {
      map['battery_voltage'] = Variable<double>(batteryVoltage.value);
    }
    if (batteryPct.present) {
      map['battery_pct'] = Variable<double>(batteryPct.value);
    }
    if (diagnostics.present) {
      map['diagnostics'] = Variable<String>(
        $TelemetryBufferTable.$converterdiagnosticsn.toSql(diagnostics.value),
      );
    }
    if (disconnected.present) {
      map['disconnected'] = Variable<bool>(disconnected.value);
    }
    if (dutyStatus.present) {
      map['duty_status'] = Variable<String>(dutyStatus.value);
    }
    if (driverId.present) {
      map['driver_id'] = Variable<String>(driverId.value);
    }
    if (sent.present) {
      map['sent'] = Variable<bool>(sent.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TelemetryBufferCompanion(')
          ..write('id: $id, ')
          ..write('unitId: $unitId, ')
          ..write('ts: $ts, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('speedKmh: $speedKmh, ')
          ..write('headingDeg: $headingDeg, ')
          ..write('odometerM: $odometerM, ')
          ..write('engineHours: $engineHours, ')
          ..write('ignition: $ignition, ')
          ..write('fuelPct: $fuelPct, ')
          ..write('coolantTempC: $coolantTempC, ')
          ..write('coolantLevelPct: $coolantLevelPct, ')
          ..write('oilLevelPct: $oilLevelPct, ')
          ..write('batteryVoltage: $batteryVoltage, ')
          ..write('batteryPct: $batteryPct, ')
          ..write('diagnostics: $diagnostics, ')
          ..write('disconnected: $disconnected, ')
          ..write('dutyStatus: $dutyStatus, ')
          ..write('driverId: $driverId, ')
          ..write('sent: $sent')
          ..write(')'))
        .toString();
  }
}

class $DailyLogsTable extends DailyLogs with TableInfo<$DailyLogsTable, DailyLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _logDateMeta = const VerificationMeta('logDate');
  @override
  late final GeneratedColumn<String> logDate = GeneratedColumn<String>(
    'log_date',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 10, maxTextLength: 10),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _driverIdMeta = const VerificationMeta('driverId');
  @override
  late final GeneratedColumn<String> driverId = GeneratedColumn<String>(
    'driver_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta('timezone');
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _certificationStatusMeta = const VerificationMeta(
    'certificationStatus',
  );
  @override
  late final GeneratedColumn<String> certificationStatus = GeneratedColumn<String>(
    'certification_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('uncertified'),
  );
  static const VerificationMeta _signedAtMeta = const VerificationMeta('signedAt');
  @override
  late final GeneratedColumn<DateTime> signedAt = GeneratedColumn<DateTime>(
    'signed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceMMeta = const VerificationMeta('distanceM');
  @override
  late final GeneratedColumn<int> distanceM = GeneratedColumn<int>(
    'distance_m',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, Object?>, String> totals =
      GeneratedColumn<String>(
        'totals',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant<String>('{}'),
      ).withConverter<Map<String, Object?>>($DailyLogsTable.$convertertotals);
  static const VerificationMeta _readyMeta = const VerificationMeta('ready');
  @override
  late final GeneratedColumn<bool> ready = GeneratedColumn<bool>(
    'ready',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("ready" IN (0, 1))'),
    defaultValue: const Constant<bool>(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serverId,
    logDate,
    driverId,
    timezone,
    certificationStatus,
    signedAt,
    distanceM,
    totals,
    ready,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('log_date')) {
      context.handle(_logDateMeta, logDate.isAcceptableOrUnknown(data['log_date']!, _logDateMeta));
    } else if (isInserting) {
      context.missing(_logDateMeta);
    }
    if (data.containsKey('driver_id')) {
      context.handle(
        _driverIdMeta,
        driverId.isAcceptableOrUnknown(data['driver_id']!, _driverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_driverIdMeta);
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    } else if (isInserting) {
      context.missing(_timezoneMeta);
    }
    if (data.containsKey('certification_status')) {
      context.handle(
        _certificationStatusMeta,
        certificationStatus.isAcceptableOrUnknown(
          data['certification_status']!,
          _certificationStatusMeta,
        ),
      );
    }
    if (data.containsKey('signed_at')) {
      context.handle(
        _signedAtMeta,
        signedAt.isAcceptableOrUnknown(data['signed_at']!, _signedAtMeta),
      );
    }
    if (data.containsKey('distance_m')) {
      context.handle(
        _distanceMMeta,
        distanceM.isAcceptableOrUnknown(data['distance_m']!, _distanceMMeta),
      );
    }
    if (data.containsKey('ready')) {
      context.handle(_readyMeta, ready.isAcceptableOrUnknown(data['ready']!, _readyMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {driverId, logDate},
  ];
  @override
  DailyLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyLogRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      logDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}log_date'],
      )!,
      driverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}driver_id'],
      )!,
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      certificationStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}certification_status'],
      )!,
      signedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}signed_at'],
      ),
      distanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distance_m'],
      )!,
      totals: $DailyLogsTable.$convertertotals.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}totals'])!,
      ),
      ready: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}ready'])!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DailyLogsTable createAlias(String alias) {
    return $DailyLogsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Map<String, Object?>, String, Object?> $convertertotals =
      const JsonMapConverter();
}

class DailyLogRow extends DataClass implements Insertable<DailyLogRow> {
  final int id;
  final String? serverId;

  /// Home Terminal TZ dagi kun, `YYYY-MM-DD` (M42).
  final String logDate;
  final String driverId;

  /// IANA nomi (`America/Chicago`) — kun chegarasi shu bilan hisoblanadi.
  final String timezone;

  /// `uncertified`/`certified`/`recertify_required`.
  final String certificationStatus;
  final DateTime? signedAt;
  final int distanceM;

  /// Status bo'yicha jamlar (soniya) — JSON.
  final Map<String, Object?> totals;

  /// Sertifikatsiyaga tayyor (server hisoblaydi).
  final bool ready;
  final DateTime updatedAt;
  const DailyLogRow({
    required this.id,
    this.serverId,
    required this.logDate,
    required this.driverId,
    required this.timezone,
    required this.certificationStatus,
    this.signedAt,
    required this.distanceM,
    required this.totals,
    required this.ready,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['log_date'] = Variable<String>(logDate);
    map['driver_id'] = Variable<String>(driverId);
    map['timezone'] = Variable<String>(timezone);
    map['certification_status'] = Variable<String>(certificationStatus);
    if (!nullToAbsent || signedAt != null) {
      map['signed_at'] = Variable<DateTime>(signedAt);
    }
    map['distance_m'] = Variable<int>(distanceM);
    {
      map['totals'] = Variable<String>($DailyLogsTable.$convertertotals.toSql(totals));
    }
    map['ready'] = Variable<bool>(ready);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DailyLogsCompanion toCompanion(bool nullToAbsent) {
    return DailyLogsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent ? const Value.absent() : Value(serverId),
      logDate: Value(logDate),
      driverId: Value(driverId),
      timezone: Value(timezone),
      certificationStatus: Value(certificationStatus),
      signedAt: signedAt == null && nullToAbsent ? const Value.absent() : Value(signedAt),
      distanceM: Value(distanceM),
      totals: Value(totals),
      ready: Value(ready),
      updatedAt: Value(updatedAt),
    );
  }

  factory DailyLogRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyLogRow(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      logDate: serializer.fromJson<String>(json['logDate']),
      driverId: serializer.fromJson<String>(json['driverId']),
      timezone: serializer.fromJson<String>(json['timezone']),
      certificationStatus: serializer.fromJson<String>(json['certificationStatus']),
      signedAt: serializer.fromJson<DateTime?>(json['signedAt']),
      distanceM: serializer.fromJson<int>(json['distanceM']),
      totals: $DailyLogsTable.$convertertotals.fromJson(
        serializer.fromJson<Object?>(json['totals']),
      ),
      ready: serializer.fromJson<bool>(json['ready']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'logDate': serializer.toJson<String>(logDate),
      'driverId': serializer.toJson<String>(driverId),
      'timezone': serializer.toJson<String>(timezone),
      'certificationStatus': serializer.toJson<String>(certificationStatus),
      'signedAt': serializer.toJson<DateTime?>(signedAt),
      'distanceM': serializer.toJson<int>(distanceM),
      'totals': serializer.toJson<Object?>($DailyLogsTable.$convertertotals.toJson(totals)),
      'ready': serializer.toJson<bool>(ready),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DailyLogRow copyWith({
    int? id,
    Value<String?> serverId = const Value.absent(),
    String? logDate,
    String? driverId,
    String? timezone,
    String? certificationStatus,
    Value<DateTime?> signedAt = const Value.absent(),
    int? distanceM,
    Map<String, Object?>? totals,
    bool? ready,
    DateTime? updatedAt,
  }) => DailyLogRow(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    logDate: logDate ?? this.logDate,
    driverId: driverId ?? this.driverId,
    timezone: timezone ?? this.timezone,
    certificationStatus: certificationStatus ?? this.certificationStatus,
    signedAt: signedAt.present ? signedAt.value : this.signedAt,
    distanceM: distanceM ?? this.distanceM,
    totals: totals ?? this.totals,
    ready: ready ?? this.ready,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DailyLogRow copyWithCompanion(DailyLogsCompanion data) {
    return DailyLogRow(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      logDate: data.logDate.present ? data.logDate.value : this.logDate,
      driverId: data.driverId.present ? data.driverId.value : this.driverId,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      certificationStatus: data.certificationStatus.present
          ? data.certificationStatus.value
          : this.certificationStatus,
      signedAt: data.signedAt.present ? data.signedAt.value : this.signedAt,
      distanceM: data.distanceM.present ? data.distanceM.value : this.distanceM,
      totals: data.totals.present ? data.totals.value : this.totals,
      ready: data.ready.present ? data.ready.value : this.ready,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyLogRow(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('logDate: $logDate, ')
          ..write('driverId: $driverId, ')
          ..write('timezone: $timezone, ')
          ..write('certificationStatus: $certificationStatus, ')
          ..write('signedAt: $signedAt, ')
          ..write('distanceM: $distanceM, ')
          ..write('totals: $totals, ')
          ..write('ready: $ready, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    logDate,
    driverId,
    timezone,
    certificationStatus,
    signedAt,
    distanceM,
    totals,
    ready,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyLogRow &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.logDate == this.logDate &&
          other.driverId == this.driverId &&
          other.timezone == this.timezone &&
          other.certificationStatus == this.certificationStatus &&
          other.signedAt == this.signedAt &&
          other.distanceM == this.distanceM &&
          other.totals == this.totals &&
          other.ready == this.ready &&
          other.updatedAt == this.updatedAt);
}

class DailyLogsCompanion extends UpdateCompanion<DailyLogRow> {
  final Value<int> id;
  final Value<String?> serverId;
  final Value<String> logDate;
  final Value<String> driverId;
  final Value<String> timezone;
  final Value<String> certificationStatus;
  final Value<DateTime?> signedAt;
  final Value<int> distanceM;
  final Value<Map<String, Object?>> totals;
  final Value<bool> ready;
  final Value<DateTime> updatedAt;
  const DailyLogsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.logDate = const Value.absent(),
    this.driverId = const Value.absent(),
    this.timezone = const Value.absent(),
    this.certificationStatus = const Value.absent(),
    this.signedAt = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.totals = const Value.absent(),
    this.ready = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DailyLogsCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    required String logDate,
    required String driverId,
    required String timezone,
    this.certificationStatus = const Value.absent(),
    this.signedAt = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.totals = const Value.absent(),
    this.ready = const Value.absent(),
    required DateTime updatedAt,
  }) : logDate = Value(logDate),
       driverId = Value(driverId),
       timezone = Value(timezone),
       updatedAt = Value(updatedAt);
  static Insertable<DailyLogRow> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? logDate,
    Expression<String>? driverId,
    Expression<String>? timezone,
    Expression<String>? certificationStatus,
    Expression<DateTime>? signedAt,
    Expression<int>? distanceM,
    Expression<String>? totals,
    Expression<bool>? ready,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (logDate != null) 'log_date': logDate,
      if (driverId != null) 'driver_id': driverId,
      if (timezone != null) 'timezone': timezone,
      if (certificationStatus != null) 'certification_status': certificationStatus,
      if (signedAt != null) 'signed_at': signedAt,
      if (distanceM != null) 'distance_m': distanceM,
      if (totals != null) 'totals': totals,
      if (ready != null) 'ready': ready,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DailyLogsCompanion copyWith({
    Value<int>? id,
    Value<String?>? serverId,
    Value<String>? logDate,
    Value<String>? driverId,
    Value<String>? timezone,
    Value<String>? certificationStatus,
    Value<DateTime?>? signedAt,
    Value<int>? distanceM,
    Value<Map<String, Object?>>? totals,
    Value<bool>? ready,
    Value<DateTime>? updatedAt,
  }) {
    return DailyLogsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      logDate: logDate ?? this.logDate,
      driverId: driverId ?? this.driverId,
      timezone: timezone ?? this.timezone,
      certificationStatus: certificationStatus ?? this.certificationStatus,
      signedAt: signedAt ?? this.signedAt,
      distanceM: distanceM ?? this.distanceM,
      totals: totals ?? this.totals,
      ready: ready ?? this.ready,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (logDate.present) {
      map['log_date'] = Variable<String>(logDate.value);
    }
    if (driverId.present) {
      map['driver_id'] = Variable<String>(driverId.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (certificationStatus.present) {
      map['certification_status'] = Variable<String>(certificationStatus.value);
    }
    if (signedAt.present) {
      map['signed_at'] = Variable<DateTime>(signedAt.value);
    }
    if (distanceM.present) {
      map['distance_m'] = Variable<int>(distanceM.value);
    }
    if (totals.present) {
      map['totals'] = Variable<String>($DailyLogsTable.$convertertotals.toSql(totals.value));
    }
    if (ready.present) {
      map['ready'] = Variable<bool>(ready.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyLogsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('logDate: $logDate, ')
          ..write('driverId: $driverId, ')
          ..write('timezone: $timezone, ')
          ..write('certificationStatus: $certificationStatus, ')
          ..write('signedAt: $signedAt, ')
          ..write('distanceM: $distanceM, ')
          ..write('totals: $totals, ')
          ..write('ready: $ready, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $HosStatesTable extends HosStates with TableInfo<$HosStatesTable, HosStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HosStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _driverIdMeta = const VerificationMeta('driverId');
  @override
  late final GeneratedColumn<String> driverId = GeneratedColumn<String>(
    'driver_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _computedAtMeta = const VerificationMeta('computedAt');
  @override
  late final GeneratedColumn<DateTime> computedAt = GeneratedColumn<DateTime>(
    'computed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, Object?>, String> counters =
      GeneratedColumn<String>(
        'counters',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant<String>('{}'),
      ).withConverter<Map<String, Object?>>($HosStatesTable.$convertercounters);
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, Object?>, String> recap =
      GeneratedColumn<String>(
        'recap',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant<String>('{}'),
      ).withConverter<Map<String, Object?>>($HosStatesTable.$converterrecap);
  static const VerificationMeta _policyVersionIdMeta = const VerificationMeta('policyVersionId');
  @override
  late final GeneratedColumn<String> policyVersionId = GeneratedColumn<String>(
    'policy_version_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [driverId, computedAt, counters, recap, policyVersionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hos_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<HosStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('driver_id')) {
      context.handle(
        _driverIdMeta,
        driverId.isAcceptableOrUnknown(data['driver_id']!, _driverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_driverIdMeta);
    }
    if (data.containsKey('computed_at')) {
      context.handle(
        _computedAtMeta,
        computedAt.isAcceptableOrUnknown(data['computed_at']!, _computedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_computedAtMeta);
    }
    if (data.containsKey('policy_version_id')) {
      context.handle(
        _policyVersionIdMeta,
        policyVersionId.isAcceptableOrUnknown(data['policy_version_id']!, _policyVersionIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {driverId};
  @override
  HosStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HosStateRow(
      driverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}driver_id'],
      )!,
      computedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}computed_at'],
      )!,
      counters: $HosStatesTable.$convertercounters.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}counters'])!,
      ),
      recap: $HosStatesTable.$converterrecap.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}recap'])!,
      ),
      policyVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}policy_version_id'],
      ),
    );
  }

  @override
  $HosStatesTable createAlias(String alias) {
    return $HosStatesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Map<String, Object?>, String, Object?> $convertercounters =
      const JsonMapConverter();
  static JsonTypeConverter2<Map<String, Object?>, String, Object?> $converterrecap =
      const JsonMapConverter();
}

class HosStateRow extends DataClass implements Insertable<HosStateRow> {
  final String driverId;
  final DateTime computedAt;
  final Map<String, Object?> counters;
  final Map<String, Object?> recap;
  final String? policyVersionId;
  const HosStateRow({
    required this.driverId,
    required this.computedAt,
    required this.counters,
    required this.recap,
    this.policyVersionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['driver_id'] = Variable<String>(driverId);
    map['computed_at'] = Variable<DateTime>(computedAt);
    {
      map['counters'] = Variable<String>($HosStatesTable.$convertercounters.toSql(counters));
    }
    {
      map['recap'] = Variable<String>($HosStatesTable.$converterrecap.toSql(recap));
    }
    if (!nullToAbsent || policyVersionId != null) {
      map['policy_version_id'] = Variable<String>(policyVersionId);
    }
    return map;
  }

  HosStatesCompanion toCompanion(bool nullToAbsent) {
    return HosStatesCompanion(
      driverId: Value(driverId),
      computedAt: Value(computedAt),
      counters: Value(counters),
      recap: Value(recap),
      policyVersionId: policyVersionId == null && nullToAbsent
          ? const Value.absent()
          : Value(policyVersionId),
    );
  }

  factory HosStateRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HosStateRow(
      driverId: serializer.fromJson<String>(json['driverId']),
      computedAt: serializer.fromJson<DateTime>(json['computedAt']),
      counters: $HosStatesTable.$convertercounters.fromJson(
        serializer.fromJson<Object?>(json['counters']),
      ),
      recap: $HosStatesTable.$converterrecap.fromJson(serializer.fromJson<Object?>(json['recap'])),
      policyVersionId: serializer.fromJson<String?>(json['policyVersionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'driverId': serializer.toJson<String>(driverId),
      'computedAt': serializer.toJson<DateTime>(computedAt),
      'counters': serializer.toJson<Object?>($HosStatesTable.$convertercounters.toJson(counters)),
      'recap': serializer.toJson<Object?>($HosStatesTable.$converterrecap.toJson(recap)),
      'policyVersionId': serializer.toJson<String?>(policyVersionId),
    };
  }

  HosStateRow copyWith({
    String? driverId,
    DateTime? computedAt,
    Map<String, Object?>? counters,
    Map<String, Object?>? recap,
    Value<String?> policyVersionId = const Value.absent(),
  }) => HosStateRow(
    driverId: driverId ?? this.driverId,
    computedAt: computedAt ?? this.computedAt,
    counters: counters ?? this.counters,
    recap: recap ?? this.recap,
    policyVersionId: policyVersionId.present ? policyVersionId.value : this.policyVersionId,
  );
  HosStateRow copyWithCompanion(HosStatesCompanion data) {
    return HosStateRow(
      driverId: data.driverId.present ? data.driverId.value : this.driverId,
      computedAt: data.computedAt.present ? data.computedAt.value : this.computedAt,
      counters: data.counters.present ? data.counters.value : this.counters,
      recap: data.recap.present ? data.recap.value : this.recap,
      policyVersionId: data.policyVersionId.present
          ? data.policyVersionId.value
          : this.policyVersionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HosStateRow(')
          ..write('driverId: $driverId, ')
          ..write('computedAt: $computedAt, ')
          ..write('counters: $counters, ')
          ..write('recap: $recap, ')
          ..write('policyVersionId: $policyVersionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(driverId, computedAt, counters, recap, policyVersionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HosStateRow &&
          other.driverId == this.driverId &&
          other.computedAt == this.computedAt &&
          other.counters == this.counters &&
          other.recap == this.recap &&
          other.policyVersionId == this.policyVersionId);
}

class HosStatesCompanion extends UpdateCompanion<HosStateRow> {
  final Value<String> driverId;
  final Value<DateTime> computedAt;
  final Value<Map<String, Object?>> counters;
  final Value<Map<String, Object?>> recap;
  final Value<String?> policyVersionId;
  final Value<int> rowid;
  const HosStatesCompanion({
    this.driverId = const Value.absent(),
    this.computedAt = const Value.absent(),
    this.counters = const Value.absent(),
    this.recap = const Value.absent(),
    this.policyVersionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HosStatesCompanion.insert({
    required String driverId,
    required DateTime computedAt,
    this.counters = const Value.absent(),
    this.recap = const Value.absent(),
    this.policyVersionId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : driverId = Value(driverId),
       computedAt = Value(computedAt);
  static Insertable<HosStateRow> custom({
    Expression<String>? driverId,
    Expression<DateTime>? computedAt,
    Expression<String>? counters,
    Expression<String>? recap,
    Expression<String>? policyVersionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (driverId != null) 'driver_id': driverId,
      if (computedAt != null) 'computed_at': computedAt,
      if (counters != null) 'counters': counters,
      if (recap != null) 'recap': recap,
      if (policyVersionId != null) 'policy_version_id': policyVersionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HosStatesCompanion copyWith({
    Value<String>? driverId,
    Value<DateTime>? computedAt,
    Value<Map<String, Object?>>? counters,
    Value<Map<String, Object?>>? recap,
    Value<String?>? policyVersionId,
    Value<int>? rowid,
  }) {
    return HosStatesCompanion(
      driverId: driverId ?? this.driverId,
      computedAt: computedAt ?? this.computedAt,
      counters: counters ?? this.counters,
      recap: recap ?? this.recap,
      policyVersionId: policyVersionId ?? this.policyVersionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (driverId.present) {
      map['driver_id'] = Variable<String>(driverId.value);
    }
    if (computedAt.present) {
      map['computed_at'] = Variable<DateTime>(computedAt.value);
    }
    if (counters.present) {
      map['counters'] = Variable<String>($HosStatesTable.$convertercounters.toSql(counters.value));
    }
    if (recap.present) {
      map['recap'] = Variable<String>($HosStatesTable.$converterrecap.toSql(recap.value));
    }
    if (policyVersionId.present) {
      map['policy_version_id'] = Variable<String>(policyVersionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HosStatesCompanion(')
          ..write('driverId: $driverId, ')
          ..write('computedAt: $computedAt, ')
          ..write('counters: $counters, ')
          ..write('recap: $recap, ')
          ..write('policyVersionId: $policyVersionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HosPoliciesTable extends HosPolicies with TableInfo<$HosPoliciesTable, HosPolicyRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HosPoliciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _versionIdMeta = const VerificationMeta('versionId');
  @override
  late final GeneratedColumn<String> versionId = GeneratedColumn<String>(
    'version_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectiveFromMeta = const VerificationMeta('effectiveFrom');
  @override
  late final GeneratedColumn<DateTime> effectiveFrom = GeneratedColumn<DateTime>(
    'effective_from',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [versionId, effectiveFrom, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hos_policy';
  @override
  VerificationContext validateIntegrity(
    Insertable<HosPolicyRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('version_id')) {
      context.handle(
        _versionIdMeta,
        versionId.isAcceptableOrUnknown(data['version_id']!, _versionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_versionIdMeta);
    }
    if (data.containsKey('effective_from')) {
      context.handle(
        _effectiveFromMeta,
        effectiveFrom.isAcceptableOrUnknown(data['effective_from']!, _effectiveFromMeta),
      );
    } else if (isInserting) {
      context.missing(_effectiveFromMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta, payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {versionId};
  @override
  HosPolicyRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HosPolicyRow(
      versionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version_id'],
      )!,
      effectiveFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}effective_from'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $HosPoliciesTable createAlias(String alias) {
    return $HosPoliciesTable(attachedDatabase, alias);
  }
}

class HosPolicyRow extends DataClass implements Insertable<HosPolicyRow> {
  final String versionId;
  final DateTime effectiveFrom;

  /// `hos_engine` `Policy` JSON — pull da almashtiriladi (M36, birinchi qadam).
  final String payload;
  const HosPolicyRow({required this.versionId, required this.effectiveFrom, required this.payload});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['version_id'] = Variable<String>(versionId);
    map['effective_from'] = Variable<DateTime>(effectiveFrom);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  HosPoliciesCompanion toCompanion(bool nullToAbsent) {
    return HosPoliciesCompanion(
      versionId: Value(versionId),
      effectiveFrom: Value(effectiveFrom),
      payload: Value(payload),
    );
  }

  factory HosPolicyRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HosPolicyRow(
      versionId: serializer.fromJson<String>(json['versionId']),
      effectiveFrom: serializer.fromJson<DateTime>(json['effectiveFrom']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'versionId': serializer.toJson<String>(versionId),
      'effectiveFrom': serializer.toJson<DateTime>(effectiveFrom),
      'payload': serializer.toJson<String>(payload),
    };
  }

  HosPolicyRow copyWith({String? versionId, DateTime? effectiveFrom, String? payload}) =>
      HosPolicyRow(
        versionId: versionId ?? this.versionId,
        effectiveFrom: effectiveFrom ?? this.effectiveFrom,
        payload: payload ?? this.payload,
      );
  HosPolicyRow copyWithCompanion(HosPoliciesCompanion data) {
    return HosPolicyRow(
      versionId: data.versionId.present ? data.versionId.value : this.versionId,
      effectiveFrom: data.effectiveFrom.present ? data.effectiveFrom.value : this.effectiveFrom,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HosPolicyRow(')
          ..write('versionId: $versionId, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(versionId, effectiveFrom, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HosPolicyRow &&
          other.versionId == this.versionId &&
          other.effectiveFrom == this.effectiveFrom &&
          other.payload == this.payload);
}

class HosPoliciesCompanion extends UpdateCompanion<HosPolicyRow> {
  final Value<String> versionId;
  final Value<DateTime> effectiveFrom;
  final Value<String> payload;
  final Value<int> rowid;
  const HosPoliciesCompanion({
    this.versionId = const Value.absent(),
    this.effectiveFrom = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HosPoliciesCompanion.insert({
    required String versionId,
    required DateTime effectiveFrom,
    required String payload,
    this.rowid = const Value.absent(),
  }) : versionId = Value(versionId),
       effectiveFrom = Value(effectiveFrom),
       payload = Value(payload);
  static Insertable<HosPolicyRow> custom({
    Expression<String>? versionId,
    Expression<DateTime>? effectiveFrom,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (versionId != null) 'version_id': versionId,
      if (effectiveFrom != null) 'effective_from': effectiveFrom,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HosPoliciesCompanion copyWith({
    Value<String>? versionId,
    Value<DateTime>? effectiveFrom,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return HosPoliciesCompanion(
      versionId: versionId ?? this.versionId,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (versionId.present) {
      map['version_id'] = Variable<String>(versionId.value);
    }
    if (effectiveFrom.present) {
      map['effective_from'] = Variable<DateTime>(effectiveFrom.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HosPoliciesCompanion(')
          ..write('versionId: $versionId, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DvirDraftsTable extends DvirDrafts with TableInfo<$DvirDraftsTable, DvirDraftRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DvirDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientIdMeta = const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<String> unitId = GeneratedColumn<String>(
    'unit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, Object?>, String> defects =
      GeneratedColumn<String>(
        'defects',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant<String>('{}'),
      ).withConverter<Map<String, Object?>>($DvirDraftsTable.$converterdefects);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> trailerIds =
      GeneratedColumn<String>(
        'trailer_ids',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant<String>('[]'),
      ).withConverter<List<String>>($DvirDraftsTable.$convertertrailerIds);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _driverSignatureKeyMeta = const VerificationMeta(
    'driverSignatureKey',
  );
  @override
  late final GeneratedColumn<String> driverSignatureKey = GeneratedColumn<String>(
    'driver_signature_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> localPhotoPaths =
      GeneratedColumn<String>(
        'local_photo_paths',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant<String>('[]'),
      ).withConverter<List<String>>($DvirDraftsTable.$converterlocalPhotoPaths);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('draft'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    clientId,
    unitId,
    type,
    defects,
    trailerIds,
    notes,
    driverSignatureKey,
    localPhotoPaths,
    state,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dvir_drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<DvirDraftRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('unit_id')) {
      context.handle(_unitIdMeta, unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta));
    } else if (isInserting) {
      context.missing(_unitIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(_typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('driver_signature_key')) {
      context.handle(
        _driverSignatureKeyMeta,
        driverSignatureKey.isAcceptableOrUnknown(
          data['driver_signature_key']!,
          _driverSignatureKeyMeta,
        ),
      );
    }
    if (data.containsKey('state')) {
      context.handle(_stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientId};
  @override
  DvirDraftRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DvirDraftRow(
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      unitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_id'],
      )!,
      type: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      defects: $DvirDraftsTable.$converterdefects.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}defects'])!,
      ),
      trailerIds: $DvirDraftsTable.$convertertrailerIds.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}trailer_ids'],
        )!,
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      driverSignatureKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}driver_signature_key'],
      ),
      localPhotoPaths: $DvirDraftsTable.$converterlocalPhotoPaths.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}local_photo_paths'],
        )!,
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DvirDraftsTable createAlias(String alias) {
    return $DvirDraftsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Map<String, Object?>, String, Object?> $converterdefects =
      const JsonMapConverter();
  static JsonTypeConverter2<List<String>, String, Object?> $convertertrailerIds =
      const StringListConverter();
  static JsonTypeConverter2<List<String>, String, Object?> $converterlocalPhotoPaths =
      const StringListConverter();
}

class DvirDraftRow extends DataClass implements Insertable<DvirDraftRow> {
  final String clientId;
  final String unitId;

  /// `pre_trip`/`post_trip`.
  final String type;

  /// Aniqlangan nuqsonlar ro'yxati — JSON.
  final Map<String, Object?> defects;
  final List<String> trailerIds;
  final String? notes;

  /// Object storage kaliti (imzo yuklangandan keyin to'ladi).
  final String? driverSignatureKey;
  final List<String> localPhotoPaths;

  /// `draft`/`queued`/`sent`.
  final String state;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DvirDraftRow({
    required this.clientId,
    required this.unitId,
    required this.type,
    required this.defects,
    required this.trailerIds,
    this.notes,
    this.driverSignatureKey,
    required this.localPhotoPaths,
    required this.state,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_id'] = Variable<String>(clientId);
    map['unit_id'] = Variable<String>(unitId);
    map['type'] = Variable<String>(type);
    {
      map['defects'] = Variable<String>($DvirDraftsTable.$converterdefects.toSql(defects));
    }
    {
      map['trailer_ids'] = Variable<String>(
        $DvirDraftsTable.$convertertrailerIds.toSql(trailerIds),
      );
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || driverSignatureKey != null) {
      map['driver_signature_key'] = Variable<String>(driverSignatureKey);
    }
    {
      map['local_photo_paths'] = Variable<String>(
        $DvirDraftsTable.$converterlocalPhotoPaths.toSql(localPhotoPaths),
      );
    }
    map['state'] = Variable<String>(state);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DvirDraftsCompanion toCompanion(bool nullToAbsent) {
    return DvirDraftsCompanion(
      clientId: Value(clientId),
      unitId: Value(unitId),
      type: Value(type),
      defects: Value(defects),
      trailerIds: Value(trailerIds),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      driverSignatureKey: driverSignatureKey == null && nullToAbsent
          ? const Value.absent()
          : Value(driverSignatureKey),
      localPhotoPaths: Value(localPhotoPaths),
      state: Value(state),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DvirDraftRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DvirDraftRow(
      clientId: serializer.fromJson<String>(json['clientId']),
      unitId: serializer.fromJson<String>(json['unitId']),
      type: serializer.fromJson<String>(json['type']),
      defects: $DvirDraftsTable.$converterdefects.fromJson(
        serializer.fromJson<Object?>(json['defects']),
      ),
      trailerIds: $DvirDraftsTable.$convertertrailerIds.fromJson(
        serializer.fromJson<Object?>(json['trailerIds']),
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      driverSignatureKey: serializer.fromJson<String?>(json['driverSignatureKey']),
      localPhotoPaths: $DvirDraftsTable.$converterlocalPhotoPaths.fromJson(
        serializer.fromJson<Object?>(json['localPhotoPaths']),
      ),
      state: serializer.fromJson<String>(json['state']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientId': serializer.toJson<String>(clientId),
      'unitId': serializer.toJson<String>(unitId),
      'type': serializer.toJson<String>(type),
      'defects': serializer.toJson<Object?>($DvirDraftsTable.$converterdefects.toJson(defects)),
      'trailerIds': serializer.toJson<Object?>(
        $DvirDraftsTable.$convertertrailerIds.toJson(trailerIds),
      ),
      'notes': serializer.toJson<String?>(notes),
      'driverSignatureKey': serializer.toJson<String?>(driverSignatureKey),
      'localPhotoPaths': serializer.toJson<Object?>(
        $DvirDraftsTable.$converterlocalPhotoPaths.toJson(localPhotoPaths),
      ),
      'state': serializer.toJson<String>(state),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DvirDraftRow copyWith({
    String? clientId,
    String? unitId,
    String? type,
    Map<String, Object?>? defects,
    List<String>? trailerIds,
    Value<String?> notes = const Value.absent(),
    Value<String?> driverSignatureKey = const Value.absent(),
    List<String>? localPhotoPaths,
    String? state,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DvirDraftRow(
    clientId: clientId ?? this.clientId,
    unitId: unitId ?? this.unitId,
    type: type ?? this.type,
    defects: defects ?? this.defects,
    trailerIds: trailerIds ?? this.trailerIds,
    notes: notes.present ? notes.value : this.notes,
    driverSignatureKey: driverSignatureKey.present
        ? driverSignatureKey.value
        : this.driverSignatureKey,
    localPhotoPaths: localPhotoPaths ?? this.localPhotoPaths,
    state: state ?? this.state,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DvirDraftRow copyWithCompanion(DvirDraftsCompanion data) {
    return DvirDraftRow(
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      type: data.type.present ? data.type.value : this.type,
      defects: data.defects.present ? data.defects.value : this.defects,
      trailerIds: data.trailerIds.present ? data.trailerIds.value : this.trailerIds,
      notes: data.notes.present ? data.notes.value : this.notes,
      driverSignatureKey: data.driverSignatureKey.present
          ? data.driverSignatureKey.value
          : this.driverSignatureKey,
      localPhotoPaths: data.localPhotoPaths.present
          ? data.localPhotoPaths.value
          : this.localPhotoPaths,
      state: data.state.present ? data.state.value : this.state,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DvirDraftRow(')
          ..write('clientId: $clientId, ')
          ..write('unitId: $unitId, ')
          ..write('type: $type, ')
          ..write('defects: $defects, ')
          ..write('trailerIds: $trailerIds, ')
          ..write('notes: $notes, ')
          ..write('driverSignatureKey: $driverSignatureKey, ')
          ..write('localPhotoPaths: $localPhotoPaths, ')
          ..write('state: $state, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    clientId,
    unitId,
    type,
    defects,
    trailerIds,
    notes,
    driverSignatureKey,
    localPhotoPaths,
    state,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DvirDraftRow &&
          other.clientId == this.clientId &&
          other.unitId == this.unitId &&
          other.type == this.type &&
          other.defects == this.defects &&
          other.trailerIds == this.trailerIds &&
          other.notes == this.notes &&
          other.driverSignatureKey == this.driverSignatureKey &&
          other.localPhotoPaths == this.localPhotoPaths &&
          other.state == this.state &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DvirDraftsCompanion extends UpdateCompanion<DvirDraftRow> {
  final Value<String> clientId;
  final Value<String> unitId;
  final Value<String> type;
  final Value<Map<String, Object?>> defects;
  final Value<List<String>> trailerIds;
  final Value<String?> notes;
  final Value<String?> driverSignatureKey;
  final Value<List<String>> localPhotoPaths;
  final Value<String> state;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DvirDraftsCompanion({
    this.clientId = const Value.absent(),
    this.unitId = const Value.absent(),
    this.type = const Value.absent(),
    this.defects = const Value.absent(),
    this.trailerIds = const Value.absent(),
    this.notes = const Value.absent(),
    this.driverSignatureKey = const Value.absent(),
    this.localPhotoPaths = const Value.absent(),
    this.state = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DvirDraftsCompanion.insert({
    required String clientId,
    required String unitId,
    required String type,
    this.defects = const Value.absent(),
    this.trailerIds = const Value.absent(),
    this.notes = const Value.absent(),
    this.driverSignatureKey = const Value.absent(),
    this.localPhotoPaths = const Value.absent(),
    this.state = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : clientId = Value(clientId),
       unitId = Value(unitId),
       type = Value(type),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DvirDraftRow> custom({
    Expression<String>? clientId,
    Expression<String>? unitId,
    Expression<String>? type,
    Expression<String>? defects,
    Expression<String>? trailerIds,
    Expression<String>? notes,
    Expression<String>? driverSignatureKey,
    Expression<String>? localPhotoPaths,
    Expression<String>? state,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientId != null) 'client_id': clientId,
      if (unitId != null) 'unit_id': unitId,
      if (type != null) 'type': type,
      if (defects != null) 'defects': defects,
      if (trailerIds != null) 'trailer_ids': trailerIds,
      if (notes != null) 'notes': notes,
      if (driverSignatureKey != null) 'driver_signature_key': driverSignatureKey,
      if (localPhotoPaths != null) 'local_photo_paths': localPhotoPaths,
      if (state != null) 'state': state,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DvirDraftsCompanion copyWith({
    Value<String>? clientId,
    Value<String>? unitId,
    Value<String>? type,
    Value<Map<String, Object?>>? defects,
    Value<List<String>>? trailerIds,
    Value<String?>? notes,
    Value<String?>? driverSignatureKey,
    Value<List<String>>? localPhotoPaths,
    Value<String>? state,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DvirDraftsCompanion(
      clientId: clientId ?? this.clientId,
      unitId: unitId ?? this.unitId,
      type: type ?? this.type,
      defects: defects ?? this.defects,
      trailerIds: trailerIds ?? this.trailerIds,
      notes: notes ?? this.notes,
      driverSignatureKey: driverSignatureKey ?? this.driverSignatureKey,
      localPhotoPaths: localPhotoPaths ?? this.localPhotoPaths,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (unitId.present) {
      map['unit_id'] = Variable<String>(unitId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (defects.present) {
      map['defects'] = Variable<String>($DvirDraftsTable.$converterdefects.toSql(defects.value));
    }
    if (trailerIds.present) {
      map['trailer_ids'] = Variable<String>(
        $DvirDraftsTable.$convertertrailerIds.toSql(trailerIds.value),
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (driverSignatureKey.present) {
      map['driver_signature_key'] = Variable<String>(driverSignatureKey.value);
    }
    if (localPhotoPaths.present) {
      map['local_photo_paths'] = Variable<String>(
        $DvirDraftsTable.$converterlocalPhotoPaths.toSql(localPhotoPaths.value),
      );
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DvirDraftsCompanion(')
          ..write('clientId: $clientId, ')
          ..write('unitId: $unitId, ')
          ..write('type: $type, ')
          ..write('defects: $defects, ')
          ..write('trailerIds: $trailerIds, ')
          ..write('notes: $notes, ')
          ..write('driverSignatureKey: $driverSignatureKey, ')
          ..write('localPhotoPaths: $localPhotoPaths, ')
          ..write('state: $state, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DvirReportsTable extends DvirReports with TableInfo<$DvirReportsTable, DvirReportRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DvirReportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<String> unitId = GeneratedColumn<String>(
    'unit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hasCriticalDefectMeta = const VerificationMeta(
    'hasCriticalDefect',
  );
  @override
  late final GeneratedColumn<bool> hasCriticalDefect = GeneratedColumn<bool>(
    'has_critical_defect',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_critical_defect" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(false),
  );
  static const VerificationMeta _outOfServiceMeta = const VerificationMeta('outOfService');
  @override
  late final GeneratedColumn<bool> outOfService = GeneratedColumn<bool>(
    'out_of_service',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("out_of_service" IN (0, 1))'),
    defaultValue: const Constant<bool>(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, Object?>, String> payload =
      GeneratedColumn<String>(
        'payload',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant<String>('{}'),
      ).withConverter<Map<String, Object?>>($DvirReportsTable.$converterpayload);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    status,
    kind,
    type,
    unitId,
    createdAt,
    hasCriticalDefect,
    outOfService,
    payload,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dvir_reports';
  @override
  VerificationContext validateIntegrity(
    Insertable<DvirReportRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(_kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('type')) {
      context.handle(_typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('unit_id')) {
      context.handle(_unitIdMeta, unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta));
    } else if (isInserting) {
      context.missing(_unitIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('has_critical_defect')) {
      context.handle(
        _hasCriticalDefectMeta,
        hasCriticalDefect.isAcceptableOrUnknown(
          data['has_critical_defect']!,
          _hasCriticalDefectMeta,
        ),
      );
    }
    if (data.containsKey('out_of_service')) {
      context.handle(
        _outOfServiceMeta,
        outOfService.isAcceptableOrUnknown(data['out_of_service']!, _outOfServiceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DvirReportRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DvirReportRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      kind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      type: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      unitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      hasCriticalDefect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_critical_defect'],
      )!,
      outOfService: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}out_of_service'],
      )!,
      payload: $DvirReportsTable.$converterpayload.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      ),
    );
  }

  @override
  $DvirReportsTable createAlias(String alias) {
    return $DvirReportsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Map<String, Object?>, String, Object?> $converterpayload =
      const JsonMapConverter();
}

class DvirReportRow extends DataClass implements Insertable<DvirReportRow> {
  final String id;

  /// `open`/`resolved`/`certified`.
  final String status;

  /// `driver`/`mechanic`.
  final String kind;

  /// `pre_trip`/`post_trip`.
  final String type;
  final String unitId;
  final DateTime createdAt;
  final bool hasCriticalDefect;
  final bool outOfService;

  /// To'liq server javobi — ekranga chiqarish uchun.
  final Map<String, Object?> payload;
  const DvirReportRow({
    required this.id,
    required this.status,
    required this.kind,
    required this.type,
    required this.unitId,
    required this.createdAt,
    required this.hasCriticalDefect,
    required this.outOfService,
    required this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['status'] = Variable<String>(status);
    map['kind'] = Variable<String>(kind);
    map['type'] = Variable<String>(type);
    map['unit_id'] = Variable<String>(unitId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['has_critical_defect'] = Variable<bool>(hasCriticalDefect);
    map['out_of_service'] = Variable<bool>(outOfService);
    {
      map['payload'] = Variable<String>($DvirReportsTable.$converterpayload.toSql(payload));
    }
    return map;
  }

  DvirReportsCompanion toCompanion(bool nullToAbsent) {
    return DvirReportsCompanion(
      id: Value(id),
      status: Value(status),
      kind: Value(kind),
      type: Value(type),
      unitId: Value(unitId),
      createdAt: Value(createdAt),
      hasCriticalDefect: Value(hasCriticalDefect),
      outOfService: Value(outOfService),
      payload: Value(payload),
    );
  }

  factory DvirReportRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DvirReportRow(
      id: serializer.fromJson<String>(json['id']),
      status: serializer.fromJson<String>(json['status']),
      kind: serializer.fromJson<String>(json['kind']),
      type: serializer.fromJson<String>(json['type']),
      unitId: serializer.fromJson<String>(json['unitId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      hasCriticalDefect: serializer.fromJson<bool>(json['hasCriticalDefect']),
      outOfService: serializer.fromJson<bool>(json['outOfService']),
      payload: $DvirReportsTable.$converterpayload.fromJson(
        serializer.fromJson<Object?>(json['payload']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'status': serializer.toJson<String>(status),
      'kind': serializer.toJson<String>(kind),
      'type': serializer.toJson<String>(type),
      'unitId': serializer.toJson<String>(unitId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'hasCriticalDefect': serializer.toJson<bool>(hasCriticalDefect),
      'outOfService': serializer.toJson<bool>(outOfService),
      'payload': serializer.toJson<Object?>($DvirReportsTable.$converterpayload.toJson(payload)),
    };
  }

  DvirReportRow copyWith({
    String? id,
    String? status,
    String? kind,
    String? type,
    String? unitId,
    DateTime? createdAt,
    bool? hasCriticalDefect,
    bool? outOfService,
    Map<String, Object?>? payload,
  }) => DvirReportRow(
    id: id ?? this.id,
    status: status ?? this.status,
    kind: kind ?? this.kind,
    type: type ?? this.type,
    unitId: unitId ?? this.unitId,
    createdAt: createdAt ?? this.createdAt,
    hasCriticalDefect: hasCriticalDefect ?? this.hasCriticalDefect,
    outOfService: outOfService ?? this.outOfService,
    payload: payload ?? this.payload,
  );
  DvirReportRow copyWithCompanion(DvirReportsCompanion data) {
    return DvirReportRow(
      id: data.id.present ? data.id.value : this.id,
      status: data.status.present ? data.status.value : this.status,
      kind: data.kind.present ? data.kind.value : this.kind,
      type: data.type.present ? data.type.value : this.type,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      hasCriticalDefect: data.hasCriticalDefect.present
          ? data.hasCriticalDefect.value
          : this.hasCriticalDefect,
      outOfService: data.outOfService.present ? data.outOfService.value : this.outOfService,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DvirReportRow(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('kind: $kind, ')
          ..write('type: $type, ')
          ..write('unitId: $unitId, ')
          ..write('createdAt: $createdAt, ')
          ..write('hasCriticalDefect: $hasCriticalDefect, ')
          ..write('outOfService: $outOfService, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    status,
    kind,
    type,
    unitId,
    createdAt,
    hasCriticalDefect,
    outOfService,
    payload,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DvirReportRow &&
          other.id == this.id &&
          other.status == this.status &&
          other.kind == this.kind &&
          other.type == this.type &&
          other.unitId == this.unitId &&
          other.createdAt == this.createdAt &&
          other.hasCriticalDefect == this.hasCriticalDefect &&
          other.outOfService == this.outOfService &&
          other.payload == this.payload);
}

class DvirReportsCompanion extends UpdateCompanion<DvirReportRow> {
  final Value<String> id;
  final Value<String> status;
  final Value<String> kind;
  final Value<String> type;
  final Value<String> unitId;
  final Value<DateTime> createdAt;
  final Value<bool> hasCriticalDefect;
  final Value<bool> outOfService;
  final Value<Map<String, Object?>> payload;
  final Value<int> rowid;
  const DvirReportsCompanion({
    this.id = const Value.absent(),
    this.status = const Value.absent(),
    this.kind = const Value.absent(),
    this.type = const Value.absent(),
    this.unitId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.hasCriticalDefect = const Value.absent(),
    this.outOfService = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DvirReportsCompanion.insert({
    required String id,
    required String status,
    required String kind,
    required String type,
    required String unitId,
    required DateTime createdAt,
    this.hasCriticalDefect = const Value.absent(),
    this.outOfService = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       status = Value(status),
       kind = Value(kind),
       type = Value(type),
       unitId = Value(unitId),
       createdAt = Value(createdAt);
  static Insertable<DvirReportRow> custom({
    Expression<String>? id,
    Expression<String>? status,
    Expression<String>? kind,
    Expression<String>? type,
    Expression<String>? unitId,
    Expression<DateTime>? createdAt,
    Expression<bool>? hasCriticalDefect,
    Expression<bool>? outOfService,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (status != null) 'status': status,
      if (kind != null) 'kind': kind,
      if (type != null) 'type': type,
      if (unitId != null) 'unit_id': unitId,
      if (createdAt != null) 'created_at': createdAt,
      if (hasCriticalDefect != null) 'has_critical_defect': hasCriticalDefect,
      if (outOfService != null) 'out_of_service': outOfService,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DvirReportsCompanion copyWith({
    Value<String>? id,
    Value<String>? status,
    Value<String>? kind,
    Value<String>? type,
    Value<String>? unitId,
    Value<DateTime>? createdAt,
    Value<bool>? hasCriticalDefect,
    Value<bool>? outOfService,
    Value<Map<String, Object?>>? payload,
    Value<int>? rowid,
  }) {
    return DvirReportsCompanion(
      id: id ?? this.id,
      status: status ?? this.status,
      kind: kind ?? this.kind,
      type: type ?? this.type,
      unitId: unitId ?? this.unitId,
      createdAt: createdAt ?? this.createdAt,
      hasCriticalDefect: hasCriticalDefect ?? this.hasCriticalDefect,
      outOfService: outOfService ?? this.outOfService,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (unitId.present) {
      map['unit_id'] = Variable<String>(unitId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (hasCriticalDefect.present) {
      map['has_critical_defect'] = Variable<bool>(hasCriticalDefect.value);
    }
    if (outOfService.present) {
      map['out_of_service'] = Variable<bool>(outOfService.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>($DvirReportsTable.$converterpayload.toSql(payload.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DvirReportsCompanion(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('kind: $kind, ')
          ..write('type: $type, ')
          ..write('unitId: $unitId, ')
          ..write('createdAt: $createdAt, ')
          ..write('hasCriticalDefect: $hasCriticalDefect, ')
          ..write('outOfService: $outOfService, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FilesQueueTable extends FilesQueue with TableInfo<$FilesQueueTable, FileQueueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FilesQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentTypeMeta = const VerificationMeta('contentType');
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta('sizeBytes');
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _presignedKeyMeta = const VerificationMeta('presignedKey');
  @override
  late final GeneratedColumn<String> presignedKey = GeneratedColumn<String>(
    'presigned_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uploadUrlMeta = const VerificationMeta('uploadUrl');
  @override
  late final GeneratedColumn<String> uploadUrl = GeneratedColumn<String>(
    'upload_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta('expiresAt');
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('pending'),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uploadedAtMeta = const VerificationMeta('uploadedAt');
  @override
  late final GeneratedColumn<DateTime> uploadedAt = GeneratedColumn<DateTime>(
    'uploaded_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    localPath,
    kind,
    contentType,
    sizeBytes,
    presignedKey,
    uploadUrl,
    expiresAt,
    state,
    attempts,
    createdAt,
    uploadedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'files_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<FileQueueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(_kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(data['content_type']!, _contentTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_contentTypeMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('presigned_key')) {
      context.handle(
        _presignedKeyMeta,
        presignedKey.isAcceptableOrUnknown(data['presigned_key']!, _presignedKeyMeta),
      );
    }
    if (data.containsKey('upload_url')) {
      context.handle(
        _uploadUrlMeta,
        uploadUrl.isAcceptableOrUnknown(data['upload_url']!, _uploadUrlMeta),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(_stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('uploaded_at')) {
      context.handle(
        _uploadedAtMeta,
        uploadedAt.isAcceptableOrUnknown(data['uploaded_at']!, _uploadedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FileQueueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FileQueueRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      kind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      presignedKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}presigned_key'],
      ),
      uploadUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upload_url'],
      ),
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      uploadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}uploaded_at'],
      ),
    );
  }

  @override
  $FilesQueueTable createAlias(String alias) {
    return $FilesQueueTable(attachedDatabase, alias);
  }
}

class FileQueueRow extends DataClass implements Insertable<FileQueueRow> {
  final int id;
  final String localPath;

  /// `dvir_photo`/`signature`/`chat_file`/`feedback`.
  final String kind;
  final String contentType;
  final int sizeBytes;
  final String? presignedKey;
  final String? uploadUrl;
  final DateTime? expiresAt;

  /// `pending`/`uploading`/`uploaded`/`failed`.
  final String state;
  final int attempts;
  final DateTime createdAt;

  /// Retention: yuklangandan keyin 7 kun saqlanadi (§5.2).
  final DateTime? uploadedAt;
  const FileQueueRow({
    required this.id,
    required this.localPath,
    required this.kind,
    required this.contentType,
    required this.sizeBytes,
    this.presignedKey,
    this.uploadUrl,
    this.expiresAt,
    required this.state,
    required this.attempts,
    required this.createdAt,
    this.uploadedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['local_path'] = Variable<String>(localPath);
    map['kind'] = Variable<String>(kind);
    map['content_type'] = Variable<String>(contentType);
    map['size_bytes'] = Variable<int>(sizeBytes);
    if (!nullToAbsent || presignedKey != null) {
      map['presigned_key'] = Variable<String>(presignedKey);
    }
    if (!nullToAbsent || uploadUrl != null) {
      map['upload_url'] = Variable<String>(uploadUrl);
    }
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    map['state'] = Variable<String>(state);
    map['attempts'] = Variable<int>(attempts);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || uploadedAt != null) {
      map['uploaded_at'] = Variable<DateTime>(uploadedAt);
    }
    return map;
  }

  FilesQueueCompanion toCompanion(bool nullToAbsent) {
    return FilesQueueCompanion(
      id: Value(id),
      localPath: Value(localPath),
      kind: Value(kind),
      contentType: Value(contentType),
      sizeBytes: Value(sizeBytes),
      presignedKey: presignedKey == null && nullToAbsent
          ? const Value.absent()
          : Value(presignedKey),
      uploadUrl: uploadUrl == null && nullToAbsent ? const Value.absent() : Value(uploadUrl),
      expiresAt: expiresAt == null && nullToAbsent ? const Value.absent() : Value(expiresAt),
      state: Value(state),
      attempts: Value(attempts),
      createdAt: Value(createdAt),
      uploadedAt: uploadedAt == null && nullToAbsent ? const Value.absent() : Value(uploadedAt),
    );
  }

  factory FileQueueRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FileQueueRow(
      id: serializer.fromJson<int>(json['id']),
      localPath: serializer.fromJson<String>(json['localPath']),
      kind: serializer.fromJson<String>(json['kind']),
      contentType: serializer.fromJson<String>(json['contentType']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      presignedKey: serializer.fromJson<String?>(json['presignedKey']),
      uploadUrl: serializer.fromJson<String?>(json['uploadUrl']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
      state: serializer.fromJson<String>(json['state']),
      attempts: serializer.fromJson<int>(json['attempts']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      uploadedAt: serializer.fromJson<DateTime?>(json['uploadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'localPath': serializer.toJson<String>(localPath),
      'kind': serializer.toJson<String>(kind),
      'contentType': serializer.toJson<String>(contentType),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'presignedKey': serializer.toJson<String?>(presignedKey),
      'uploadUrl': serializer.toJson<String?>(uploadUrl),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
      'state': serializer.toJson<String>(state),
      'attempts': serializer.toJson<int>(attempts),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'uploadedAt': serializer.toJson<DateTime?>(uploadedAt),
    };
  }

  FileQueueRow copyWith({
    int? id,
    String? localPath,
    String? kind,
    String? contentType,
    int? sizeBytes,
    Value<String?> presignedKey = const Value.absent(),
    Value<String?> uploadUrl = const Value.absent(),
    Value<DateTime?> expiresAt = const Value.absent(),
    String? state,
    int? attempts,
    DateTime? createdAt,
    Value<DateTime?> uploadedAt = const Value.absent(),
  }) => FileQueueRow(
    id: id ?? this.id,
    localPath: localPath ?? this.localPath,
    kind: kind ?? this.kind,
    contentType: contentType ?? this.contentType,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    presignedKey: presignedKey.present ? presignedKey.value : this.presignedKey,
    uploadUrl: uploadUrl.present ? uploadUrl.value : this.uploadUrl,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
    state: state ?? this.state,
    attempts: attempts ?? this.attempts,
    createdAt: createdAt ?? this.createdAt,
    uploadedAt: uploadedAt.present ? uploadedAt.value : this.uploadedAt,
  );
  FileQueueRow copyWithCompanion(FilesQueueCompanion data) {
    return FileQueueRow(
      id: data.id.present ? data.id.value : this.id,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      kind: data.kind.present ? data.kind.value : this.kind,
      contentType: data.contentType.present ? data.contentType.value : this.contentType,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      presignedKey: data.presignedKey.present ? data.presignedKey.value : this.presignedKey,
      uploadUrl: data.uploadUrl.present ? data.uploadUrl.value : this.uploadUrl,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      state: data.state.present ? data.state.value : this.state,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      uploadedAt: data.uploadedAt.present ? data.uploadedAt.value : this.uploadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FileQueueRow(')
          ..write('id: $id, ')
          ..write('localPath: $localPath, ')
          ..write('kind: $kind, ')
          ..write('contentType: $contentType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('presignedKey: $presignedKey, ')
          ..write('uploadUrl: $uploadUrl, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('state: $state, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('uploadedAt: $uploadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    localPath,
    kind,
    contentType,
    sizeBytes,
    presignedKey,
    uploadUrl,
    expiresAt,
    state,
    attempts,
    createdAt,
    uploadedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FileQueueRow &&
          other.id == this.id &&
          other.localPath == this.localPath &&
          other.kind == this.kind &&
          other.contentType == this.contentType &&
          other.sizeBytes == this.sizeBytes &&
          other.presignedKey == this.presignedKey &&
          other.uploadUrl == this.uploadUrl &&
          other.expiresAt == this.expiresAt &&
          other.state == this.state &&
          other.attempts == this.attempts &&
          other.createdAt == this.createdAt &&
          other.uploadedAt == this.uploadedAt);
}

class FilesQueueCompanion extends UpdateCompanion<FileQueueRow> {
  final Value<int> id;
  final Value<String> localPath;
  final Value<String> kind;
  final Value<String> contentType;
  final Value<int> sizeBytes;
  final Value<String?> presignedKey;
  final Value<String?> uploadUrl;
  final Value<DateTime?> expiresAt;
  final Value<String> state;
  final Value<int> attempts;
  final Value<DateTime> createdAt;
  final Value<DateTime?> uploadedAt;
  const FilesQueueCompanion({
    this.id = const Value.absent(),
    this.localPath = const Value.absent(),
    this.kind = const Value.absent(),
    this.contentType = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.presignedKey = const Value.absent(),
    this.uploadUrl = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.state = const Value.absent(),
    this.attempts = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.uploadedAt = const Value.absent(),
  });
  FilesQueueCompanion.insert({
    this.id = const Value.absent(),
    required String localPath,
    required String kind,
    required String contentType,
    required int sizeBytes,
    this.presignedKey = const Value.absent(),
    this.uploadUrl = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.state = const Value.absent(),
    this.attempts = const Value.absent(),
    required DateTime createdAt,
    this.uploadedAt = const Value.absent(),
  }) : localPath = Value(localPath),
       kind = Value(kind),
       contentType = Value(contentType),
       sizeBytes = Value(sizeBytes),
       createdAt = Value(createdAt);
  static Insertable<FileQueueRow> custom({
    Expression<int>? id,
    Expression<String>? localPath,
    Expression<String>? kind,
    Expression<String>? contentType,
    Expression<int>? sizeBytes,
    Expression<String>? presignedKey,
    Expression<String>? uploadUrl,
    Expression<DateTime>? expiresAt,
    Expression<String>? state,
    Expression<int>? attempts,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? uploadedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localPath != null) 'local_path': localPath,
      if (kind != null) 'kind': kind,
      if (contentType != null) 'content_type': contentType,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (presignedKey != null) 'presigned_key': presignedKey,
      if (uploadUrl != null) 'upload_url': uploadUrl,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (state != null) 'state': state,
      if (attempts != null) 'attempts': attempts,
      if (createdAt != null) 'created_at': createdAt,
      if (uploadedAt != null) 'uploaded_at': uploadedAt,
    });
  }

  FilesQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? localPath,
    Value<String>? kind,
    Value<String>? contentType,
    Value<int>? sizeBytes,
    Value<String?>? presignedKey,
    Value<String?>? uploadUrl,
    Value<DateTime?>? expiresAt,
    Value<String>? state,
    Value<int>? attempts,
    Value<DateTime>? createdAt,
    Value<DateTime?>? uploadedAt,
  }) {
    return FilesQueueCompanion(
      id: id ?? this.id,
      localPath: localPath ?? this.localPath,
      kind: kind ?? this.kind,
      contentType: contentType ?? this.contentType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      presignedKey: presignedKey ?? this.presignedKey,
      uploadUrl: uploadUrl ?? this.uploadUrl,
      expiresAt: expiresAt ?? this.expiresAt,
      state: state ?? this.state,
      attempts: attempts ?? this.attempts,
      createdAt: createdAt ?? this.createdAt,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (presignedKey.present) {
      map['presigned_key'] = Variable<String>(presignedKey.value);
    }
    if (uploadUrl.present) {
      map['upload_url'] = Variable<String>(uploadUrl.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (uploadedAt.present) {
      map['uploaded_at'] = Variable<DateTime>(uploadedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FilesQueueCompanion(')
          ..write('id: $id, ')
          ..write('localPath: $localPath, ')
          ..write('kind: $kind, ')
          ..write('contentType: $contentType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('presignedKey: $presignedKey, ')
          ..write('uploadUrl: $uploadUrl, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('state: $state, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('uploadedAt: $uploadedAt')
          ..write(')'))
        .toString();
  }
}

class $ChatOutboxTable extends ChatOutbox with TableInfo<$ChatOutboxTable, ChatOutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientIdMeta = const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileKeyMeta = const VerificationMeta('fileKey');
  @override
  late final GeneratedColumn<String> fileKey = GeneratedColumn<String>(
    'file_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('queued'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    clientId,
    conversationId,
    kind,
    body,
    fileKey,
    lat,
    lng,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatOutboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(data['conversation_id']!, _conversationIdMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(_kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('text')) {
      context.handle(_bodyMeta, body.isAcceptableOrUnknown(data['text']!, _bodyMeta));
    }
    if (data.containsKey('file_key')) {
      context.handle(_fileKeyMeta, fileKey.isAcceptableOrUnknown(data['file_key']!, _fileKeyMeta));
    }
    if (data.containsKey('lat')) {
      context.handle(_latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    }
    if (data.containsKey('lng')) {
      context.handle(_lngMeta, lng.isAcceptableOrUnknown(data['lng']!, _lngMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientId};
  @override
  ChatOutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatOutboxRow(
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      ),
      kind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      body: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}text']),
      fileKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_key'],
      ),
      lat: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}lat']),
      lng: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}lng']),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ChatOutboxTable createAlias(String alias) {
    return $ChatOutboxTable(attachedDatabase, alias);
  }
}

class ChatOutboxRow extends DataClass implements Insertable<ChatOutboxRow> {
  final String clientId;
  final String? conversationId;

  /// `text`/`file`/`location`.
  final String kind;

  /// Getter nomi `body`, SQL ustuni `text`: `text()` quruvchisi bilan
  /// nom to'qnashuvi bo'lmasin (drift_dev buni tahlil qila olmaydi).
  final String? body;
  final String? fileKey;
  final double? lat;
  final double? lng;

  /// `queued`/`sent`/`delivered`/`read`/`failed`.
  final String status;
  final DateTime createdAt;
  const ChatOutboxRow({
    required this.clientId,
    this.conversationId,
    required this.kind,
    this.body,
    this.fileKey,
    this.lat,
    this.lng,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_id'] = Variable<String>(clientId);
    if (!nullToAbsent || conversationId != null) {
      map['conversation_id'] = Variable<String>(conversationId);
    }
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || body != null) {
      map['text'] = Variable<String>(body);
    }
    if (!nullToAbsent || fileKey != null) {
      map['file_key'] = Variable<String>(fileKey);
    }
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lng != null) {
      map['lng'] = Variable<double>(lng);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ChatOutboxCompanion toCompanion(bool nullToAbsent) {
    return ChatOutboxCompanion(
      clientId: Value(clientId),
      conversationId: conversationId == null && nullToAbsent
          ? const Value.absent()
          : Value(conversationId),
      kind: Value(kind),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      fileKey: fileKey == null && nullToAbsent ? const Value.absent() : Value(fileKey),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory ChatOutboxRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatOutboxRow(
      clientId: serializer.fromJson<String>(json['clientId']),
      conversationId: serializer.fromJson<String?>(json['conversationId']),
      kind: serializer.fromJson<String>(json['kind']),
      body: serializer.fromJson<String?>(json['body']),
      fileKey: serializer.fromJson<String?>(json['fileKey']),
      lat: serializer.fromJson<double?>(json['lat']),
      lng: serializer.fromJson<double?>(json['lng']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientId': serializer.toJson<String>(clientId),
      'conversationId': serializer.toJson<String?>(conversationId),
      'kind': serializer.toJson<String>(kind),
      'body': serializer.toJson<String?>(body),
      'fileKey': serializer.toJson<String?>(fileKey),
      'lat': serializer.toJson<double?>(lat),
      'lng': serializer.toJson<double?>(lng),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ChatOutboxRow copyWith({
    String? clientId,
    Value<String?> conversationId = const Value.absent(),
    String? kind,
    Value<String?> body = const Value.absent(),
    Value<String?> fileKey = const Value.absent(),
    Value<double?> lat = const Value.absent(),
    Value<double?> lng = const Value.absent(),
    String? status,
    DateTime? createdAt,
  }) => ChatOutboxRow(
    clientId: clientId ?? this.clientId,
    conversationId: conversationId.present ? conversationId.value : this.conversationId,
    kind: kind ?? this.kind,
    body: body.present ? body.value : this.body,
    fileKey: fileKey.present ? fileKey.value : this.fileKey,
    lat: lat.present ? lat.value : this.lat,
    lng: lng.present ? lng.value : this.lng,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  ChatOutboxRow copyWithCompanion(ChatOutboxCompanion data) {
    return ChatOutboxRow(
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      conversationId: data.conversationId.present ? data.conversationId.value : this.conversationId,
      kind: data.kind.present ? data.kind.value : this.kind,
      body: data.body.present ? data.body.value : this.body,
      fileKey: data.fileKey.present ? data.fileKey.value : this.fileKey,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatOutboxRow(')
          ..write('clientId: $clientId, ')
          ..write('conversationId: $conversationId, ')
          ..write('kind: $kind, ')
          ..write('body: $body, ')
          ..write('fileKey: $fileKey, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(clientId, conversationId, kind, body, fileKey, lat, lng, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatOutboxRow &&
          other.clientId == this.clientId &&
          other.conversationId == this.conversationId &&
          other.kind == this.kind &&
          other.body == this.body &&
          other.fileKey == this.fileKey &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class ChatOutboxCompanion extends UpdateCompanion<ChatOutboxRow> {
  final Value<String> clientId;
  final Value<String?> conversationId;
  final Value<String> kind;
  final Value<String?> body;
  final Value<String?> fileKey;
  final Value<double?> lat;
  final Value<double?> lng;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ChatOutboxCompanion({
    this.clientId = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.kind = const Value.absent(),
    this.body = const Value.absent(),
    this.fileKey = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatOutboxCompanion.insert({
    required String clientId,
    this.conversationId = const Value.absent(),
    required String kind,
    this.body = const Value.absent(),
    this.fileKey = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : clientId = Value(clientId),
       kind = Value(kind),
       createdAt = Value(createdAt);
  static Insertable<ChatOutboxRow> custom({
    Expression<String>? clientId,
    Expression<String>? conversationId,
    Expression<String>? kind,
    Expression<String>? body,
    Expression<String>? fileKey,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientId != null) 'client_id': clientId,
      if (conversationId != null) 'conversation_id': conversationId,
      if (kind != null) 'kind': kind,
      if (body != null) 'text': body,
      if (fileKey != null) 'file_key': fileKey,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatOutboxCompanion copyWith({
    Value<String>? clientId,
    Value<String?>? conversationId,
    Value<String>? kind,
    Value<String?>? body,
    Value<String?>? fileKey,
    Value<double?>? lat,
    Value<double?>? lng,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ChatOutboxCompanion(
      clientId: clientId ?? this.clientId,
      conversationId: conversationId ?? this.conversationId,
      kind: kind ?? this.kind,
      body: body ?? this.body,
      fileKey: fileKey ?? this.fileKey,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (body.present) {
      map['text'] = Variable<String>(body.value);
    }
    if (fileKey.present) {
      map['file_key'] = Variable<String>(fileKey.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatOutboxCompanion(')
          ..write('clientId: $clientId, ')
          ..write('conversationId: $conversationId, ')
          ..write('kind: $kind, ')
          ..write('body: $body, ')
          ..write('fileKey: $fileKey, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages with TableInfo<$ChatMessagesTable, ChatMessageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta('senderId');
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileKeyMeta = const VerificationMeta('fileKey');
  @override
  late final GeneratedColumn<String> fileKey = GeneratedColumn<String>(
    'file_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('sent'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clientId,
    conversationId,
    senderId,
    kind,
    body,
    fileKey,
    lat,
    lng,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(data['conversation_id']!, _conversationIdMeta),
      );
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(_kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('text')) {
      context.handle(_bodyMeta, body.isAcceptableOrUnknown(data['text']!, _bodyMeta));
    }
    if (data.containsKey('file_key')) {
      context.handle(_fileKeyMeta, fileKey.isAcceptableOrUnknown(data['file_key']!, _fileKeyMeta));
    }
    if (data.containsKey('lat')) {
      context.handle(_latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    }
    if (data.containsKey('lng')) {
      context.handle(_lngMeta, lng.isAcceptableOrUnknown(data['lng']!, _lngMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessageRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      ),
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      ),
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_id'],
      ),
      kind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      body: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}text']),
      fileKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_key'],
      ),
      lat: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}lat']),
      lng: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}lng']),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessageRow extends DataClass implements Insertable<ChatMessageRow> {
  final String id;

  /// Optimistik yozuvni server nusxasi bilan bog'laydi.
  final String? clientId;
  final String? conversationId;
  final String? senderId;
  final String kind;

  /// Getter nomi `body`, SQL ustuni `text`: `text()` quruvchisi bilan
  /// nom to'qnashuvi bo'lmasin (drift_dev buni tahlil qila olmaydi).
  final String? body;
  final String? fileKey;
  final double? lat;
  final double? lng;

  /// `queued`/`sent`/`delivered`/`read`/`failed`.
  final String status;
  final DateTime createdAt;
  const ChatMessageRow({
    required this.id,
    this.clientId,
    this.conversationId,
    this.senderId,
    required this.kind,
    this.body,
    this.fileKey,
    this.lat,
    this.lng,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    if (!nullToAbsent || conversationId != null) {
      map['conversation_id'] = Variable<String>(conversationId);
    }
    if (!nullToAbsent || senderId != null) {
      map['sender_id'] = Variable<String>(senderId);
    }
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || body != null) {
      map['text'] = Variable<String>(body);
    }
    if (!nullToAbsent || fileKey != null) {
      map['file_key'] = Variable<String>(fileKey);
    }
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lng != null) {
      map['lng'] = Variable<double>(lng);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      clientId: clientId == null && nullToAbsent ? const Value.absent() : Value(clientId),
      conversationId: conversationId == null && nullToAbsent
          ? const Value.absent()
          : Value(conversationId),
      senderId: senderId == null && nullToAbsent ? const Value.absent() : Value(senderId),
      kind: Value(kind),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      fileKey: fileKey == null && nullToAbsent ? const Value.absent() : Value(fileKey),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory ChatMessageRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessageRow(
      id: serializer.fromJson<String>(json['id']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      conversationId: serializer.fromJson<String?>(json['conversationId']),
      senderId: serializer.fromJson<String?>(json['senderId']),
      kind: serializer.fromJson<String>(json['kind']),
      body: serializer.fromJson<String?>(json['body']),
      fileKey: serializer.fromJson<String?>(json['fileKey']),
      lat: serializer.fromJson<double?>(json['lat']),
      lng: serializer.fromJson<double?>(json['lng']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientId': serializer.toJson<String?>(clientId),
      'conversationId': serializer.toJson<String?>(conversationId),
      'senderId': serializer.toJson<String?>(senderId),
      'kind': serializer.toJson<String>(kind),
      'body': serializer.toJson<String?>(body),
      'fileKey': serializer.toJson<String?>(fileKey),
      'lat': serializer.toJson<double?>(lat),
      'lng': serializer.toJson<double?>(lng),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ChatMessageRow copyWith({
    String? id,
    Value<String?> clientId = const Value.absent(),
    Value<String?> conversationId = const Value.absent(),
    Value<String?> senderId = const Value.absent(),
    String? kind,
    Value<String?> body = const Value.absent(),
    Value<String?> fileKey = const Value.absent(),
    Value<double?> lat = const Value.absent(),
    Value<double?> lng = const Value.absent(),
    String? status,
    DateTime? createdAt,
  }) => ChatMessageRow(
    id: id ?? this.id,
    clientId: clientId.present ? clientId.value : this.clientId,
    conversationId: conversationId.present ? conversationId.value : this.conversationId,
    senderId: senderId.present ? senderId.value : this.senderId,
    kind: kind ?? this.kind,
    body: body.present ? body.value : this.body,
    fileKey: fileKey.present ? fileKey.value : this.fileKey,
    lat: lat.present ? lat.value : this.lat,
    lng: lng.present ? lng.value : this.lng,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  ChatMessageRow copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessageRow(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      conversationId: data.conversationId.present ? data.conversationId.value : this.conversationId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      kind: data.kind.present ? data.kind.value : this.kind,
      body: data.body.present ? data.body.value : this.body,
      fileKey: data.fileKey.present ? data.fileKey.value : this.fileKey,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessageRow(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderId: $senderId, ')
          ..write('kind: $kind, ')
          ..write('body: $body, ')
          ..write('fileKey: $fileKey, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clientId,
    conversationId,
    senderId,
    kind,
    body,
    fileKey,
    lat,
    lng,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessageRow &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.conversationId == this.conversationId &&
          other.senderId == this.senderId &&
          other.kind == this.kind &&
          other.body == this.body &&
          other.fileKey == this.fileKey &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessageRow> {
  final Value<String> id;
  final Value<String?> clientId;
  final Value<String?> conversationId;
  final Value<String?> senderId;
  final Value<String> kind;
  final Value<String?> body;
  final Value<String?> fileKey;
  final Value<double?> lat;
  final Value<double?> lng;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.kind = const Value.absent(),
    this.body = const Value.absent(),
    this.fileKey = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    required String id,
    this.clientId = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.senderId = const Value.absent(),
    required String kind,
    this.body = const Value.absent(),
    this.fileKey = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       createdAt = Value(createdAt);
  static Insertable<ChatMessageRow> custom({
    Expression<String>? id,
    Expression<String>? clientId,
    Expression<String>? conversationId,
    Expression<String>? senderId,
    Expression<String>? kind,
    Expression<String>? body,
    Expression<String>? fileKey,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (conversationId != null) 'conversation_id': conversationId,
      if (senderId != null) 'sender_id': senderId,
      if (kind != null) 'kind': kind,
      if (body != null) 'text': body,
      if (fileKey != null) 'file_key': fileKey,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatMessagesCompanion copyWith({
    Value<String>? id,
    Value<String?>? clientId,
    Value<String?>? conversationId,
    Value<String?>? senderId,
    Value<String>? kind,
    Value<String?>? body,
    Value<String?>? fileKey,
    Value<double?>? lat,
    Value<double?>? lng,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      kind: kind ?? this.kind,
      body: body ?? this.body,
      fileKey: fileKey ?? this.fileKey,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (body.present) {
      map['text'] = Variable<String>(body.value);
    }
    if (fileKey.present) {
      map['file_key'] = Variable<String>(fileKey.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderId: $senderId, ')
          ..write('kind: $kind, ')
          ..write('body: $body, ')
          ..write('fileKey: $fileKey, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationsTable extends Notifications
    with TableInfo<$NotificationsTable, NotificationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _alertTypeMeta = const VerificationMeta('alertType');
  @override
  late final GeneratedColumn<String> alertType = GeneratedColumn<String>(
    'alert_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readMeta = const VerificationMeta('read');
  @override
  late final GeneratedColumn<bool> read = GeneratedColumn<bool>(
    'read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("read" IN (0, 1))'),
    defaultValue: const Constant<bool>(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    alertType,
    title,
    body,
    entityType,
    entityId,
    read,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notifications';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('alert_type')) {
      context.handle(
        _alertTypeMeta,
        alertType.isAcceptableOrUnknown(data['alert_type']!, _alertTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_alertTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(_bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    }
    if (data.containsKey('read')) {
      context.handle(_readMeta, read.isAcceptableOrUnknown(data['read']!, _readMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      alertType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alert_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      ),
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      ),
      read: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}read'])!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $NotificationsTable createAlias(String alias) {
    return $NotificationsTable(attachedDatabase, alias);
  }
}

class NotificationRow extends DataClass implements Insertable<NotificationRow> {
  final String id;
  final String alertType;
  final String title;
  final String body;
  final String? entityType;
  final String? entityId;
  final bool read;
  final DateTime createdAt;
  const NotificationRow({
    required this.id,
    required this.alertType,
    required this.title,
    required this.body,
    this.entityType,
    this.entityId,
    required this.read,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['alert_type'] = Variable<String>(alertType);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || entityType != null) {
      map['entity_type'] = Variable<String>(entityType);
    }
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<String>(entityId);
    }
    map['read'] = Variable<bool>(read);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NotificationsCompanion toCompanion(bool nullToAbsent) {
    return NotificationsCompanion(
      id: Value(id),
      alertType: Value(alertType),
      title: Value(title),
      body: Value(body),
      entityType: entityType == null && nullToAbsent ? const Value.absent() : Value(entityType),
      entityId: entityId == null && nullToAbsent ? const Value.absent() : Value(entityId),
      read: Value(read),
      createdAt: Value(createdAt),
    );
  }

  factory NotificationRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationRow(
      id: serializer.fromJson<String>(json['id']),
      alertType: serializer.fromJson<String>(json['alertType']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      entityType: serializer.fromJson<String?>(json['entityType']),
      entityId: serializer.fromJson<String?>(json['entityId']),
      read: serializer.fromJson<bool>(json['read']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'alertType': serializer.toJson<String>(alertType),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'entityType': serializer.toJson<String?>(entityType),
      'entityId': serializer.toJson<String?>(entityId),
      'read': serializer.toJson<bool>(read),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  NotificationRow copyWith({
    String? id,
    String? alertType,
    String? title,
    String? body,
    Value<String?> entityType = const Value.absent(),
    Value<String?> entityId = const Value.absent(),
    bool? read,
    DateTime? createdAt,
  }) => NotificationRow(
    id: id ?? this.id,
    alertType: alertType ?? this.alertType,
    title: title ?? this.title,
    body: body ?? this.body,
    entityType: entityType.present ? entityType.value : this.entityType,
    entityId: entityId.present ? entityId.value : this.entityId,
    read: read ?? this.read,
    createdAt: createdAt ?? this.createdAt,
  );
  NotificationRow copyWithCompanion(NotificationsCompanion data) {
    return NotificationRow(
      id: data.id.present ? data.id.value : this.id,
      alertType: data.alertType.present ? data.alertType.value : this.alertType,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      entityType: data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      read: data.read.present ? data.read.value : this.read,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationRow(')
          ..write('id: $id, ')
          ..write('alertType: $alertType, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('read: $read, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, alertType, title, body, entityType, entityId, read, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationRow &&
          other.id == this.id &&
          other.alertType == this.alertType &&
          other.title == this.title &&
          other.body == this.body &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.read == this.read &&
          other.createdAt == this.createdAt);
}

class NotificationsCompanion extends UpdateCompanion<NotificationRow> {
  final Value<String> id;
  final Value<String> alertType;
  final Value<String> title;
  final Value<String> body;
  final Value<String?> entityType;
  final Value<String?> entityId;
  final Value<bool> read;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const NotificationsCompanion({
    this.id = const Value.absent(),
    this.alertType = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.read = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationsCompanion.insert({
    required String id,
    required String alertType,
    required String title,
    required String body,
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.read = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       alertType = Value(alertType),
       title = Value(title),
       body = Value(body),
       createdAt = Value(createdAt);
  static Insertable<NotificationRow> custom({
    Expression<String>? id,
    Expression<String>? alertType,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<bool>? read,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (alertType != null) 'alert_type': alertType,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (read != null) 'read': read,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationsCompanion copyWith({
    Value<String>? id,
    Value<String>? alertType,
    Value<String>? title,
    Value<String>? body,
    Value<String?>? entityType,
    Value<String?>? entityId,
    Value<bool>? read,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return NotificationsCompanion(
      id: id ?? this.id,
      alertType: alertType ?? this.alertType,
      title: title ?? this.title,
      body: body ?? this.body,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (alertType.present) {
      map['alert_type'] = Variable<String>(alertType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (read.present) {
      map['read'] = Variable<bool>(read.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationsCompanion(')
          ..write('id: $id, ')
          ..write('alertType: $alertType, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('read: $read, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LogEditRequestsTable extends LogEditRequests
    with TableInfo<$LogEditRequestsTable, LogEditRequestRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LogEditRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dailyLogIdMeta = const VerificationMeta('dailyLogId');
  @override
  late final GeneratedColumn<String> dailyLogId = GeneratedColumn<String>(
    'daily_log_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _logDateMeta = const VerificationMeta('logDate');
  @override
  late final GeneratedColumn<String> logDate = GeneratedColumn<String>(
    'log_date',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 10, maxTextLength: 10),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, Object?>, String> changes =
      GeneratedColumn<String>(
        'changes',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant<String>('{}'),
      ).withConverter<Map<String, Object?>>($LogEditRequestsTable.$converterchanges);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localDecisionMeta = const VerificationMeta('localDecision');
  @override
  late final GeneratedColumn<String> localDecision = GeneratedColumn<String>(
    'local_decision',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dailyLogId,
    logDate,
    changes,
    source,
    status,
    createdAt,
    localDecision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'log_edit_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<LogEditRequestRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('daily_log_id')) {
      context.handle(
        _dailyLogIdMeta,
        dailyLogId.isAcceptableOrUnknown(data['daily_log_id']!, _dailyLogIdMeta),
      );
    }
    if (data.containsKey('log_date')) {
      context.handle(_logDateMeta, logDate.isAcceptableOrUnknown(data['log_date']!, _logDateMeta));
    } else if (isInserting) {
      context.missing(_logDateMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta, source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('local_decision')) {
      context.handle(
        _localDecisionMeta,
        localDecision.isAcceptableOrUnknown(data['local_decision']!, _localDecisionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LogEditRequestRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LogEditRequestRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      dailyLogId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}daily_log_id'],
      ),
      logDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}log_date'],
      )!,
      changes: $LogEditRequestsTable.$converterchanges.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}changes'])!,
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      localDecision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_decision'],
      ),
    );
  }

  @override
  $LogEditRequestsTable createAlias(String alias) {
    return $LogEditRequestsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Map<String, Object?>, String, Object?> $converterchanges =
      const JsonMapConverter();
}

class LogEditRequestRow extends DataClass implements Insertable<LogEditRequestRow> {
  final String id;
  final String? dailyLogId;
  final String logDate;

  /// So'ralgan o'zgarishlar (event diff) — JSON.
  final Map<String, Object?> changes;

  /// `driver`/`admin`.
  final String source;

  /// `pending`/`approved`/`rejected`.
  final String status;
  final DateTime createdAt;

  /// Haydovchining lokal qarori (hali push qilinmagan bo'lishi mumkin).
  final String? localDecision;
  const LogEditRequestRow({
    required this.id,
    this.dailyLogId,
    required this.logDate,
    required this.changes,
    required this.source,
    required this.status,
    required this.createdAt,
    this.localDecision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || dailyLogId != null) {
      map['daily_log_id'] = Variable<String>(dailyLogId);
    }
    map['log_date'] = Variable<String>(logDate);
    {
      map['changes'] = Variable<String>($LogEditRequestsTable.$converterchanges.toSql(changes));
    }
    map['source'] = Variable<String>(source);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || localDecision != null) {
      map['local_decision'] = Variable<String>(localDecision);
    }
    return map;
  }

  LogEditRequestsCompanion toCompanion(bool nullToAbsent) {
    return LogEditRequestsCompanion(
      id: Value(id),
      dailyLogId: dailyLogId == null && nullToAbsent ? const Value.absent() : Value(dailyLogId),
      logDate: Value(logDate),
      changes: Value(changes),
      source: Value(source),
      status: Value(status),
      createdAt: Value(createdAt),
      localDecision: localDecision == null && nullToAbsent
          ? const Value.absent()
          : Value(localDecision),
    );
  }

  factory LogEditRequestRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LogEditRequestRow(
      id: serializer.fromJson<String>(json['id']),
      dailyLogId: serializer.fromJson<String?>(json['dailyLogId']),
      logDate: serializer.fromJson<String>(json['logDate']),
      changes: $LogEditRequestsTable.$converterchanges.fromJson(
        serializer.fromJson<Object?>(json['changes']),
      ),
      source: serializer.fromJson<String>(json['source']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      localDecision: serializer.fromJson<String?>(json['localDecision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dailyLogId': serializer.toJson<String?>(dailyLogId),
      'logDate': serializer.toJson<String>(logDate),
      'changes': serializer.toJson<Object?>(
        $LogEditRequestsTable.$converterchanges.toJson(changes),
      ),
      'source': serializer.toJson<String>(source),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'localDecision': serializer.toJson<String?>(localDecision),
    };
  }

  LogEditRequestRow copyWith({
    String? id,
    Value<String?> dailyLogId = const Value.absent(),
    String? logDate,
    Map<String, Object?>? changes,
    String? source,
    String? status,
    DateTime? createdAt,
    Value<String?> localDecision = const Value.absent(),
  }) => LogEditRequestRow(
    id: id ?? this.id,
    dailyLogId: dailyLogId.present ? dailyLogId.value : this.dailyLogId,
    logDate: logDate ?? this.logDate,
    changes: changes ?? this.changes,
    source: source ?? this.source,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    localDecision: localDecision.present ? localDecision.value : this.localDecision,
  );
  LogEditRequestRow copyWithCompanion(LogEditRequestsCompanion data) {
    return LogEditRequestRow(
      id: data.id.present ? data.id.value : this.id,
      dailyLogId: data.dailyLogId.present ? data.dailyLogId.value : this.dailyLogId,
      logDate: data.logDate.present ? data.logDate.value : this.logDate,
      changes: data.changes.present ? data.changes.value : this.changes,
      source: data.source.present ? data.source.value : this.source,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      localDecision: data.localDecision.present ? data.localDecision.value : this.localDecision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LogEditRequestRow(')
          ..write('id: $id, ')
          ..write('dailyLogId: $dailyLogId, ')
          ..write('logDate: $logDate, ')
          ..write('changes: $changes, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('localDecision: $localDecision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, dailyLogId, logDate, changes, source, status, createdAt, localDecision);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LogEditRequestRow &&
          other.id == this.id &&
          other.dailyLogId == this.dailyLogId &&
          other.logDate == this.logDate &&
          other.changes == this.changes &&
          other.source == this.source &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.localDecision == this.localDecision);
}

class LogEditRequestsCompanion extends UpdateCompanion<LogEditRequestRow> {
  final Value<String> id;
  final Value<String?> dailyLogId;
  final Value<String> logDate;
  final Value<Map<String, Object?>> changes;
  final Value<String> source;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<String?> localDecision;
  final Value<int> rowid;
  const LogEditRequestsCompanion({
    this.id = const Value.absent(),
    this.dailyLogId = const Value.absent(),
    this.logDate = const Value.absent(),
    this.changes = const Value.absent(),
    this.source = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.localDecision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LogEditRequestsCompanion.insert({
    required String id,
    this.dailyLogId = const Value.absent(),
    required String logDate,
    this.changes = const Value.absent(),
    required String source,
    required String status,
    required DateTime createdAt,
    this.localDecision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       logDate = Value(logDate),
       source = Value(source),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<LogEditRequestRow> custom({
    Expression<String>? id,
    Expression<String>? dailyLogId,
    Expression<String>? logDate,
    Expression<String>? changes,
    Expression<String>? source,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<String>? localDecision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dailyLogId != null) 'daily_log_id': dailyLogId,
      if (logDate != null) 'log_date': logDate,
      if (changes != null) 'changes': changes,
      if (source != null) 'source': source,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (localDecision != null) 'local_decision': localDecision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LogEditRequestsCompanion copyWith({
    Value<String>? id,
    Value<String?>? dailyLogId,
    Value<String>? logDate,
    Value<Map<String, Object?>>? changes,
    Value<String>? source,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<String?>? localDecision,
    Value<int>? rowid,
  }) {
    return LogEditRequestsCompanion(
      id: id ?? this.id,
      dailyLogId: dailyLogId ?? this.dailyLogId,
      logDate: logDate ?? this.logDate,
      changes: changes ?? this.changes,
      source: source ?? this.source,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      localDecision: localDecision ?? this.localDecision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dailyLogId.present) {
      map['daily_log_id'] = Variable<String>(dailyLogId.value);
    }
    if (logDate.present) {
      map['log_date'] = Variable<String>(logDate.value);
    }
    if (changes.present) {
      map['changes'] = Variable<String>(
        $LogEditRequestsTable.$converterchanges.toSql(changes.value),
      );
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (localDecision.present) {
      map['local_decision'] = Variable<String>(localDecision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LogEditRequestsCompanion(')
          ..write('id: $id, ')
          ..write('dailyLogId: $dailyLogId, ')
          ..write('logDate: $logDate, ')
          ..write('changes: $changes, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('localDecision: $localDecision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UnidentifiedEventsTable extends UnidentifiedEvents
    with TableInfo<$UnidentifiedEventsTable, UnidentifiedEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnidentifiedEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<String> unitId = GeneratedColumn<String>(
    'unit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startAtMeta = const VerificationMeta('startAt');
  @override
  late final GeneratedColumn<DateTime> startAt = GeneratedColumn<DateTime>(
    'start_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<DateTime> endAt = GeneratedColumn<DateTime>(
    'end_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceMMeta = const VerificationMeta('distanceM');
  @override
  late final GeneratedColumn<int> distanceM = GeneratedColumn<int>(
    'distance_m',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dismissedLocalMeta = const VerificationMeta('dismissedLocal');
  @override
  late final GeneratedColumn<bool> dismissedLocal = GeneratedColumn<bool>(
    'dismissed_local',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("dismissed_local" IN (0, 1))'),
    defaultValue: const Constant<bool>(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    unitId,
    startAt,
    endAt,
    distanceM,
    status,
    dismissedLocal,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'unidentified_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<UnidentifiedEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('unit_id')) {
      context.handle(_unitIdMeta, unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta));
    } else if (isInserting) {
      context.missing(_unitIdMeta);
    }
    if (data.containsKey('start_at')) {
      context.handle(_startAtMeta, startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta));
    } else if (isInserting) {
      context.missing(_startAtMeta);
    }
    if (data.containsKey('end_at')) {
      context.handle(_endAtMeta, endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta));
    }
    if (data.containsKey('distance_m')) {
      context.handle(
        _distanceMMeta,
        distanceM.isAcceptableOrUnknown(data['distance_m']!, _distanceMMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('dismissed_local')) {
      context.handle(
        _dismissedLocalMeta,
        dismissedLocal.isAcceptableOrUnknown(data['dismissed_local']!, _dismissedLocalMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UnidentifiedEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UnidentifiedEventRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      unitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_id'],
      )!,
      startAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_at'],
      )!,
      endAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_at'],
      ),
      distanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distance_m'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      dismissedLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dismissed_local'],
      )!,
    );
  }

  @override
  $UnidentifiedEventsTable createAlias(String alias) {
    return $UnidentifiedEventsTable(attachedDatabase, alias);
  }
}

class UnidentifiedEventRow extends DataClass implements Insertable<UnidentifiedEventRow> {
  final String id;
  final String unitId;
  final DateTime startAt;
  final DateTime? endAt;
  final int distanceM;

  /// `pending`/`claimed`/`assigned`/`annotated`.
  final String status;

  /// Haydovchi ro'yxatdan yashirgan (server holati o'zgarmaydi).
  final bool dismissedLocal;
  const UnidentifiedEventRow({
    required this.id,
    required this.unitId,
    required this.startAt,
    this.endAt,
    required this.distanceM,
    required this.status,
    required this.dismissedLocal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['unit_id'] = Variable<String>(unitId);
    map['start_at'] = Variable<DateTime>(startAt);
    if (!nullToAbsent || endAt != null) {
      map['end_at'] = Variable<DateTime>(endAt);
    }
    map['distance_m'] = Variable<int>(distanceM);
    map['status'] = Variable<String>(status);
    map['dismissed_local'] = Variable<bool>(dismissedLocal);
    return map;
  }

  UnidentifiedEventsCompanion toCompanion(bool nullToAbsent) {
    return UnidentifiedEventsCompanion(
      id: Value(id),
      unitId: Value(unitId),
      startAt: Value(startAt),
      endAt: endAt == null && nullToAbsent ? const Value.absent() : Value(endAt),
      distanceM: Value(distanceM),
      status: Value(status),
      dismissedLocal: Value(dismissedLocal),
    );
  }

  factory UnidentifiedEventRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UnidentifiedEventRow(
      id: serializer.fromJson<String>(json['id']),
      unitId: serializer.fromJson<String>(json['unitId']),
      startAt: serializer.fromJson<DateTime>(json['startAt']),
      endAt: serializer.fromJson<DateTime?>(json['endAt']),
      distanceM: serializer.fromJson<int>(json['distanceM']),
      status: serializer.fromJson<String>(json['status']),
      dismissedLocal: serializer.fromJson<bool>(json['dismissedLocal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'unitId': serializer.toJson<String>(unitId),
      'startAt': serializer.toJson<DateTime>(startAt),
      'endAt': serializer.toJson<DateTime?>(endAt),
      'distanceM': serializer.toJson<int>(distanceM),
      'status': serializer.toJson<String>(status),
      'dismissedLocal': serializer.toJson<bool>(dismissedLocal),
    };
  }

  UnidentifiedEventRow copyWith({
    String? id,
    String? unitId,
    DateTime? startAt,
    Value<DateTime?> endAt = const Value.absent(),
    int? distanceM,
    String? status,
    bool? dismissedLocal,
  }) => UnidentifiedEventRow(
    id: id ?? this.id,
    unitId: unitId ?? this.unitId,
    startAt: startAt ?? this.startAt,
    endAt: endAt.present ? endAt.value : this.endAt,
    distanceM: distanceM ?? this.distanceM,
    status: status ?? this.status,
    dismissedLocal: dismissedLocal ?? this.dismissedLocal,
  );
  UnidentifiedEventRow copyWithCompanion(UnidentifiedEventsCompanion data) {
    return UnidentifiedEventRow(
      id: data.id.present ? data.id.value : this.id,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      distanceM: data.distanceM.present ? data.distanceM.value : this.distanceM,
      status: data.status.present ? data.status.value : this.status,
      dismissedLocal: data.dismissedLocal.present ? data.dismissedLocal.value : this.dismissedLocal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UnidentifiedEventRow(')
          ..write('id: $id, ')
          ..write('unitId: $unitId, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('distanceM: $distanceM, ')
          ..write('status: $status, ')
          ..write('dismissedLocal: $dismissedLocal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, unitId, startAt, endAt, distanceM, status, dismissedLocal);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnidentifiedEventRow &&
          other.id == this.id &&
          other.unitId == this.unitId &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.distanceM == this.distanceM &&
          other.status == this.status &&
          other.dismissedLocal == this.dismissedLocal);
}

class UnidentifiedEventsCompanion extends UpdateCompanion<UnidentifiedEventRow> {
  final Value<String> id;
  final Value<String> unitId;
  final Value<DateTime> startAt;
  final Value<DateTime?> endAt;
  final Value<int> distanceM;
  final Value<String> status;
  final Value<bool> dismissedLocal;
  final Value<int> rowid;
  const UnidentifiedEventsCompanion({
    this.id = const Value.absent(),
    this.unitId = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.status = const Value.absent(),
    this.dismissedLocal = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UnidentifiedEventsCompanion.insert({
    required String id,
    required String unitId,
    required DateTime startAt,
    this.endAt = const Value.absent(),
    this.distanceM = const Value.absent(),
    required String status,
    this.dismissedLocal = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       unitId = Value(unitId),
       startAt = Value(startAt),
       status = Value(status);
  static Insertable<UnidentifiedEventRow> custom({
    Expression<String>? id,
    Expression<String>? unitId,
    Expression<DateTime>? startAt,
    Expression<DateTime>? endAt,
    Expression<int>? distanceM,
    Expression<String>? status,
    Expression<bool>? dismissedLocal,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (unitId != null) 'unit_id': unitId,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (distanceM != null) 'distance_m': distanceM,
      if (status != null) 'status': status,
      if (dismissedLocal != null) 'dismissed_local': dismissedLocal,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UnidentifiedEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? unitId,
    Value<DateTime>? startAt,
    Value<DateTime?>? endAt,
    Value<int>? distanceM,
    Value<String>? status,
    Value<bool>? dismissedLocal,
    Value<int>? rowid,
  }) {
    return UnidentifiedEventsCompanion(
      id: id ?? this.id,
      unitId: unitId ?? this.unitId,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      distanceM: distanceM ?? this.distanceM,
      status: status ?? this.status,
      dismissedLocal: dismissedLocal ?? this.dismissedLocal,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (unitId.present) {
      map['unit_id'] = Variable<String>(unitId.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<DateTime>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<DateTime>(endAt.value);
    }
    if (distanceM.present) {
      map['distance_m'] = Variable<int>(distanceM.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (dismissedLocal.present) {
      map['dismissed_local'] = Variable<bool>(dismissedLocal.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnidentifiedEventsCompanion(')
          ..write('id: $id, ')
          ..write('unitId: $unitId, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('distanceM: $distanceM, ')
          ..write('status: $status, ')
          ..write('dismissedLocal: $dismissedLocal, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ViolationsTable extends Violations with TableInfo<$ViolationsTable, ViolationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ViolationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta('severity');
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('violation'),
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta('occurredAt');
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _logDateMeta = const VerificationMeta('logDate');
  @override
  late final GeneratedColumn<String> logDate = GeneratedColumn<String>(
    'log_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dailyLogIdMeta = const VerificationMeta('dailyLogId');
  @override
  late final GeneratedColumn<String> dailyLogId = GeneratedColumn<String>(
    'daily_log_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _driverIdMeta = const VerificationMeta('driverId');
  @override
  late final GeneratedColumn<String> driverId = GeneratedColumn<String>(
    'driver_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<String> unitId = GeneratedColumn<String>(
    'unit_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _policyVersionIdMeta = const VerificationMeta('policyVersionId');
  @override
  late final GeneratedColumn<String> policyVersionId = GeneratedColumn<String>(
    'policy_version_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, Object?>, String> details =
      GeneratedColumn<String>(
        'details',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant<String>('{}'),
      ).withConverter<Map<String, Object?>>($ViolationsTable.$converterdetails);
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta('resolvedAt');
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resolvedReasonMeta = const VerificationMeta('resolvedReason');
  @override
  late final GeneratedColumn<String> resolvedReason = GeneratedColumn<String>(
    'resolved_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    severity,
    occurredAt,
    logDate,
    dailyLogId,
    driverId,
    unitId,
    policyVersionId,
    details,
    resolvedAt,
    resolvedReason,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'violations';
  @override
  VerificationContext validateIntegrity(
    Insertable<ViolationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(_typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('log_date')) {
      context.handle(_logDateMeta, logDate.isAcceptableOrUnknown(data['log_date']!, _logDateMeta));
    }
    if (data.containsKey('daily_log_id')) {
      context.handle(
        _dailyLogIdMeta,
        dailyLogId.isAcceptableOrUnknown(data['daily_log_id']!, _dailyLogIdMeta),
      );
    }
    if (data.containsKey('driver_id')) {
      context.handle(
        _driverIdMeta,
        driverId.isAcceptableOrUnknown(data['driver_id']!, _driverIdMeta),
      );
    }
    if (data.containsKey('unit_id')) {
      context.handle(_unitIdMeta, unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta));
    }
    if (data.containsKey('policy_version_id')) {
      context.handle(
        _policyVersionIdMeta,
        policyVersionId.isAcceptableOrUnknown(data['policy_version_id']!, _policyVersionIdMeta),
      );
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    if (data.containsKey('resolved_reason')) {
      context.handle(
        _resolvedReasonMeta,
        resolvedReason.isAcceptableOrUnknown(data['resolved_reason']!, _resolvedReasonMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ViolationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ViolationRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      logDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}log_date'],
      ),
      dailyLogId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}daily_log_id'],
      ),
      driverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}driver_id'],
      ),
      unitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_id'],
      ),
      policyVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}policy_version_id'],
      ),
      details: $ViolationsTable.$converterdetails.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}details'])!,
      ),
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
      resolvedReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolved_reason'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ViolationsTable createAlias(String alias) {
    return $ViolationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Map<String, Object?>, String, Object?> $converterdetails =
      const JsonMapConverter();
}

class ViolationRow extends DataClass implements Insertable<ViolationRow> {
  /// Server `id` si (UUID) — mijoz buzilish yaratmaydi.
  final String id;

  /// `drive_limit`, `shift_window`, `break_required`, `cycle_limit`, … .
  final String type;

  /// `warning` / `violation`.
  final String severity;
  final DateTime occurredAt;

  /// Home Terminal TZ dagi kun, `YYYY-MM-DD` (kun bo'yicha guruhlash uchun).
  final String? logDate;
  final String? dailyLogId;
  final String? driverId;
  final String? unitId;
  final String? policyVersionId;

  /// `{limit_min, remaining_min, days_uncertified, note}` — JSON.
  final Map<String, Object?> details;
  final DateTime? resolvedAt;
  final String? resolvedReason;
  final DateTime updatedAt;
  const ViolationRow({
    required this.id,
    required this.type,
    required this.severity,
    required this.occurredAt,
    this.logDate,
    this.dailyLogId,
    this.driverId,
    this.unitId,
    this.policyVersionId,
    required this.details,
    this.resolvedAt,
    this.resolvedReason,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['severity'] = Variable<String>(severity);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || logDate != null) {
      map['log_date'] = Variable<String>(logDate);
    }
    if (!nullToAbsent || dailyLogId != null) {
      map['daily_log_id'] = Variable<String>(dailyLogId);
    }
    if (!nullToAbsent || driverId != null) {
      map['driver_id'] = Variable<String>(driverId);
    }
    if (!nullToAbsent || unitId != null) {
      map['unit_id'] = Variable<String>(unitId);
    }
    if (!nullToAbsent || policyVersionId != null) {
      map['policy_version_id'] = Variable<String>(policyVersionId);
    }
    {
      map['details'] = Variable<String>($ViolationsTable.$converterdetails.toSql(details));
    }
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    if (!nullToAbsent || resolvedReason != null) {
      map['resolved_reason'] = Variable<String>(resolvedReason);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ViolationsCompanion toCompanion(bool nullToAbsent) {
    return ViolationsCompanion(
      id: Value(id),
      type: Value(type),
      severity: Value(severity),
      occurredAt: Value(occurredAt),
      logDate: logDate == null && nullToAbsent ? const Value.absent() : Value(logDate),
      dailyLogId: dailyLogId == null && nullToAbsent ? const Value.absent() : Value(dailyLogId),
      driverId: driverId == null && nullToAbsent ? const Value.absent() : Value(driverId),
      unitId: unitId == null && nullToAbsent ? const Value.absent() : Value(unitId),
      policyVersionId: policyVersionId == null && nullToAbsent
          ? const Value.absent()
          : Value(policyVersionId),
      details: Value(details),
      resolvedAt: resolvedAt == null && nullToAbsent ? const Value.absent() : Value(resolvedAt),
      resolvedReason: resolvedReason == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedReason),
      updatedAt: Value(updatedAt),
    );
  }

  factory ViolationRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ViolationRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      severity: serializer.fromJson<String>(json['severity']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      logDate: serializer.fromJson<String?>(json['logDate']),
      dailyLogId: serializer.fromJson<String?>(json['dailyLogId']),
      driverId: serializer.fromJson<String?>(json['driverId']),
      unitId: serializer.fromJson<String?>(json['unitId']),
      policyVersionId: serializer.fromJson<String?>(json['policyVersionId']),
      details: $ViolationsTable.$converterdetails.fromJson(
        serializer.fromJson<Object?>(json['details']),
      ),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
      resolvedReason: serializer.fromJson<String?>(json['resolvedReason']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'severity': serializer.toJson<String>(severity),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'logDate': serializer.toJson<String?>(logDate),
      'dailyLogId': serializer.toJson<String?>(dailyLogId),
      'driverId': serializer.toJson<String?>(driverId),
      'unitId': serializer.toJson<String?>(unitId),
      'policyVersionId': serializer.toJson<String?>(policyVersionId),
      'details': serializer.toJson<Object?>($ViolationsTable.$converterdetails.toJson(details)),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
      'resolvedReason': serializer.toJson<String?>(resolvedReason),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ViolationRow copyWith({
    String? id,
    String? type,
    String? severity,
    DateTime? occurredAt,
    Value<String?> logDate = const Value.absent(),
    Value<String?> dailyLogId = const Value.absent(),
    Value<String?> driverId = const Value.absent(),
    Value<String?> unitId = const Value.absent(),
    Value<String?> policyVersionId = const Value.absent(),
    Map<String, Object?>? details,
    Value<DateTime?> resolvedAt = const Value.absent(),
    Value<String?> resolvedReason = const Value.absent(),
    DateTime? updatedAt,
  }) => ViolationRow(
    id: id ?? this.id,
    type: type ?? this.type,
    severity: severity ?? this.severity,
    occurredAt: occurredAt ?? this.occurredAt,
    logDate: logDate.present ? logDate.value : this.logDate,
    dailyLogId: dailyLogId.present ? dailyLogId.value : this.dailyLogId,
    driverId: driverId.present ? driverId.value : this.driverId,
    unitId: unitId.present ? unitId.value : this.unitId,
    policyVersionId: policyVersionId.present ? policyVersionId.value : this.policyVersionId,
    details: details ?? this.details,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
    resolvedReason: resolvedReason.present ? resolvedReason.value : this.resolvedReason,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ViolationRow copyWithCompanion(ViolationsCompanion data) {
    return ViolationRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      severity: data.severity.present ? data.severity.value : this.severity,
      occurredAt: data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
      logDate: data.logDate.present ? data.logDate.value : this.logDate,
      dailyLogId: data.dailyLogId.present ? data.dailyLogId.value : this.dailyLogId,
      driverId: data.driverId.present ? data.driverId.value : this.driverId,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      policyVersionId: data.policyVersionId.present
          ? data.policyVersionId.value
          : this.policyVersionId,
      details: data.details.present ? data.details.value : this.details,
      resolvedAt: data.resolvedAt.present ? data.resolvedAt.value : this.resolvedAt,
      resolvedReason: data.resolvedReason.present ? data.resolvedReason.value : this.resolvedReason,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ViolationRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('severity: $severity, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('logDate: $logDate, ')
          ..write('dailyLogId: $dailyLogId, ')
          ..write('driverId: $driverId, ')
          ..write('unitId: $unitId, ')
          ..write('policyVersionId: $policyVersionId, ')
          ..write('details: $details, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('resolvedReason: $resolvedReason, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    severity,
    occurredAt,
    logDate,
    dailyLogId,
    driverId,
    unitId,
    policyVersionId,
    details,
    resolvedAt,
    resolvedReason,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ViolationRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.severity == this.severity &&
          other.occurredAt == this.occurredAt &&
          other.logDate == this.logDate &&
          other.dailyLogId == this.dailyLogId &&
          other.driverId == this.driverId &&
          other.unitId == this.unitId &&
          other.policyVersionId == this.policyVersionId &&
          other.details == this.details &&
          other.resolvedAt == this.resolvedAt &&
          other.resolvedReason == this.resolvedReason &&
          other.updatedAt == this.updatedAt);
}

class ViolationsCompanion extends UpdateCompanion<ViolationRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> severity;
  final Value<DateTime> occurredAt;
  final Value<String?> logDate;
  final Value<String?> dailyLogId;
  final Value<String?> driverId;
  final Value<String?> unitId;
  final Value<String?> policyVersionId;
  final Value<Map<String, Object?>> details;
  final Value<DateTime?> resolvedAt;
  final Value<String?> resolvedReason;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ViolationsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.severity = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.logDate = const Value.absent(),
    this.dailyLogId = const Value.absent(),
    this.driverId = const Value.absent(),
    this.unitId = const Value.absent(),
    this.policyVersionId = const Value.absent(),
    this.details = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.resolvedReason = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ViolationsCompanion.insert({
    required String id,
    required String type,
    this.severity = const Value.absent(),
    required DateTime occurredAt,
    this.logDate = const Value.absent(),
    this.dailyLogId = const Value.absent(),
    this.driverId = const Value.absent(),
    this.unitId = const Value.absent(),
    this.policyVersionId = const Value.absent(),
    this.details = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.resolvedReason = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       occurredAt = Value(occurredAt),
       updatedAt = Value(updatedAt);
  static Insertable<ViolationRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? severity,
    Expression<DateTime>? occurredAt,
    Expression<String>? logDate,
    Expression<String>? dailyLogId,
    Expression<String>? driverId,
    Expression<String>? unitId,
    Expression<String>? policyVersionId,
    Expression<String>? details,
    Expression<DateTime>? resolvedAt,
    Expression<String>? resolvedReason,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (severity != null) 'severity': severity,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (logDate != null) 'log_date': logDate,
      if (dailyLogId != null) 'daily_log_id': dailyLogId,
      if (driverId != null) 'driver_id': driverId,
      if (unitId != null) 'unit_id': unitId,
      if (policyVersionId != null) 'policy_version_id': policyVersionId,
      if (details != null) 'details': details,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (resolvedReason != null) 'resolved_reason': resolvedReason,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ViolationsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String>? severity,
    Value<DateTime>? occurredAt,
    Value<String?>? logDate,
    Value<String?>? dailyLogId,
    Value<String?>? driverId,
    Value<String?>? unitId,
    Value<String?>? policyVersionId,
    Value<Map<String, Object?>>? details,
    Value<DateTime?>? resolvedAt,
    Value<String?>? resolvedReason,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ViolationsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      occurredAt: occurredAt ?? this.occurredAt,
      logDate: logDate ?? this.logDate,
      dailyLogId: dailyLogId ?? this.dailyLogId,
      driverId: driverId ?? this.driverId,
      unitId: unitId ?? this.unitId,
      policyVersionId: policyVersionId ?? this.policyVersionId,
      details: details ?? this.details,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedReason: resolvedReason ?? this.resolvedReason,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (logDate.present) {
      map['log_date'] = Variable<String>(logDate.value);
    }
    if (dailyLogId.present) {
      map['daily_log_id'] = Variable<String>(dailyLogId.value);
    }
    if (driverId.present) {
      map['driver_id'] = Variable<String>(driverId.value);
    }
    if (unitId.present) {
      map['unit_id'] = Variable<String>(unitId.value);
    }
    if (policyVersionId.present) {
      map['policy_version_id'] = Variable<String>(policyVersionId.value);
    }
    if (details.present) {
      map['details'] = Variable<String>($ViolationsTable.$converterdetails.toSql(details.value));
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (resolvedReason.present) {
      map['resolved_reason'] = Variable<String>(resolvedReason.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ViolationsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('severity: $severity, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('logDate: $logDate, ')
          ..write('dailyLogId: $dailyLogId, ')
          ..write('driverId: $driverId, ')
          ..write('unitId: $unitId, ')
          ..write('policyVersionId: $policyVersionId, ')
          ..write('details: $details, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('resolvedReason: $resolvedReason, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RefDefectTypesTable extends RefDefectTypes
    with TableInfo<$RefDefectTypesTable, RefDefectTypeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RefDefectTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _appliesToMeta = const VerificationMeta('appliesTo');
  @override
  late final GeneratedColumn<String> appliesTo = GeneratedColumn<String>(
    'applies_to',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('vehicle'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, code, label, category, appliesTo, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ref_defect_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<RefDefectTypeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(_codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('label')) {
      context.handle(_labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('applies_to')) {
      context.handle(
        _appliesToMeta,
        appliesTo.isAcceptableOrUnknown(data['applies_to']!, _appliesToMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RefDefectTypeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RefDefectTypeRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      code: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      appliesTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}applies_to'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RefDefectTypesTable createAlias(String alias) {
    return $RefDefectTypesTable(attachedDatabase, alias);
  }
}

class RefDefectTypeRow extends DataClass implements Insertable<RefDefectTypeRow> {
  final String id;
  final String code;
  final String label;
  final String? category;

  /// `vehicle`/`trailer`.
  final String appliesTo;
  final DateTime updatedAt;
  const RefDefectTypeRow({
    required this.id,
    required this.code,
    required this.label,
    this.category,
    required this.appliesTo,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['applies_to'] = Variable<String>(appliesTo);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RefDefectTypesCompanion toCompanion(bool nullToAbsent) {
    return RefDefectTypesCompanion(
      id: Value(id),
      code: Value(code),
      label: Value(label),
      category: category == null && nullToAbsent ? const Value.absent() : Value(category),
      appliesTo: Value(appliesTo),
      updatedAt: Value(updatedAt),
    );
  }

  factory RefDefectTypeRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RefDefectTypeRow(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      label: serializer.fromJson<String>(json['label']),
      category: serializer.fromJson<String?>(json['category']),
      appliesTo: serializer.fromJson<String>(json['appliesTo']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'label': serializer.toJson<String>(label),
      'category': serializer.toJson<String?>(category),
      'appliesTo': serializer.toJson<String>(appliesTo),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RefDefectTypeRow copyWith({
    String? id,
    String? code,
    String? label,
    Value<String?> category = const Value.absent(),
    String? appliesTo,
    DateTime? updatedAt,
  }) => RefDefectTypeRow(
    id: id ?? this.id,
    code: code ?? this.code,
    label: label ?? this.label,
    category: category.present ? category.value : this.category,
    appliesTo: appliesTo ?? this.appliesTo,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RefDefectTypeRow copyWithCompanion(RefDefectTypesCompanion data) {
    return RefDefectTypeRow(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      label: data.label.present ? data.label.value : this.label,
      category: data.category.present ? data.category.value : this.category,
      appliesTo: data.appliesTo.present ? data.appliesTo.value : this.appliesTo,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RefDefectTypeRow(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('label: $label, ')
          ..write('category: $category, ')
          ..write('appliesTo: $appliesTo, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, code, label, category, appliesTo, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RefDefectTypeRow &&
          other.id == this.id &&
          other.code == this.code &&
          other.label == this.label &&
          other.category == this.category &&
          other.appliesTo == this.appliesTo &&
          other.updatedAt == this.updatedAt);
}

class RefDefectTypesCompanion extends UpdateCompanion<RefDefectTypeRow> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> label;
  final Value<String?> category;
  final Value<String> appliesTo;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RefDefectTypesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.label = const Value.absent(),
    this.category = const Value.absent(),
    this.appliesTo = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RefDefectTypesCompanion.insert({
    required String id,
    required String code,
    required String label,
    this.category = const Value.absent(),
    this.appliesTo = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       label = Value(label),
       updatedAt = Value(updatedAt);
  static Insertable<RefDefectTypeRow> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? label,
    Expression<String>? category,
    Expression<String>? appliesTo,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (label != null) 'label': label,
      if (category != null) 'category': category,
      if (appliesTo != null) 'applies_to': appliesTo,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RefDefectTypesCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<String>? label,
    Value<String?>? category,
    Value<String>? appliesTo,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RefDefectTypesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      label: label ?? this.label,
      category: category ?? this.category,
      appliesTo: appliesTo ?? this.appliesTo,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (appliesTo.present) {
      map['applies_to'] = Variable<String>(appliesTo.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RefDefectTypesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('label: $label, ')
          ..write('category: $category, ')
          ..write('appliesTo: $appliesTo, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RefQuickNotesTable extends RefQuickNotes
    with TableInfo<$RefQuickNotesTable, RefQuickNoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RefQuickNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, label, category, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ref_quick_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<RefQuickNoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('text')) {
      context.handle(_labelMeta, label.isAcceptableOrUnknown(data['text']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RefQuickNoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RefQuickNoteRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RefQuickNotesTable createAlias(String alias) {
    return $RefQuickNotesTable(attachedDatabase, alias);
  }
}

class RefQuickNoteRow extends DataClass implements Insertable<RefQuickNoteRow> {
  final String id;

  /// Getter nomi `label`, SQL ustuni `text` (drift `text()` quruvchisi bilan
  /// to'qnashmasligi uchun).
  final String label;
  final String? category;
  final DateTime updatedAt;
  const RefQuickNoteRow({
    required this.id,
    required this.label,
    this.category,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['text'] = Variable<String>(label);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RefQuickNotesCompanion toCompanion(bool nullToAbsent) {
    return RefQuickNotesCompanion(
      id: Value(id),
      label: Value(label),
      category: category == null && nullToAbsent ? const Value.absent() : Value(category),
      updatedAt: Value(updatedAt),
    );
  }

  factory RefQuickNoteRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RefQuickNoteRow(
      id: serializer.fromJson<String>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      category: serializer.fromJson<String?>(json['category']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'label': serializer.toJson<String>(label),
      'category': serializer.toJson<String?>(category),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RefQuickNoteRow copyWith({
    String? id,
    String? label,
    Value<String?> category = const Value.absent(),
    DateTime? updatedAt,
  }) => RefQuickNoteRow(
    id: id ?? this.id,
    label: label ?? this.label,
    category: category.present ? category.value : this.category,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RefQuickNoteRow copyWithCompanion(RefQuickNotesCompanion data) {
    return RefQuickNoteRow(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      category: data.category.present ? data.category.value : this.category,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RefQuickNoteRow(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('category: $category, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, label, category, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RefQuickNoteRow &&
          other.id == this.id &&
          other.label == this.label &&
          other.category == this.category &&
          other.updatedAt == this.updatedAt);
}

class RefQuickNotesCompanion extends UpdateCompanion<RefQuickNoteRow> {
  final Value<String> id;
  final Value<String> label;
  final Value<String?> category;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RefQuickNotesCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.category = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RefQuickNotesCompanion.insert({
    required String id,
    required String label,
    this.category = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       label = Value(label),
       updatedAt = Value(updatedAt);
  static Insertable<RefQuickNoteRow> custom({
    Expression<String>? id,
    Expression<String>? label,
    Expression<String>? category,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'text': label,
      if (category != null) 'category': category,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RefQuickNotesCompanion copyWith({
    Value<String>? id,
    Value<String>? label,
    Value<String?>? category,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RefQuickNotesCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      category: category ?? this.category,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (label.present) {
      map['text'] = Variable<String>(label.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RefQuickNotesCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('category: $category, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RefTrailersTable extends RefTrailers with TableInfo<$RefTrailersTable, RefTrailerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RefTrailersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<String> unitId = GeneratedColumn<String>(
    'unit_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, number, unitId, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ref_trailers';
  @override
  VerificationContext validateIntegrity(
    Insertable<RefTrailerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('number')) {
      context.handle(_numberMeta, number.isAcceptableOrUnknown(data['number']!, _numberMeta));
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('unit_id')) {
      context.handle(_unitIdMeta, unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RefTrailerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RefTrailerRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}number'],
      )!,
      unitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_id'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RefTrailersTable createAlias(String alias) {
    return $RefTrailersTable(attachedDatabase, alias);
  }
}

class RefTrailerRow extends DataClass implements Insertable<RefTrailerRow> {
  final String id;
  final String number;
  final String? unitId;
  final DateTime updatedAt;
  const RefTrailerRow({
    required this.id,
    required this.number,
    this.unitId,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['number'] = Variable<String>(number);
    if (!nullToAbsent || unitId != null) {
      map['unit_id'] = Variable<String>(unitId);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RefTrailersCompanion toCompanion(bool nullToAbsent) {
    return RefTrailersCompanion(
      id: Value(id),
      number: Value(number),
      unitId: unitId == null && nullToAbsent ? const Value.absent() : Value(unitId),
      updatedAt: Value(updatedAt),
    );
  }

  factory RefTrailerRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RefTrailerRow(
      id: serializer.fromJson<String>(json['id']),
      number: serializer.fromJson<String>(json['number']),
      unitId: serializer.fromJson<String?>(json['unitId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'number': serializer.toJson<String>(number),
      'unitId': serializer.toJson<String?>(unitId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RefTrailerRow copyWith({
    String? id,
    String? number,
    Value<String?> unitId = const Value.absent(),
    DateTime? updatedAt,
  }) => RefTrailerRow(
    id: id ?? this.id,
    number: number ?? this.number,
    unitId: unitId.present ? unitId.value : this.unitId,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RefTrailerRow copyWithCompanion(RefTrailersCompanion data) {
    return RefTrailerRow(
      id: data.id.present ? data.id.value : this.id,
      number: data.number.present ? data.number.value : this.number,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RefTrailerRow(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('unitId: $unitId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, number, unitId, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RefTrailerRow &&
          other.id == this.id &&
          other.number == this.number &&
          other.unitId == this.unitId &&
          other.updatedAt == this.updatedAt);
}

class RefTrailersCompanion extends UpdateCompanion<RefTrailerRow> {
  final Value<String> id;
  final Value<String> number;
  final Value<String?> unitId;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RefTrailersCompanion({
    this.id = const Value.absent(),
    this.number = const Value.absent(),
    this.unitId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RefTrailersCompanion.insert({
    required String id,
    required String number,
    this.unitId = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       number = Value(number),
       updatedAt = Value(updatedAt);
  static Insertable<RefTrailerRow> custom({
    Expression<String>? id,
    Expression<String>? number,
    Expression<String>? unitId,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (number != null) 'number': number,
      if (unitId != null) 'unit_id': unitId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RefTrailersCompanion copyWith({
    Value<String>? id,
    Value<String>? number,
    Value<String?>? unitId,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RefTrailersCompanion(
      id: id ?? this.id,
      number: number ?? this.number,
      unitId: unitId ?? this.unitId,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (unitId.present) {
      map['unit_id'] = Variable<String>(unitId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RefTrailersCompanion(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('unitId: $unitId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorTableTable extends SyncCursorTable
    with TableInfo<$SyncCursorTableTable, SyncCursorRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(1),
  );
  static const VerificationMeta _nextSinceMeta = const VerificationMeta('nextSince');
  @override
  late final GeneratedColumn<String> nextSince = GeneratedColumn<String>(
    'next_since',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPushAtMeta = const VerificationMeta('lastPushAt');
  @override
  late final GeneratedColumn<DateTime> lastPushAt = GeneratedColumn<DateTime>(
    'last_push_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPullAtMeta = const VerificationMeta('lastPullAt');
  @override
  late final GeneratedColumn<DateTime> lastPullAt = GeneratedColumn<DateTime>(
    'last_pull_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorAtMeta = const VerificationMeta('lastErrorAt');
  @override
  late final GeneratedColumn<DateTime> lastErrorAt = GeneratedColumn<DateTime>(
    'last_error_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nextSince,
    lastPushAt,
    lastPullAt,
    lastError,
    lastErrorAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursor';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncCursorRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('next_since')) {
      context.handle(
        _nextSinceMeta,
        nextSince.isAcceptableOrUnknown(data['next_since']!, _nextSinceMeta),
      );
    }
    if (data.containsKey('last_push_at')) {
      context.handle(
        _lastPushAtMeta,
        lastPushAt.isAcceptableOrUnknown(data['last_push_at']!, _lastPushAtMeta),
      );
    }
    if (data.containsKey('last_pull_at')) {
      context.handle(
        _lastPullAtMeta,
        lastPullAt.isAcceptableOrUnknown(data['last_pull_at']!, _lastPullAtMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('last_error_at')) {
      context.handle(
        _lastErrorAtMeta,
        lastErrorAt.isAcceptableOrUnknown(data['last_error_at']!, _lastErrorAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncCursorRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursorRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nextSince: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_since'],
      ),
      lastPushAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_push_at'],
      ),
      lastPullAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_pull_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      lastErrorAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_error_at'],
      ),
    );
  }

  @override
  $SyncCursorTableTable createAlias(String alias) {
    return $SyncCursorTableTable(attachedDatabase, alias);
  }
}

class SyncCursorRow extends DataClass implements Insertable<SyncCursorRow> {
  final int id;

  /// Server bergan kursor; mijoz **hech qachon** o'zi hisoblamaydi (M35).
  final String? nextSince;
  final DateTime? lastPushAt;
  final DateTime? lastPullAt;

  /// Oxirgi xato kodi (`M-54` diagnostikasi).
  final String? lastError;
  final DateTime? lastErrorAt;
  const SyncCursorRow({
    required this.id,
    this.nextSince,
    this.lastPushAt,
    this.lastPullAt,
    this.lastError,
    this.lastErrorAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || nextSince != null) {
      map['next_since'] = Variable<String>(nextSince);
    }
    if (!nullToAbsent || lastPushAt != null) {
      map['last_push_at'] = Variable<DateTime>(lastPushAt);
    }
    if (!nullToAbsent || lastPullAt != null) {
      map['last_pull_at'] = Variable<DateTime>(lastPullAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || lastErrorAt != null) {
      map['last_error_at'] = Variable<DateTime>(lastErrorAt);
    }
    return map;
  }

  SyncCursorTableCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorTableCompanion(
      id: Value(id),
      nextSince: nextSince == null && nullToAbsent ? const Value.absent() : Value(nextSince),
      lastPushAt: lastPushAt == null && nullToAbsent ? const Value.absent() : Value(lastPushAt),
      lastPullAt: lastPullAt == null && nullToAbsent ? const Value.absent() : Value(lastPullAt),
      lastError: lastError == null && nullToAbsent ? const Value.absent() : Value(lastError),
      lastErrorAt: lastErrorAt == null && nullToAbsent ? const Value.absent() : Value(lastErrorAt),
    );
  }

  factory SyncCursorRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursorRow(
      id: serializer.fromJson<int>(json['id']),
      nextSince: serializer.fromJson<String?>(json['nextSince']),
      lastPushAt: serializer.fromJson<DateTime?>(json['lastPushAt']),
      lastPullAt: serializer.fromJson<DateTime?>(json['lastPullAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      lastErrorAt: serializer.fromJson<DateTime?>(json['lastErrorAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nextSince': serializer.toJson<String?>(nextSince),
      'lastPushAt': serializer.toJson<DateTime?>(lastPushAt),
      'lastPullAt': serializer.toJson<DateTime?>(lastPullAt),
      'lastError': serializer.toJson<String?>(lastError),
      'lastErrorAt': serializer.toJson<DateTime?>(lastErrorAt),
    };
  }

  SyncCursorRow copyWith({
    int? id,
    Value<String?> nextSince = const Value.absent(),
    Value<DateTime?> lastPushAt = const Value.absent(),
    Value<DateTime?> lastPullAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    Value<DateTime?> lastErrorAt = const Value.absent(),
  }) => SyncCursorRow(
    id: id ?? this.id,
    nextSince: nextSince.present ? nextSince.value : this.nextSince,
    lastPushAt: lastPushAt.present ? lastPushAt.value : this.lastPushAt,
    lastPullAt: lastPullAt.present ? lastPullAt.value : this.lastPullAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    lastErrorAt: lastErrorAt.present ? lastErrorAt.value : this.lastErrorAt,
  );
  SyncCursorRow copyWithCompanion(SyncCursorTableCompanion data) {
    return SyncCursorRow(
      id: data.id.present ? data.id.value : this.id,
      nextSince: data.nextSince.present ? data.nextSince.value : this.nextSince,
      lastPushAt: data.lastPushAt.present ? data.lastPushAt.value : this.lastPushAt,
      lastPullAt: data.lastPullAt.present ? data.lastPullAt.value : this.lastPullAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      lastErrorAt: data.lastErrorAt.present ? data.lastErrorAt.value : this.lastErrorAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorRow(')
          ..write('id: $id, ')
          ..write('nextSince: $nextSince, ')
          ..write('lastPushAt: $lastPushAt, ')
          ..write('lastPullAt: $lastPullAt, ')
          ..write('lastError: $lastError, ')
          ..write('lastErrorAt: $lastErrorAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nextSince, lastPushAt, lastPullAt, lastError, lastErrorAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursorRow &&
          other.id == this.id &&
          other.nextSince == this.nextSince &&
          other.lastPushAt == this.lastPushAt &&
          other.lastPullAt == this.lastPullAt &&
          other.lastError == this.lastError &&
          other.lastErrorAt == this.lastErrorAt);
}

class SyncCursorTableCompanion extends UpdateCompanion<SyncCursorRow> {
  final Value<int> id;
  final Value<String?> nextSince;
  final Value<DateTime?> lastPushAt;
  final Value<DateTime?> lastPullAt;
  final Value<String?> lastError;
  final Value<DateTime?> lastErrorAt;
  const SyncCursorTableCompanion({
    this.id = const Value.absent(),
    this.nextSince = const Value.absent(),
    this.lastPushAt = const Value.absent(),
    this.lastPullAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.lastErrorAt = const Value.absent(),
  });
  SyncCursorTableCompanion.insert({
    this.id = const Value.absent(),
    this.nextSince = const Value.absent(),
    this.lastPushAt = const Value.absent(),
    this.lastPullAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.lastErrorAt = const Value.absent(),
  });
  static Insertable<SyncCursorRow> custom({
    Expression<int>? id,
    Expression<String>? nextSince,
    Expression<DateTime>? lastPushAt,
    Expression<DateTime>? lastPullAt,
    Expression<String>? lastError,
    Expression<DateTime>? lastErrorAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nextSince != null) 'next_since': nextSince,
      if (lastPushAt != null) 'last_push_at': lastPushAt,
      if (lastPullAt != null) 'last_pull_at': lastPullAt,
      if (lastError != null) 'last_error': lastError,
      if (lastErrorAt != null) 'last_error_at': lastErrorAt,
    });
  }

  SyncCursorTableCompanion copyWith({
    Value<int>? id,
    Value<String?>? nextSince,
    Value<DateTime?>? lastPushAt,
    Value<DateTime?>? lastPullAt,
    Value<String?>? lastError,
    Value<DateTime?>? lastErrorAt,
  }) {
    return SyncCursorTableCompanion(
      id: id ?? this.id,
      nextSince: nextSince ?? this.nextSince,
      lastPushAt: lastPushAt ?? this.lastPushAt,
      lastPullAt: lastPullAt ?? this.lastPullAt,
      lastError: lastError ?? this.lastError,
      lastErrorAt: lastErrorAt ?? this.lastErrorAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nextSince.present) {
      map['next_since'] = Variable<String>(nextSince.value);
    }
    if (lastPushAt.present) {
      map['last_push_at'] = Variable<DateTime>(lastPushAt.value);
    }
    if (lastPullAt.present) {
      map['last_pull_at'] = Variable<DateTime>(lastPullAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (lastErrorAt.present) {
      map['last_error_at'] = Variable<DateTime>(lastErrorAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorTableCompanion(')
          ..write('id: $id, ')
          ..write('nextSince: $nextSince, ')
          ..write('lastPushAt: $lastPushAt, ')
          ..write('lastPullAt: $lastPullAt, ')
          ..write('lastError: $lastError, ')
          ..write('lastErrorAt: $lastErrorAt')
          ..write(')'))
        .toString();
  }
}

class $KvSettingsTable extends KvSettings with TableInfo<$KvSettingsTable, KvSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KvSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kv_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<KvSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  KvSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KvSettingRow(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $KvSettingsTable createAlias(String alias) {
    return $KvSettingsTable(attachedDatabase, alias);
  }
}

class KvSettingRow extends DataClass implements Insertable<KvSettingRow> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const KvSettingRow({required this.key, required this.value, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  KvSettingsCompanion toCompanion(bool nullToAbsent) {
    return KvSettingsCompanion(key: Value(key), value: Value(value), updatedAt: Value(updatedAt));
  }

  factory KvSettingRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KvSettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  KvSettingRow copyWith({String? key, String? value, DateTime? updatedAt}) => KvSettingRow(
    key: key ?? this.key,
    value: value ?? this.value,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  KvSettingRow copyWithCompanion(KvSettingsCompanion data) {
    return KvSettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KvSettingRow(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KvSettingRow &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class KvSettingsCompanion extends UpdateCompanion<KvSettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const KvSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KvSettingsCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<KvSettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KvSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return KvSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KvSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $OutboxItemsTable outboxItems = $OutboxItemsTable(this);
  late final $DutyEventsTable dutyEvents = $DutyEventsTable(this);
  late final $TelemetryBufferTable telemetryBuffer = $TelemetryBufferTable(this);
  late final $DailyLogsTable dailyLogs = $DailyLogsTable(this);
  late final $HosStatesTable hosStates = $HosStatesTable(this);
  late final $HosPoliciesTable hosPolicies = $HosPoliciesTable(this);
  late final $DvirDraftsTable dvirDrafts = $DvirDraftsTable(this);
  late final $DvirReportsTable dvirReports = $DvirReportsTable(this);
  late final $FilesQueueTable filesQueue = $FilesQueueTable(this);
  late final $ChatOutboxTable chatOutbox = $ChatOutboxTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $NotificationsTable notifications = $NotificationsTable(this);
  late final $LogEditRequestsTable logEditRequests = $LogEditRequestsTable(this);
  late final $UnidentifiedEventsTable unidentifiedEvents = $UnidentifiedEventsTable(this);
  late final $ViolationsTable violations = $ViolationsTable(this);
  late final $RefDefectTypesTable refDefectTypes = $RefDefectTypesTable(this);
  late final $RefQuickNotesTable refQuickNotes = $RefQuickNotesTable(this);
  late final $RefTrailersTable refTrailers = $RefTrailersTable(this);
  late final $SyncCursorTableTable syncCursorTable = $SyncCursorTableTable(this);
  late final $KvSettingsTable kvSettings = $KvSettingsTable(this);
  late final Index idxOutboxReady = Index(
    'idx_outbox_ready',
    'CREATE INDEX idx_outbox_ready ON outbox_items (state, next_attempt_at, device_seq)',
  );
  late final Index idxOutboxKindState = Index(
    'idx_outbox_kind_state',
    'CREATE INDEX idx_outbox_kind_state ON outbox_items (kind, state)',
  );
  late final Index idxOutboxRejectSeen = Index(
    'idx_outbox_reject_seen',
    'CREATE INDEX idx_outbox_reject_seen ON outbox_items (state, reject_seen)',
  );
  late final Index idxDutyEventsTime = Index(
    'idx_duty_events_time',
    'CREATE INDEX idx_duty_events_time ON duty_events (event_time)',
  );
  late final Index idxDutyEventsSync = Index(
    'idx_duty_events_sync',
    'CREATE INDEX idx_duty_events_sync ON duty_events (sync_state)',
  );
  late final Index idxDutyEventsDriverDay = Index(
    'idx_duty_events_driver_day',
    'CREATE INDEX idx_duty_events_driver_day ON duty_events (driver_id, log_date)',
  );
  late final Index idxTelemetrySentTs = Index(
    'idx_telemetry_sent_ts',
    'CREATE INDEX idx_telemetry_sent_ts ON telemetry_buffer (sent, ts)',
  );
  late final Index idxDvirDraftsState = Index(
    'idx_dvir_drafts_state',
    'CREATE INDEX idx_dvir_drafts_state ON dvir_drafts (state, updated_at)',
  );
  late final Index idxDvirReportsCreated = Index(
    'idx_dvir_reports_created',
    'CREATE INDEX idx_dvir_reports_created ON dvir_reports (created_at)',
  );
  late final Index idxFilesQueueState = Index(
    'idx_files_queue_state',
    'CREATE INDEX idx_files_queue_state ON files_queue (state, attempts)',
  );
  late final Index idxChatOutboxStatus = Index(
    'idx_chat_outbox_status',
    'CREATE INDEX idx_chat_outbox_status ON chat_outbox (status, created_at)',
  );
  late final Index idxChatMessagesCreated = Index(
    'idx_chat_messages_created',
    'CREATE INDEX idx_chat_messages_created ON chat_messages (created_at)',
  );
  late final Index idxNotificationsRead = Index(
    'idx_notifications_read',
    'CREATE INDEX idx_notifications_read ON notifications (read, created_at)',
  );
  late final Index idxLogEditsStatus = Index(
    'idx_log_edits_status',
    'CREATE INDEX idx_log_edits_status ON log_edit_requests (status, created_at)',
  );
  late final Index idxUnidentifiedStatus = Index(
    'idx_unidentified_status',
    'CREATE INDEX idx_unidentified_status ON unidentified_events (status, start_at)',
  );
  late final Index idxViolationsOccurred = Index(
    'idx_violations_occurred',
    'CREATE INDEX idx_violations_occurred ON violations (occurred_at)',
  );
  late final Index idxViolationsLogDate = Index(
    'idx_violations_log_date',
    'CREATE INDEX idx_violations_log_date ON violations (log_date)',
  );
  late final OutboxDao outboxDao = OutboxDao(this as AppDatabase);
  late final DutyEventsDao dutyEventsDao = DutyEventsDao(this as AppDatabase);
  late final TelemetryDao telemetryDao = TelemetryDao(this as AppDatabase);
  late final LogsDao logsDao = LogsDao(this as AppDatabase);
  late final DvirDao dvirDao = DvirDao(this as AppDatabase);
  late final ChatDao chatDao = ChatDao(this as AppDatabase);
  late final RefDao refDao = RefDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    outboxItems,
    dutyEvents,
    telemetryBuffer,
    dailyLogs,
    hosStates,
    hosPolicies,
    dvirDrafts,
    dvirReports,
    filesQueue,
    chatOutbox,
    chatMessages,
    notifications,
    logEditRequests,
    unidentifiedEvents,
    violations,
    refDefectTypes,
    refQuickNotes,
    refTrailers,
    syncCursorTable,
    kvSettings,
    idxOutboxReady,
    idxOutboxKindState,
    idxOutboxRejectSeen,
    idxDutyEventsTime,
    idxDutyEventsSync,
    idxDutyEventsDriverDay,
    idxTelemetrySentTs,
    idxDvirDraftsState,
    idxDvirReportsCreated,
    idxFilesQueueState,
    idxChatOutboxStatus,
    idxChatMessagesCreated,
    idxNotificationsRead,
    idxLogEditsStatus,
    idxUnidentifiedStatus,
    idxViolationsOccurred,
    idxViolationsLogDate,
  ];
  @override
  DriftDatabaseOptions get options => const DriftDatabaseOptions(storeDateTimeAsText: true);
}
