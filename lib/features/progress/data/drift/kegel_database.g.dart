// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kegel_database.dart';

// ignore_for_file: type=lint
class $SessionRunsTable extends SessionRuns
    with TableInfo<$SessionRunsTable, SessionRun> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionRunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMsMeta = const VerificationMeta(
    'startedAtMs',
  );
  @override
  late final GeneratedColumn<int> startedAtMs = GeneratedColumn<int>(
    'started_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMsMeta = const VerificationMeta(
    'endedAtMs',
  );
  @override
  late final GeneratedColumn<int> endedAtMs = GeneratedColumn<int>(
    'ended_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _configJsonMeta = const VerificationMeta(
    'configJson',
  );
  @override
  late final GeneratedColumn<String> configJson = GeneratedColumn<String>(
    'config_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skippedPhaseCountMeta = const VerificationMeta(
    'skippedPhaseCount',
  );
  @override
  late final GeneratedColumn<int> skippedPhaseCount = GeneratedColumn<int>(
    'skipped_phase_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAtMs,
    endedAtMs,
    configJson,
    outcome,
    skippedPhaseCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionRun> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('started_at_ms')) {
      context.handle(
        _startedAtMsMeta,
        startedAtMs.isAcceptableOrUnknown(
          data['started_at_ms']!,
          _startedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedAtMsMeta);
    }
    if (data.containsKey('ended_at_ms')) {
      context.handle(
        _endedAtMsMeta,
        endedAtMs.isAcceptableOrUnknown(data['ended_at_ms']!, _endedAtMsMeta),
      );
    } else if (isInserting) {
      context.missing(_endedAtMsMeta);
    }
    if (data.containsKey('config_json')) {
      context.handle(
        _configJsonMeta,
        configJson.isAcceptableOrUnknown(data['config_json']!, _configJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_configJsonMeta);
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    } else if (isInserting) {
      context.missing(_outcomeMeta);
    }
    if (data.containsKey('skipped_phase_count')) {
      context.handle(
        _skippedPhaseCountMeta,
        skippedPhaseCount.isAcceptableOrUnknown(
          data['skipped_phase_count']!,
          _skippedPhaseCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionRun map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionRun(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      startedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at_ms'],
      )!,
      endedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at_ms'],
      )!,
      configJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config_json'],
      )!,
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      )!,
      skippedPhaseCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skipped_phase_count'],
      )!,
    );
  }

  @override
  $SessionRunsTable createAlias(String alias) {
    return $SessionRunsTable(attachedDatabase, alias);
  }
}

class SessionRun extends DataClass implements Insertable<SessionRun> {
  final String id;
  final int startedAtMs;
  final int endedAtMs;
  final String configJson;
  final String outcome;
  final int skippedPhaseCount;
  const SessionRun({
    required this.id,
    required this.startedAtMs,
    required this.endedAtMs,
    required this.configJson,
    required this.outcome,
    required this.skippedPhaseCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['started_at_ms'] = Variable<int>(startedAtMs);
    map['ended_at_ms'] = Variable<int>(endedAtMs);
    map['config_json'] = Variable<String>(configJson);
    map['outcome'] = Variable<String>(outcome);
    map['skipped_phase_count'] = Variable<int>(skippedPhaseCount);
    return map;
  }

  SessionRunsCompanion toCompanion(bool nullToAbsent) {
    return SessionRunsCompanion(
      id: Value(id),
      startedAtMs: Value(startedAtMs),
      endedAtMs: Value(endedAtMs),
      configJson: Value(configJson),
      outcome: Value(outcome),
      skippedPhaseCount: Value(skippedPhaseCount),
    );
  }

  factory SessionRun.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionRun(
      id: serializer.fromJson<String>(json['id']),
      startedAtMs: serializer.fromJson<int>(json['startedAtMs']),
      endedAtMs: serializer.fromJson<int>(json['endedAtMs']),
      configJson: serializer.fromJson<String>(json['configJson']),
      outcome: serializer.fromJson<String>(json['outcome']),
      skippedPhaseCount: serializer.fromJson<int>(json['skippedPhaseCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startedAtMs': serializer.toJson<int>(startedAtMs),
      'endedAtMs': serializer.toJson<int>(endedAtMs),
      'configJson': serializer.toJson<String>(configJson),
      'outcome': serializer.toJson<String>(outcome),
      'skippedPhaseCount': serializer.toJson<int>(skippedPhaseCount),
    };
  }

  SessionRun copyWith({
    String? id,
    int? startedAtMs,
    int? endedAtMs,
    String? configJson,
    String? outcome,
    int? skippedPhaseCount,
  }) => SessionRun(
    id: id ?? this.id,
    startedAtMs: startedAtMs ?? this.startedAtMs,
    endedAtMs: endedAtMs ?? this.endedAtMs,
    configJson: configJson ?? this.configJson,
    outcome: outcome ?? this.outcome,
    skippedPhaseCount: skippedPhaseCount ?? this.skippedPhaseCount,
  );
  SessionRun copyWithCompanion(SessionRunsCompanion data) {
    return SessionRun(
      id: data.id.present ? data.id.value : this.id,
      startedAtMs: data.startedAtMs.present
          ? data.startedAtMs.value
          : this.startedAtMs,
      endedAtMs: data.endedAtMs.present ? data.endedAtMs.value : this.endedAtMs,
      configJson: data.configJson.present
          ? data.configJson.value
          : this.configJson,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      skippedPhaseCount: data.skippedPhaseCount.present
          ? data.skippedPhaseCount.value
          : this.skippedPhaseCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionRun(')
          ..write('id: $id, ')
          ..write('startedAtMs: $startedAtMs, ')
          ..write('endedAtMs: $endedAtMs, ')
          ..write('configJson: $configJson, ')
          ..write('outcome: $outcome, ')
          ..write('skippedPhaseCount: $skippedPhaseCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAtMs,
    endedAtMs,
    configJson,
    outcome,
    skippedPhaseCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionRun &&
          other.id == this.id &&
          other.startedAtMs == this.startedAtMs &&
          other.endedAtMs == this.endedAtMs &&
          other.configJson == this.configJson &&
          other.outcome == this.outcome &&
          other.skippedPhaseCount == this.skippedPhaseCount);
}

class SessionRunsCompanion extends UpdateCompanion<SessionRun> {
  final Value<String> id;
  final Value<int> startedAtMs;
  final Value<int> endedAtMs;
  final Value<String> configJson;
  final Value<String> outcome;
  final Value<int> skippedPhaseCount;
  final Value<int> rowid;
  const SessionRunsCompanion({
    this.id = const Value.absent(),
    this.startedAtMs = const Value.absent(),
    this.endedAtMs = const Value.absent(),
    this.configJson = const Value.absent(),
    this.outcome = const Value.absent(),
    this.skippedPhaseCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionRunsCompanion.insert({
    required String id,
    required int startedAtMs,
    required int endedAtMs,
    required String configJson,
    required String outcome,
    this.skippedPhaseCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startedAtMs = Value(startedAtMs),
       endedAtMs = Value(endedAtMs),
       configJson = Value(configJson),
       outcome = Value(outcome);
  static Insertable<SessionRun> custom({
    Expression<String>? id,
    Expression<int>? startedAtMs,
    Expression<int>? endedAtMs,
    Expression<String>? configJson,
    Expression<String>? outcome,
    Expression<int>? skippedPhaseCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAtMs != null) 'started_at_ms': startedAtMs,
      if (endedAtMs != null) 'ended_at_ms': endedAtMs,
      if (configJson != null) 'config_json': configJson,
      if (outcome != null) 'outcome': outcome,
      if (skippedPhaseCount != null) 'skipped_phase_count': skippedPhaseCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionRunsCompanion copyWith({
    Value<String>? id,
    Value<int>? startedAtMs,
    Value<int>? endedAtMs,
    Value<String>? configJson,
    Value<String>? outcome,
    Value<int>? skippedPhaseCount,
    Value<int>? rowid,
  }) {
    return SessionRunsCompanion(
      id: id ?? this.id,
      startedAtMs: startedAtMs ?? this.startedAtMs,
      endedAtMs: endedAtMs ?? this.endedAtMs,
      configJson: configJson ?? this.configJson,
      outcome: outcome ?? this.outcome,
      skippedPhaseCount: skippedPhaseCount ?? this.skippedPhaseCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startedAtMs.present) {
      map['started_at_ms'] = Variable<int>(startedAtMs.value);
    }
    if (endedAtMs.present) {
      map['ended_at_ms'] = Variable<int>(endedAtMs.value);
    }
    if (configJson.present) {
      map['config_json'] = Variable<String>(configJson.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (skippedPhaseCount.present) {
      map['skipped_phase_count'] = Variable<int>(skippedPhaseCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionRunsCompanion(')
          ..write('id: $id, ')
          ..write('startedAtMs: $startedAtMs, ')
          ..write('endedAtMs: $endedAtMs, ')
          ..write('configJson: $configJson, ')
          ..write('outcome: $outcome, ')
          ..write('skippedPhaseCount: $skippedPhaseCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserPreferenceRowsTable extends UserPreferenceRows
    with TableInfo<$UserPreferenceRowsTable, UserPreferenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPreferenceRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionConfigMirrorJsonMeta =
      const VerificationMeta('sessionConfigMirrorJson');
  @override
  late final GeneratedColumn<String> sessionConfigMirrorJson =
      GeneratedColumn<String>(
        'session_config_mirror_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schemaVersion,
    sessionConfigMirrorJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_preference_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPreferenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    if (data.containsKey('session_config_mirror_json')) {
      context.handle(
        _sessionConfigMirrorJsonMeta,
        sessionConfigMirrorJson.isAcceptableOrUnknown(
          data['session_config_mirror_json']!,
          _sessionConfigMirrorJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserPreferenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPreferenceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      sessionConfigMirrorJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_config_mirror_json'],
      ),
    );
  }

  @override
  $UserPreferenceRowsTable createAlias(String alias) {
    return $UserPreferenceRowsTable(attachedDatabase, alias);
  }
}

class UserPreferenceRow extends DataClass
    implements Insertable<UserPreferenceRow> {
  final int id;
  final int schemaVersion;
  final String? sessionConfigMirrorJson;
  const UserPreferenceRow({
    required this.id,
    required this.schemaVersion,
    this.sessionConfigMirrorJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['schema_version'] = Variable<int>(schemaVersion);
    if (!nullToAbsent || sessionConfigMirrorJson != null) {
      map['session_config_mirror_json'] = Variable<String>(
        sessionConfigMirrorJson,
      );
    }
    return map;
  }

  UserPreferenceRowsCompanion toCompanion(bool nullToAbsent) {
    return UserPreferenceRowsCompanion(
      id: Value(id),
      schemaVersion: Value(schemaVersion),
      sessionConfigMirrorJson: sessionConfigMirrorJson == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionConfigMirrorJson),
    );
  }

  factory UserPreferenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPreferenceRow(
      id: serializer.fromJson<int>(json['id']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      sessionConfigMirrorJson: serializer.fromJson<String?>(
        json['sessionConfigMirrorJson'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'sessionConfigMirrorJson': serializer.toJson<String?>(
        sessionConfigMirrorJson,
      ),
    };
  }

  UserPreferenceRow copyWith({
    int? id,
    int? schemaVersion,
    Value<String?> sessionConfigMirrorJson = const Value.absent(),
  }) => UserPreferenceRow(
    id: id ?? this.id,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    sessionConfigMirrorJson: sessionConfigMirrorJson.present
        ? sessionConfigMirrorJson.value
        : this.sessionConfigMirrorJson,
  );
  UserPreferenceRow copyWithCompanion(UserPreferenceRowsCompanion data) {
    return UserPreferenceRow(
      id: data.id.present ? data.id.value : this.id,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      sessionConfigMirrorJson: data.sessionConfigMirrorJson.present
          ? data.sessionConfigMirrorJson.value
          : this.sessionConfigMirrorJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPreferenceRow(')
          ..write('id: $id, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('sessionConfigMirrorJson: $sessionConfigMirrorJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, schemaVersion, sessionConfigMirrorJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPreferenceRow &&
          other.id == this.id &&
          other.schemaVersion == this.schemaVersion &&
          other.sessionConfigMirrorJson == this.sessionConfigMirrorJson);
}

class UserPreferenceRowsCompanion extends UpdateCompanion<UserPreferenceRow> {
  final Value<int> id;
  final Value<int> schemaVersion;
  final Value<String?> sessionConfigMirrorJson;
  const UserPreferenceRowsCompanion({
    this.id = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.sessionConfigMirrorJson = const Value.absent(),
  });
  UserPreferenceRowsCompanion.insert({
    this.id = const Value.absent(),
    required int schemaVersion,
    this.sessionConfigMirrorJson = const Value.absent(),
  }) : schemaVersion = Value(schemaVersion);
  static Insertable<UserPreferenceRow> custom({
    Expression<int>? id,
    Expression<int>? schemaVersion,
    Expression<String>? sessionConfigMirrorJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (sessionConfigMirrorJson != null)
        'session_config_mirror_json': sessionConfigMirrorJson,
    });
  }

  UserPreferenceRowsCompanion copyWith({
    Value<int>? id,
    Value<int>? schemaVersion,
    Value<String?>? sessionConfigMirrorJson,
  }) {
    return UserPreferenceRowsCompanion(
      id: id ?? this.id,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      sessionConfigMirrorJson:
          sessionConfigMirrorJson ?? this.sessionConfigMirrorJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (sessionConfigMirrorJson.present) {
      map['session_config_mirror_json'] = Variable<String>(
        sessionConfigMirrorJson.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPreferenceRowsCompanion(')
          ..write('id: $id, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('sessionConfigMirrorJson: $sessionConfigMirrorJson')
          ..write(')'))
        .toString();
  }
}

abstract class _$KegelDatabase extends GeneratedDatabase {
  _$KegelDatabase(QueryExecutor e) : super(e);
  $KegelDatabaseManager get managers => $KegelDatabaseManager(this);
  late final $SessionRunsTable sessionRuns = $SessionRunsTable(this);
  late final $UserPreferenceRowsTable userPreferenceRows =
      $UserPreferenceRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sessionRuns,
    userPreferenceRows,
  ];
}

typedef $$SessionRunsTableCreateCompanionBuilder =
    SessionRunsCompanion Function({
      required String id,
      required int startedAtMs,
      required int endedAtMs,
      required String configJson,
      required String outcome,
      Value<int> skippedPhaseCount,
      Value<int> rowid,
    });
typedef $$SessionRunsTableUpdateCompanionBuilder =
    SessionRunsCompanion Function({
      Value<String> id,
      Value<int> startedAtMs,
      Value<int> endedAtMs,
      Value<String> configJson,
      Value<String> outcome,
      Value<int> skippedPhaseCount,
      Value<int> rowid,
    });

class $$SessionRunsTableFilterComposer
    extends Composer<_$KegelDatabase, $SessionRunsTable> {
  $$SessionRunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAtMs => $composableBuilder(
    column: $table.endedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skippedPhaseCount => $composableBuilder(
    column: $table.skippedPhaseCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionRunsTableOrderingComposer
    extends Composer<_$KegelDatabase, $SessionRunsTable> {
  $$SessionRunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAtMs => $composableBuilder(
    column: $table.endedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skippedPhaseCount => $composableBuilder(
    column: $table.skippedPhaseCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionRunsTableAnnotationComposer
    extends Composer<_$KegelDatabase, $SessionRunsTable> {
  $$SessionRunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endedAtMs =>
      $composableBuilder(column: $table.endedAtMs, builder: (column) => column);

  GeneratedColumn<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<int> get skippedPhaseCount => $composableBuilder(
    column: $table.skippedPhaseCount,
    builder: (column) => column,
  );
}

class $$SessionRunsTableTableManager
    extends
        RootTableManager<
          _$KegelDatabase,
          $SessionRunsTable,
          SessionRun,
          $$SessionRunsTableFilterComposer,
          $$SessionRunsTableOrderingComposer,
          $$SessionRunsTableAnnotationComposer,
          $$SessionRunsTableCreateCompanionBuilder,
          $$SessionRunsTableUpdateCompanionBuilder,
          (
            SessionRun,
            BaseReferences<_$KegelDatabase, $SessionRunsTable, SessionRun>,
          ),
          SessionRun,
          PrefetchHooks Function()
        > {
  $$SessionRunsTableTableManager(_$KegelDatabase db, $SessionRunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionRunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionRunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionRunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> startedAtMs = const Value.absent(),
                Value<int> endedAtMs = const Value.absent(),
                Value<String> configJson = const Value.absent(),
                Value<String> outcome = const Value.absent(),
                Value<int> skippedPhaseCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionRunsCompanion(
                id: id,
                startedAtMs: startedAtMs,
                endedAtMs: endedAtMs,
                configJson: configJson,
                outcome: outcome,
                skippedPhaseCount: skippedPhaseCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int startedAtMs,
                required int endedAtMs,
                required String configJson,
                required String outcome,
                Value<int> skippedPhaseCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionRunsCompanion.insert(
                id: id,
                startedAtMs: startedAtMs,
                endedAtMs: endedAtMs,
                configJson: configJson,
                outcome: outcome,
                skippedPhaseCount: skippedPhaseCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionRunsTableProcessedTableManager =
    ProcessedTableManager<
      _$KegelDatabase,
      $SessionRunsTable,
      SessionRun,
      $$SessionRunsTableFilterComposer,
      $$SessionRunsTableOrderingComposer,
      $$SessionRunsTableAnnotationComposer,
      $$SessionRunsTableCreateCompanionBuilder,
      $$SessionRunsTableUpdateCompanionBuilder,
      (
        SessionRun,
        BaseReferences<_$KegelDatabase, $SessionRunsTable, SessionRun>,
      ),
      SessionRun,
      PrefetchHooks Function()
    >;
typedef $$UserPreferenceRowsTableCreateCompanionBuilder =
    UserPreferenceRowsCompanion Function({
      Value<int> id,
      required int schemaVersion,
      Value<String?> sessionConfigMirrorJson,
    });
typedef $$UserPreferenceRowsTableUpdateCompanionBuilder =
    UserPreferenceRowsCompanion Function({
      Value<int> id,
      Value<int> schemaVersion,
      Value<String?> sessionConfigMirrorJson,
    });

class $$UserPreferenceRowsTableFilterComposer
    extends Composer<_$KegelDatabase, $UserPreferenceRowsTable> {
  $$UserPreferenceRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionConfigMirrorJson => $composableBuilder(
    column: $table.sessionConfigMirrorJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserPreferenceRowsTableOrderingComposer
    extends Composer<_$KegelDatabase, $UserPreferenceRowsTable> {
  $$UserPreferenceRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionConfigMirrorJson => $composableBuilder(
    column: $table.sessionConfigMirrorJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserPreferenceRowsTableAnnotationComposer
    extends Composer<_$KegelDatabase, $UserPreferenceRowsTable> {
  $$UserPreferenceRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sessionConfigMirrorJson => $composableBuilder(
    column: $table.sessionConfigMirrorJson,
    builder: (column) => column,
  );
}

class $$UserPreferenceRowsTableTableManager
    extends
        RootTableManager<
          _$KegelDatabase,
          $UserPreferenceRowsTable,
          UserPreferenceRow,
          $$UserPreferenceRowsTableFilterComposer,
          $$UserPreferenceRowsTableOrderingComposer,
          $$UserPreferenceRowsTableAnnotationComposer,
          $$UserPreferenceRowsTableCreateCompanionBuilder,
          $$UserPreferenceRowsTableUpdateCompanionBuilder,
          (
            UserPreferenceRow,
            BaseReferences<
              _$KegelDatabase,
              $UserPreferenceRowsTable,
              UserPreferenceRow
            >,
          ),
          UserPreferenceRow,
          PrefetchHooks Function()
        > {
  $$UserPreferenceRowsTableTableManager(
    _$KegelDatabase db,
    $UserPreferenceRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPreferenceRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPreferenceRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPreferenceRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<String?> sessionConfigMirrorJson = const Value.absent(),
              }) => UserPreferenceRowsCompanion(
                id: id,
                schemaVersion: schemaVersion,
                sessionConfigMirrorJson: sessionConfigMirrorJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int schemaVersion,
                Value<String?> sessionConfigMirrorJson = const Value.absent(),
              }) => UserPreferenceRowsCompanion.insert(
                id: id,
                schemaVersion: schemaVersion,
                sessionConfigMirrorJson: sessionConfigMirrorJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserPreferenceRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$KegelDatabase,
      $UserPreferenceRowsTable,
      UserPreferenceRow,
      $$UserPreferenceRowsTableFilterComposer,
      $$UserPreferenceRowsTableOrderingComposer,
      $$UserPreferenceRowsTableAnnotationComposer,
      $$UserPreferenceRowsTableCreateCompanionBuilder,
      $$UserPreferenceRowsTableUpdateCompanionBuilder,
      (
        UserPreferenceRow,
        BaseReferences<
          _$KegelDatabase,
          $UserPreferenceRowsTable,
          UserPreferenceRow
        >,
      ),
      UserPreferenceRow,
      PrefetchHooks Function()
    >;

class $KegelDatabaseManager {
  final _$KegelDatabase _db;
  $KegelDatabaseManager(this._db);
  $$SessionRunsTableTableManager get sessionRuns =>
      $$SessionRunsTableTableManager(_db, _db.sessionRuns);
  $$UserPreferenceRowsTableTableManager get userPreferenceRows =>
      $$UserPreferenceRowsTableTableManager(_db, _db.userPreferenceRows);
}
