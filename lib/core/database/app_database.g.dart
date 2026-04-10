// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 200),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 1000),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TaskType, int> type =
      GeneratedColumn<int>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<TaskType>($TasksTable.$convertertype);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TaskStatus, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<TaskStatus>($TasksTable.$converterstatus);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snoozeUntilMeta = const VerificationMeta(
    'snoozeUntil',
  );
  @override
  late final GeneratedColumn<DateTime> snoozeUntil = GeneratedColumn<DateTime>(
    'snooze_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Priority, int> priority =
      GeneratedColumn<int>(
        'priority',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<Priority>($TasksTable.$converterpriority);
  static const VerificationMeta _labelsMeta = const VerificationMeta('labels');
  @override
  late final GeneratedColumn<String> labels = GeneratedColumn<String>(
    'labels',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    notes,
    type,
    date,
    status,
    createdAt,
    resolvedAt,
    snoozeUntil,
    sortOrder,
    priority,
    labels,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
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
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    if (data.containsKey('snooze_until')) {
      context.handle(
        _snoozeUntilMeta,
        snoozeUntil.isAcceptableOrUnknown(
          data['snooze_until']!,
          _snoozeUntilMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('labels')) {
      context.handle(
        _labelsMeta,
        labels.isAcceptableOrUnknown(data['labels']!, _labelsMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      type: $TasksTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}type'],
        )!,
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      ),
      status: $TasksTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
      snoozeUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}snooze_until'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      priority: $TasksTable.$converterpriority.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}priority'],
        )!,
      ),
      labels: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}labels'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TaskType, int, int> $convertertype =
      const EnumIndexConverter<TaskType>(TaskType.values);
  static JsonTypeConverter2<TaskStatus, int, int> $converterstatus =
      const EnumIndexConverter<TaskStatus>(TaskStatus.values);
  static JsonTypeConverter2<Priority, int, int> $converterpriority =
      const EnumIndexConverter<Priority>(Priority.values);
}

class Task extends DataClass implements Insertable<Task> {
  final String id;
  final String title;
  final String? notes;
  final TaskType type;
  final DateTime? date;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final DateTime? snoozeUntil;
  final int sortOrder;
  final Priority priority;
  final String labels;
  final bool isDeleted;
  const Task({
    required this.id,
    required this.title,
    this.notes,
    required this.type,
    this.date,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    this.snoozeUntil,
    required this.sortOrder,
    required this.priority,
    required this.labels,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    {
      map['type'] = Variable<int>($TasksTable.$convertertype.toSql(type));
    }
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<DateTime>(date);
    }
    {
      map['status'] = Variable<int>($TasksTable.$converterstatus.toSql(status));
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    if (!nullToAbsent || snoozeUntil != null) {
      map['snooze_until'] = Variable<DateTime>(snoozeUntil);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    {
      map['priority'] = Variable<int>(
        $TasksTable.$converterpriority.toSql(priority),
      );
    }
    map['labels'] = Variable<String>(labels);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      type: Value(type),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      status: Value(status),
      createdAt: Value(createdAt),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
      snoozeUntil: snoozeUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozeUntil),
      sortOrder: Value(sortOrder),
      priority: Value(priority),
      labels: Value(labels),
      isDeleted: Value(isDeleted),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String?>(json['notes']),
      type: $TasksTable.$convertertype.fromJson(
        serializer.fromJson<int>(json['type']),
      ),
      date: serializer.fromJson<DateTime?>(json['date']),
      status: $TasksTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
      snoozeUntil: serializer.fromJson<DateTime?>(json['snoozeUntil']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      priority: $TasksTable.$converterpriority.fromJson(
        serializer.fromJson<int>(json['priority']),
      ),
      labels: serializer.fromJson<String>(json['labels']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String?>(notes),
      'type': serializer.toJson<int>($TasksTable.$convertertype.toJson(type)),
      'date': serializer.toJson<DateTime?>(date),
      'status': serializer.toJson<int>(
        $TasksTable.$converterstatus.toJson(status),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
      'snoozeUntil': serializer.toJson<DateTime?>(snoozeUntil),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'priority': serializer.toJson<int>(
        $TasksTable.$converterpriority.toJson(priority),
      ),
      'labels': serializer.toJson<String>(labels),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  Task copyWith({
    String? id,
    String? title,
    Value<String?> notes = const Value.absent(),
    TaskType? type,
    Value<DateTime?> date = const Value.absent(),
    TaskStatus? status,
    DateTime? createdAt,
    Value<DateTime?> resolvedAt = const Value.absent(),
    Value<DateTime?> snoozeUntil = const Value.absent(),
    int? sortOrder,
    Priority? priority,
    String? labels,
    bool? isDeleted,
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    notes: notes.present ? notes.value : this.notes,
    type: type ?? this.type,
    date: date.present ? date.value : this.date,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
    snoozeUntil: snoozeUntil.present ? snoozeUntil.value : this.snoozeUntil,
    sortOrder: sortOrder ?? this.sortOrder,
    priority: priority ?? this.priority,
    labels: labels ?? this.labels,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      type: data.type.present ? data.type.value : this.type,
      date: data.date.present ? data.date.value : this.date,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
      snoozeUntil: data.snoozeUntil.present
          ? data.snoozeUntil.value
          : this.snoozeUntil,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      priority: data.priority.present ? data.priority.value : this.priority,
      labels: data.labels.present ? data.labels.value : this.labels,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('type: $type, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('snoozeUntil: $snoozeUntil, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('priority: $priority, ')
          ..write('labels: $labels, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    notes,
    type,
    date,
    status,
    createdAt,
    resolvedAt,
    snoozeUntil,
    sortOrder,
    priority,
    labels,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.type == this.type &&
          other.date == this.date &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.resolvedAt == this.resolvedAt &&
          other.snoozeUntil == this.snoozeUntil &&
          other.sortOrder == this.sortOrder &&
          other.priority == this.priority &&
          other.labels == this.labels &&
          other.isDeleted == this.isDeleted);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> notes;
  final Value<TaskType> type;
  final Value<DateTime?> date;
  final Value<TaskStatus> status;
  final Value<DateTime> createdAt;
  final Value<DateTime?> resolvedAt;
  final Value<DateTime?> snoozeUntil;
  final Value<int> sortOrder;
  final Value<Priority> priority;
  final Value<String> labels;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.type = const Value.absent(),
    this.date = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.snoozeUntil = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.priority = const Value.absent(),
    this.labels = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String title,
    this.notes = const Value.absent(),
    required TaskType type,
    this.date = const Value.absent(),
    required TaskStatus status,
    required DateTime createdAt,
    this.resolvedAt = const Value.absent(),
    this.snoozeUntil = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.priority = const Value.absent(),
    this.labels = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       type = Value(type),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<Task> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<int>? type,
    Expression<DateTime>? date,
    Expression<int>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? resolvedAt,
    Expression<DateTime>? snoozeUntil,
    Expression<int>? sortOrder,
    Expression<int>? priority,
    Expression<String>? labels,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (type != null) 'type': type,
      if (date != null) 'date': date,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (snoozeUntil != null) 'snooze_until': snoozeUntil,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (priority != null) 'priority': priority,
      if (labels != null) 'labels': labels,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? notes,
    Value<TaskType>? type,
    Value<DateTime?>? date,
    Value<TaskStatus>? status,
    Value<DateTime>? createdAt,
    Value<DateTime?>? resolvedAt,
    Value<DateTime?>? snoozeUntil,
    Value<int>? sortOrder,
    Value<Priority>? priority,
    Value<String>? labels,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      type: type ?? this.type,
      date: date ?? this.date,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      snoozeUntil: snoozeUntil ?? this.snoozeUntil,
      sortOrder: sortOrder ?? this.sortOrder,
      priority: priority ?? this.priority,
      labels: labels ?? this.labels,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (type.present) {
      map['type'] = Variable<int>($TasksTable.$convertertype.toSql(type.value));
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $TasksTable.$converterstatus.toSql(status.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (snoozeUntil.present) {
      map['snooze_until'] = Variable<DateTime>(snoozeUntil.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(
        $TasksTable.$converterpriority.toSql(priority.value),
      );
    }
    if (labels.present) {
      map['labels'] = Variable<String>(labels.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('type: $type, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('snoozeUntil: $snoozeUntil, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('priority: $priority, ')
          ..write('labels: $labels, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyInstancesTable extends DailyInstances
    with TableInfo<$DailyInstancesTable, DailyInstance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyInstancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tasks (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TaskStatus, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<TaskStatus>($DailyInstancesTable.$converterstatus);
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snoozeUntilMeta = const VerificationMeta(
    'snoozeUntil',
  );
  @override
  late final GeneratedColumn<DateTime> snoozeUntil = GeneratedColumn<DateTime>(
    'snooze_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skippedMeta = const VerificationMeta(
    'skipped',
  );
  @override
  late final GeneratedColumn<bool> skipped = GeneratedColumn<bool>(
    'skipped',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("skipped" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Priority?, int> priority =
      GeneratedColumn<int>(
        'priority',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<Priority?>($DailyInstancesTable.$converterpriorityn);
  static const VerificationMeta _labelsMeta = const VerificationMeta('labels');
  @override
  late final GeneratedColumn<String> labels = GeneratedColumn<String>(
    'labels',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    date,
    status,
    resolvedAt,
    snoozeUntil,
    skipped,
    priority,
    labels,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_instances';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyInstance> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    if (data.containsKey('snooze_until')) {
      context.handle(
        _snoozeUntilMeta,
        snoozeUntil.isAcceptableOrUnknown(
          data['snooze_until']!,
          _snoozeUntilMeta,
        ),
      );
    }
    if (data.containsKey('skipped')) {
      context.handle(
        _skippedMeta,
        skipped.isAcceptableOrUnknown(data['skipped']!, _skippedMeta),
      );
    }
    if (data.containsKey('labels')) {
      context.handle(
        _labelsMeta,
        labels.isAcceptableOrUnknown(data['labels']!, _labelsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyInstance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyInstance(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      status: $DailyInstancesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
      snoozeUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}snooze_until'],
      ),
      skipped: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}skipped'],
      )!,
      priority: $DailyInstancesTable.$converterpriorityn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}priority'],
        ),
      ),
      labels: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}labels'],
      ),
    );
  }

  @override
  $DailyInstancesTable createAlias(String alias) {
    return $DailyInstancesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TaskStatus, int, int> $converterstatus =
      const EnumIndexConverter<TaskStatus>(TaskStatus.values);
  static JsonTypeConverter2<Priority, int, int> $converterpriority =
      const EnumIndexConverter<Priority>(Priority.values);
  static JsonTypeConverter2<Priority?, int?, int?> $converterpriorityn =
      JsonTypeConverter2.asNullable($converterpriority);
}

class DailyInstance extends DataClass implements Insertable<DailyInstance> {
  final String id;
  final String taskId;
  final DateTime date;
  final TaskStatus status;
  final DateTime? resolvedAt;
  final DateTime? snoozeUntil;
  final bool skipped;
  final Priority? priority;
  final String? labels;
  const DailyInstance({
    required this.id,
    required this.taskId,
    required this.date,
    required this.status,
    this.resolvedAt,
    this.snoozeUntil,
    required this.skipped,
    this.priority,
    this.labels,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['date'] = Variable<DateTime>(date);
    {
      map['status'] = Variable<int>(
        $DailyInstancesTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    if (!nullToAbsent || snoozeUntil != null) {
      map['snooze_until'] = Variable<DateTime>(snoozeUntil);
    }
    map['skipped'] = Variable<bool>(skipped);
    if (!nullToAbsent || priority != null) {
      map['priority'] = Variable<int>(
        $DailyInstancesTable.$converterpriorityn.toSql(priority),
      );
    }
    if (!nullToAbsent || labels != null) {
      map['labels'] = Variable<String>(labels);
    }
    return map;
  }

  DailyInstancesCompanion toCompanion(bool nullToAbsent) {
    return DailyInstancesCompanion(
      id: Value(id),
      taskId: Value(taskId),
      date: Value(date),
      status: Value(status),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
      snoozeUntil: snoozeUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozeUntil),
      skipped: Value(skipped),
      priority: priority == null && nullToAbsent
          ? const Value.absent()
          : Value(priority),
      labels: labels == null && nullToAbsent
          ? const Value.absent()
          : Value(labels),
    );
  }

  factory DailyInstance.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyInstance(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      date: serializer.fromJson<DateTime>(json['date']),
      status: $DailyInstancesTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
      snoozeUntil: serializer.fromJson<DateTime?>(json['snoozeUntil']),
      skipped: serializer.fromJson<bool>(json['skipped']),
      priority: $DailyInstancesTable.$converterpriorityn.fromJson(
        serializer.fromJson<int?>(json['priority']),
      ),
      labels: serializer.fromJson<String?>(json['labels']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'date': serializer.toJson<DateTime>(date),
      'status': serializer.toJson<int>(
        $DailyInstancesTable.$converterstatus.toJson(status),
      ),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
      'snoozeUntil': serializer.toJson<DateTime?>(snoozeUntil),
      'skipped': serializer.toJson<bool>(skipped),
      'priority': serializer.toJson<int?>(
        $DailyInstancesTable.$converterpriorityn.toJson(priority),
      ),
      'labels': serializer.toJson<String?>(labels),
    };
  }

  DailyInstance copyWith({
    String? id,
    String? taskId,
    DateTime? date,
    TaskStatus? status,
    Value<DateTime?> resolvedAt = const Value.absent(),
    Value<DateTime?> snoozeUntil = const Value.absent(),
    bool? skipped,
    Value<Priority?> priority = const Value.absent(),
    Value<String?> labels = const Value.absent(),
  }) => DailyInstance(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    date: date ?? this.date,
    status: status ?? this.status,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
    snoozeUntil: snoozeUntil.present ? snoozeUntil.value : this.snoozeUntil,
    skipped: skipped ?? this.skipped,
    priority: priority.present ? priority.value : this.priority,
    labels: labels.present ? labels.value : this.labels,
  );
  DailyInstance copyWithCompanion(DailyInstancesCompanion data) {
    return DailyInstance(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      date: data.date.present ? data.date.value : this.date,
      status: data.status.present ? data.status.value : this.status,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
      snoozeUntil: data.snoozeUntil.present
          ? data.snoozeUntil.value
          : this.snoozeUntil,
      skipped: data.skipped.present ? data.skipped.value : this.skipped,
      priority: data.priority.present ? data.priority.value : this.priority,
      labels: data.labels.present ? data.labels.value : this.labels,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyInstance(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('snoozeUntil: $snoozeUntil, ')
          ..write('skipped: $skipped, ')
          ..write('priority: $priority, ')
          ..write('labels: $labels')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    taskId,
    date,
    status,
    resolvedAt,
    snoozeUntil,
    skipped,
    priority,
    labels,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyInstance &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.date == this.date &&
          other.status == this.status &&
          other.resolvedAt == this.resolvedAt &&
          other.snoozeUntil == this.snoozeUntil &&
          other.skipped == this.skipped &&
          other.priority == this.priority &&
          other.labels == this.labels);
}

class DailyInstancesCompanion extends UpdateCompanion<DailyInstance> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<DateTime> date;
  final Value<TaskStatus> status;
  final Value<DateTime?> resolvedAt;
  final Value<DateTime?> snoozeUntil;
  final Value<bool> skipped;
  final Value<Priority?> priority;
  final Value<String?> labels;
  final Value<int> rowid;
  const DailyInstancesCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.date = const Value.absent(),
    this.status = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.snoozeUntil = const Value.absent(),
    this.skipped = const Value.absent(),
    this.priority = const Value.absent(),
    this.labels = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyInstancesCompanion.insert({
    required String id,
    required String taskId,
    required DateTime date,
    required TaskStatus status,
    this.resolvedAt = const Value.absent(),
    this.snoozeUntil = const Value.absent(),
    this.skipped = const Value.absent(),
    this.priority = const Value.absent(),
    this.labels = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taskId = Value(taskId),
       date = Value(date),
       status = Value(status);
  static Insertable<DailyInstance> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<DateTime>? date,
    Expression<int>? status,
    Expression<DateTime>? resolvedAt,
    Expression<DateTime>? snoozeUntil,
    Expression<bool>? skipped,
    Expression<int>? priority,
    Expression<String>? labels,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (date != null) 'date': date,
      if (status != null) 'status': status,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (snoozeUntil != null) 'snooze_until': snoozeUntil,
      if (skipped != null) 'skipped': skipped,
      if (priority != null) 'priority': priority,
      if (labels != null) 'labels': labels,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyInstancesCompanion copyWith({
    Value<String>? id,
    Value<String>? taskId,
    Value<DateTime>? date,
    Value<TaskStatus>? status,
    Value<DateTime?>? resolvedAt,
    Value<DateTime?>? snoozeUntil,
    Value<bool>? skipped,
    Value<Priority?>? priority,
    Value<String?>? labels,
    Value<int>? rowid,
  }) {
    return DailyInstancesCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      date: date ?? this.date,
      status: status ?? this.status,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      snoozeUntil: snoozeUntil ?? this.snoozeUntil,
      skipped: skipped ?? this.skipped,
      priority: priority ?? this.priority,
      labels: labels ?? this.labels,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $DailyInstancesTable.$converterstatus.toSql(status.value),
      );
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (snoozeUntil.present) {
      map['snooze_until'] = Variable<DateTime>(snoozeUntil.value);
    }
    if (skipped.present) {
      map['skipped'] = Variable<bool>(skipped.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(
        $DailyInstancesTable.$converterpriorityn.toSql(priority.value),
      );
    }
    if (labels.present) {
      map['labels'] = Variable<String>(labels.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyInstancesCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('snoozeUntil: $snoozeUntil, ')
          ..write('skipped: $skipped, ')
          ..write('priority: $priority, ')
          ..write('labels: $labels, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _bedtimeMeta = const VerificationMeta(
    'bedtime',
  );
  @override
  late final GeneratedColumn<DateTime> bedtime = GeneratedColumn<DateTime>(
    'bedtime',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _morningCheckinMeta = const VerificationMeta(
    'morningCheckin',
  );
  @override
  late final GeneratedColumn<DateTime> morningCheckin =
      GeneratedColumn<DateTime>(
        'morning_checkin',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  late final GeneratedColumnWithTypeConverter<NotificationMode, int>
  notificationMode = GeneratedColumn<int>(
    'notification_mode',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  ).withConverter<NotificationMode>($SettingsTable.$converternotificationMode);
  static const VerificationMeta _onboardingCompletedMeta =
      const VerificationMeta('onboardingCompleted');
  @override
  late final GeneratedColumn<bool> onboardingCompleted = GeneratedColumn<bool>(
    'onboarding_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notificationPermissionAskedMeta =
      const VerificationMeta('notificationPermissionAsked');
  @override
  late final GeneratedColumn<bool> notificationPermissionAsked =
      GeneratedColumn<bool>(
        'notification_permission_asked',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notification_permission_asked" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _notificationBannerDismissalsMeta =
      const VerificationMeta('notificationBannerDismissals');
  @override
  late final GeneratedColumn<int> notificationBannerDismissals =
      GeneratedColumn<int>(
        'notification_banner_dismissals',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _lastBannerDismissedAtMeta =
      const VerificationMeta('lastBannerDismissedAt');
  @override
  late final GeneratedColumn<DateTime> lastBannerDismissedAt =
      GeneratedColumn<DateTime>(
        'last_banner_dismissed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bedtime,
    morningCheckin,
    notificationMode,
    onboardingCompleted,
    notificationPermissionAsked,
    notificationBannerDismissals,
    lastBannerDismissedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bedtime')) {
      context.handle(
        _bedtimeMeta,
        bedtime.isAcceptableOrUnknown(data['bedtime']!, _bedtimeMeta),
      );
    } else if (isInserting) {
      context.missing(_bedtimeMeta);
    }
    if (data.containsKey('morning_checkin')) {
      context.handle(
        _morningCheckinMeta,
        morningCheckin.isAcceptableOrUnknown(
          data['morning_checkin']!,
          _morningCheckinMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_morningCheckinMeta);
    }
    if (data.containsKey('onboarding_completed')) {
      context.handle(
        _onboardingCompletedMeta,
        onboardingCompleted.isAcceptableOrUnknown(
          data['onboarding_completed']!,
          _onboardingCompletedMeta,
        ),
      );
    }
    if (data.containsKey('notification_permission_asked')) {
      context.handle(
        _notificationPermissionAskedMeta,
        notificationPermissionAsked.isAcceptableOrUnknown(
          data['notification_permission_asked']!,
          _notificationPermissionAskedMeta,
        ),
      );
    }
    if (data.containsKey('notification_banner_dismissals')) {
      context.handle(
        _notificationBannerDismissalsMeta,
        notificationBannerDismissals.isAcceptableOrUnknown(
          data['notification_banner_dismissals']!,
          _notificationBannerDismissalsMeta,
        ),
      );
    }
    if (data.containsKey('last_banner_dismissed_at')) {
      context.handle(
        _lastBannerDismissedAtMeta,
        lastBannerDismissedAt.isAcceptableOrUnknown(
          data['last_banner_dismissed_at']!,
          _lastBannerDismissedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bedtime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}bedtime'],
      )!,
      morningCheckin: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}morning_checkin'],
      )!,
      notificationMode: $SettingsTable.$converternotificationMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}notification_mode'],
        )!,
      ),
      onboardingCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_completed'],
      )!,
      notificationPermissionAsked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notification_permission_asked'],
      )!,
      notificationBannerDismissals: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notification_banner_dismissals'],
      )!,
      lastBannerDismissedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_banner_dismissed_at'],
      ),
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<NotificationMode, int, int>
  $converternotificationMode = const EnumIndexConverter<NotificationMode>(
    NotificationMode.values,
  );
}

class Setting extends DataClass implements Insertable<Setting> {
  final int id;
  final DateTime bedtime;
  final DateTime morningCheckin;
  final NotificationMode notificationMode;
  final bool onboardingCompleted;
  final bool notificationPermissionAsked;
  final int notificationBannerDismissals;
  final DateTime? lastBannerDismissedAt;
  const Setting({
    required this.id,
    required this.bedtime,
    required this.morningCheckin,
    required this.notificationMode,
    required this.onboardingCompleted,
    required this.notificationPermissionAsked,
    required this.notificationBannerDismissals,
    this.lastBannerDismissedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bedtime'] = Variable<DateTime>(bedtime);
    map['morning_checkin'] = Variable<DateTime>(morningCheckin);
    {
      map['notification_mode'] = Variable<int>(
        $SettingsTable.$converternotificationMode.toSql(notificationMode),
      );
    }
    map['onboarding_completed'] = Variable<bool>(onboardingCompleted);
    map['notification_permission_asked'] = Variable<bool>(
      notificationPermissionAsked,
    );
    map['notification_banner_dismissals'] = Variable<int>(
      notificationBannerDismissals,
    );
    if (!nullToAbsent || lastBannerDismissedAt != null) {
      map['last_banner_dismissed_at'] = Variable<DateTime>(
        lastBannerDismissedAt,
      );
    }
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      bedtime: Value(bedtime),
      morningCheckin: Value(morningCheckin),
      notificationMode: Value(notificationMode),
      onboardingCompleted: Value(onboardingCompleted),
      notificationPermissionAsked: Value(notificationPermissionAsked),
      notificationBannerDismissals: Value(notificationBannerDismissals),
      lastBannerDismissedAt: lastBannerDismissedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastBannerDismissedAt),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      id: serializer.fromJson<int>(json['id']),
      bedtime: serializer.fromJson<DateTime>(json['bedtime']),
      morningCheckin: serializer.fromJson<DateTime>(json['morningCheckin']),
      notificationMode: $SettingsTable.$converternotificationMode.fromJson(
        serializer.fromJson<int>(json['notificationMode']),
      ),
      onboardingCompleted: serializer.fromJson<bool>(
        json['onboardingCompleted'],
      ),
      notificationPermissionAsked: serializer.fromJson<bool>(
        json['notificationPermissionAsked'],
      ),
      notificationBannerDismissals: serializer.fromJson<int>(
        json['notificationBannerDismissals'],
      ),
      lastBannerDismissedAt: serializer.fromJson<DateTime?>(
        json['lastBannerDismissedAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bedtime': serializer.toJson<DateTime>(bedtime),
      'morningCheckin': serializer.toJson<DateTime>(morningCheckin),
      'notificationMode': serializer.toJson<int>(
        $SettingsTable.$converternotificationMode.toJson(notificationMode),
      ),
      'onboardingCompleted': serializer.toJson<bool>(onboardingCompleted),
      'notificationPermissionAsked': serializer.toJson<bool>(
        notificationPermissionAsked,
      ),
      'notificationBannerDismissals': serializer.toJson<int>(
        notificationBannerDismissals,
      ),
      'lastBannerDismissedAt': serializer.toJson<DateTime?>(
        lastBannerDismissedAt,
      ),
    };
  }

  Setting copyWith({
    int? id,
    DateTime? bedtime,
    DateTime? morningCheckin,
    NotificationMode? notificationMode,
    bool? onboardingCompleted,
    bool? notificationPermissionAsked,
    int? notificationBannerDismissals,
    Value<DateTime?> lastBannerDismissedAt = const Value.absent(),
  }) => Setting(
    id: id ?? this.id,
    bedtime: bedtime ?? this.bedtime,
    morningCheckin: morningCheckin ?? this.morningCheckin,
    notificationMode: notificationMode ?? this.notificationMode,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    notificationPermissionAsked:
        notificationPermissionAsked ?? this.notificationPermissionAsked,
    notificationBannerDismissals:
        notificationBannerDismissals ?? this.notificationBannerDismissals,
    lastBannerDismissedAt: lastBannerDismissedAt.present
        ? lastBannerDismissedAt.value
        : this.lastBannerDismissedAt,
  );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      id: data.id.present ? data.id.value : this.id,
      bedtime: data.bedtime.present ? data.bedtime.value : this.bedtime,
      morningCheckin: data.morningCheckin.present
          ? data.morningCheckin.value
          : this.morningCheckin,
      notificationMode: data.notificationMode.present
          ? data.notificationMode.value
          : this.notificationMode,
      onboardingCompleted: data.onboardingCompleted.present
          ? data.onboardingCompleted.value
          : this.onboardingCompleted,
      notificationPermissionAsked: data.notificationPermissionAsked.present
          ? data.notificationPermissionAsked.value
          : this.notificationPermissionAsked,
      notificationBannerDismissals: data.notificationBannerDismissals.present
          ? data.notificationBannerDismissals.value
          : this.notificationBannerDismissals,
      lastBannerDismissedAt: data.lastBannerDismissedAt.present
          ? data.lastBannerDismissedAt.value
          : this.lastBannerDismissedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('id: $id, ')
          ..write('bedtime: $bedtime, ')
          ..write('morningCheckin: $morningCheckin, ')
          ..write('notificationMode: $notificationMode, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('notificationPermissionAsked: $notificationPermissionAsked, ')
          ..write(
            'notificationBannerDismissals: $notificationBannerDismissals, ',
          )
          ..write('lastBannerDismissedAt: $lastBannerDismissedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bedtime,
    morningCheckin,
    notificationMode,
    onboardingCompleted,
    notificationPermissionAsked,
    notificationBannerDismissals,
    lastBannerDismissedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.id == this.id &&
          other.bedtime == this.bedtime &&
          other.morningCheckin == this.morningCheckin &&
          other.notificationMode == this.notificationMode &&
          other.onboardingCompleted == this.onboardingCompleted &&
          other.notificationPermissionAsked ==
              this.notificationPermissionAsked &&
          other.notificationBannerDismissals ==
              this.notificationBannerDismissals &&
          other.lastBannerDismissedAt == this.lastBannerDismissedAt);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<int> id;
  final Value<DateTime> bedtime;
  final Value<DateTime> morningCheckin;
  final Value<NotificationMode> notificationMode;
  final Value<bool> onboardingCompleted;
  final Value<bool> notificationPermissionAsked;
  final Value<int> notificationBannerDismissals;
  final Value<DateTime?> lastBannerDismissedAt;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.bedtime = const Value.absent(),
    this.morningCheckin = const Value.absent(),
    this.notificationMode = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.notificationPermissionAsked = const Value.absent(),
    this.notificationBannerDismissals = const Value.absent(),
    this.lastBannerDismissedAt = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime bedtime,
    required DateTime morningCheckin,
    required NotificationMode notificationMode,
    this.onboardingCompleted = const Value.absent(),
    this.notificationPermissionAsked = const Value.absent(),
    this.notificationBannerDismissals = const Value.absent(),
    this.lastBannerDismissedAt = const Value.absent(),
  }) : bedtime = Value(bedtime),
       morningCheckin = Value(morningCheckin),
       notificationMode = Value(notificationMode);
  static Insertable<Setting> custom({
    Expression<int>? id,
    Expression<DateTime>? bedtime,
    Expression<DateTime>? morningCheckin,
    Expression<int>? notificationMode,
    Expression<bool>? onboardingCompleted,
    Expression<bool>? notificationPermissionAsked,
    Expression<int>? notificationBannerDismissals,
    Expression<DateTime>? lastBannerDismissedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bedtime != null) 'bedtime': bedtime,
      if (morningCheckin != null) 'morning_checkin': morningCheckin,
      if (notificationMode != null) 'notification_mode': notificationMode,
      if (onboardingCompleted != null)
        'onboarding_completed': onboardingCompleted,
      if (notificationPermissionAsked != null)
        'notification_permission_asked': notificationPermissionAsked,
      if (notificationBannerDismissals != null)
        'notification_banner_dismissals': notificationBannerDismissals,
      if (lastBannerDismissedAt != null)
        'last_banner_dismissed_at': lastBannerDismissedAt,
    });
  }

  SettingsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? bedtime,
    Value<DateTime>? morningCheckin,
    Value<NotificationMode>? notificationMode,
    Value<bool>? onboardingCompleted,
    Value<bool>? notificationPermissionAsked,
    Value<int>? notificationBannerDismissals,
    Value<DateTime?>? lastBannerDismissedAt,
  }) {
    return SettingsCompanion(
      id: id ?? this.id,
      bedtime: bedtime ?? this.bedtime,
      morningCheckin: morningCheckin ?? this.morningCheckin,
      notificationMode: notificationMode ?? this.notificationMode,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      notificationPermissionAsked:
          notificationPermissionAsked ?? this.notificationPermissionAsked,
      notificationBannerDismissals:
          notificationBannerDismissals ?? this.notificationBannerDismissals,
      lastBannerDismissedAt:
          lastBannerDismissedAt ?? this.lastBannerDismissedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bedtime.present) {
      map['bedtime'] = Variable<DateTime>(bedtime.value);
    }
    if (morningCheckin.present) {
      map['morning_checkin'] = Variable<DateTime>(morningCheckin.value);
    }
    if (notificationMode.present) {
      map['notification_mode'] = Variable<int>(
        $SettingsTable.$converternotificationMode.toSql(notificationMode.value),
      );
    }
    if (onboardingCompleted.present) {
      map['onboarding_completed'] = Variable<bool>(onboardingCompleted.value);
    }
    if (notificationPermissionAsked.present) {
      map['notification_permission_asked'] = Variable<bool>(
        notificationPermissionAsked.value,
      );
    }
    if (notificationBannerDismissals.present) {
      map['notification_banner_dismissals'] = Variable<int>(
        notificationBannerDismissals.value,
      );
    }
    if (lastBannerDismissedAt.present) {
      map['last_banner_dismissed_at'] = Variable<DateTime>(
        lastBannerDismissedAt.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('bedtime: $bedtime, ')
          ..write('morningCheckin: $morningCheckin, ')
          ..write('notificationMode: $notificationMode, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('notificationPermissionAsked: $notificationPermissionAsked, ')
          ..write(
            'notificationBannerDismissals: $notificationBannerDismissals, ',
          )
          ..write('lastBannerDismissedAt: $lastBannerDismissedAt')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    action,
    payload,
    createdAt,
    synced,
    retryCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String entityType;
  final String entityId;
  final String action;
  final String payload;
  final DateTime createdAt;
  final bool synced;
  final int retryCount;
  const SyncQueueData({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.action,
    required this.payload,
    required this.createdAt,
    required this.synced,
    required this.retryCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['action'] = Variable<String>(action);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    map['retry_count'] = Variable<int>(retryCount);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      action: Value(action),
      payload: Value(payload),
      createdAt: Value(createdAt),
      synced: Value(synced),
      retryCount: Value(retryCount),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      action: serializer.fromJson<String>(json['action']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'action': serializer.toJson<String>(action),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
      'retryCount': serializer.toJson<int>(retryCount),
    };
  }

  SyncQueueData copyWith({
    int? id,
    String? entityType,
    String? entityId,
    String? action,
    String? payload,
    DateTime? createdAt,
    bool? synced,
    int? retryCount,
  }) => SyncQueueData(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    action: action ?? this.action,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    synced: synced ?? this.synced,
    retryCount: retryCount ?? this.retryCount,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      action: data.action.present ? data.action.value : this.action,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    action,
    payload,
    createdAt,
    synced,
    retryCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.action == this.action &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced &&
          other.retryCount == this.retryCount);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> action;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  final Value<int> retryCount;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.action = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.retryCount = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String entityId,
    required String action,
    required String payload,
    required DateTime createdAt,
    this.synced = const Value.absent(),
    this.retryCount = const Value.absent(),
  }) : entityType = Value(entityType),
       entityId = Value(entityId),
       action = Value(action),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? action,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
    Expression<int>? retryCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (action != null) 'action': action,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
      if (retryCount != null) 'retry_count': retryCount,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? action,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<bool>? synced,
    Value<int>? retryCount,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $DailyInstancesTable dailyInstances = $DailyInstancesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final Index idxTasksTypeStatus = Index(
    'idx_tasks_type_status',
    'CREATE INDEX idx_tasks_type_status ON tasks (type, status)',
  );
  late final Index idxTasksDate = Index(
    'idx_tasks_date',
    'CREATE INDEX idx_tasks_date ON tasks (date)',
  );
  late final Index idxTasksIsDeleted = Index(
    'idx_tasks_is_deleted',
    'CREATE INDEX idx_tasks_is_deleted ON tasks (is_deleted)',
  );
  late final Index idxTasksPriority = Index(
    'idx_tasks_priority',
    'CREATE INDEX idx_tasks_priority ON tasks (priority)',
  );
  late final Index idxDailyTaskDate = Index(
    'idx_daily_task_date',
    'CREATE UNIQUE INDEX idx_daily_task_date ON daily_instances (task_id, date)',
  );
  late final Index idxDailyDate = Index(
    'idx_daily_date',
    'CREATE INDEX idx_daily_date ON daily_instances (date)',
  );
  late final Index idxSyncUnsynced = Index(
    'idx_sync_unsynced',
    'CREATE INDEX idx_sync_unsynced ON sync_queue (synced, created_at)',
  );
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  late final TaskDao taskDao = TaskDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tasks,
    dailyInstances,
    settings,
    syncQueue,
    idxTasksTypeStatus,
    idxTasksDate,
    idxTasksIsDeleted,
    idxTasksPriority,
    idxDailyTaskDate,
    idxDailyDate,
    idxSyncUnsynced,
  ];
}

typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      required String id,
      required String title,
      Value<String?> notes,
      required TaskType type,
      Value<DateTime?> date,
      required TaskStatus status,
      required DateTime createdAt,
      Value<DateTime?> resolvedAt,
      Value<DateTime?> snoozeUntil,
      Value<int> sortOrder,
      Value<Priority> priority,
      Value<String> labels,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> notes,
      Value<TaskType> type,
      Value<DateTime?> date,
      Value<TaskStatus> status,
      Value<DateTime> createdAt,
      Value<DateTime?> resolvedAt,
      Value<DateTime?> snoozeUntil,
      Value<int> sortOrder,
      Value<Priority> priority,
      Value<String> labels,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DailyInstancesTable, List<DailyInstance>>
  _dailyInstancesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dailyInstances,
    aliasName: $_aliasNameGenerator(db.tasks.id, db.dailyInstances.taskId),
  );

  $$DailyInstancesTableProcessedTableManager get dailyInstancesRefs {
    final manager = $$DailyInstancesTableTableManager(
      $_db,
      $_db.dailyInstances,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_dailyInstancesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TaskType, TaskType, int> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TaskStatus, TaskStatus, int> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get snoozeUntil => $composableBuilder(
    column: $table.snoozeUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Priority, Priority, int> get priority =>
      $composableBuilder(
        column: $table.priority,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get labels => $composableBuilder(
    column: $table.labels,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> dailyInstancesRefs(
    Expression<bool> Function($$DailyInstancesTableFilterComposer f) f,
  ) {
    final $$DailyInstancesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyInstances,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyInstancesTableFilterComposer(
            $db: $db,
            $table: $db.dailyInstances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get snoozeUntil => $composableBuilder(
    column: $table.snoozeUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get labels => $composableBuilder(
    column: $table.labels,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TaskType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TaskStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get snoozeUntil => $composableBuilder(
    column: $table.snoozeUntil,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Priority, int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get labels =>
      $composableBuilder(column: $table.labels, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  Expression<T> dailyInstancesRefs<T extends Object>(
    Expression<T> Function($$DailyInstancesTableAnnotationComposer a) f,
  ) {
    final $$DailyInstancesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyInstances,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyInstancesTableAnnotationComposer(
            $db: $db,
            $table: $db.dailyInstances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, $$TasksTableReferences),
          Task,
          PrefetchHooks Function({bool dailyInstancesRefs})
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<TaskType> type = const Value.absent(),
                Value<DateTime?> date = const Value.absent(),
                Value<TaskStatus> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<DateTime?> snoozeUntil = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<Priority> priority = const Value.absent(),
                Value<String> labels = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                title: title,
                notes: notes,
                type: type,
                date: date,
                status: status,
                createdAt: createdAt,
                resolvedAt: resolvedAt,
                snoozeUntil: snoozeUntil,
                sortOrder: sortOrder,
                priority: priority,
                labels: labels,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> notes = const Value.absent(),
                required TaskType type,
                Value<DateTime?> date = const Value.absent(),
                required TaskStatus status,
                required DateTime createdAt,
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<DateTime?> snoozeUntil = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<Priority> priority = const Value.absent(),
                Value<String> labels = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                title: title,
                notes: notes,
                type: type,
                date: date,
                status: status,
                createdAt: createdAt,
                resolvedAt: resolvedAt,
                snoozeUntil: snoozeUntil,
                sortOrder: sortOrder,
                priority: priority,
                labels: labels,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TasksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({dailyInstancesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (dailyInstancesRefs) db.dailyInstances,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dailyInstancesRefs)
                    await $_getPrefetchedData<Task, $TasksTable, DailyInstance>(
                      currentTable: table,
                      referencedTable: $$TasksTableReferences
                          ._dailyInstancesRefsTable(db),
                      managerFromTypedResult: (p0) => $$TasksTableReferences(
                        db,
                        table,
                        p0,
                      ).dailyInstancesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.taskId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, $$TasksTableReferences),
      Task,
      PrefetchHooks Function({bool dailyInstancesRefs})
    >;
typedef $$DailyInstancesTableCreateCompanionBuilder =
    DailyInstancesCompanion Function({
      required String id,
      required String taskId,
      required DateTime date,
      required TaskStatus status,
      Value<DateTime?> resolvedAt,
      Value<DateTime?> snoozeUntil,
      Value<bool> skipped,
      Value<Priority?> priority,
      Value<String?> labels,
      Value<int> rowid,
    });
typedef $$DailyInstancesTableUpdateCompanionBuilder =
    DailyInstancesCompanion Function({
      Value<String> id,
      Value<String> taskId,
      Value<DateTime> date,
      Value<TaskStatus> status,
      Value<DateTime?> resolvedAt,
      Value<DateTime?> snoozeUntil,
      Value<bool> skipped,
      Value<Priority?> priority,
      Value<String?> labels,
      Value<int> rowid,
    });

final class $$DailyInstancesTableReferences
    extends BaseReferences<_$AppDatabase, $DailyInstancesTable, DailyInstance> {
  $$DailyInstancesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TasksTable _taskIdTable(_$AppDatabase db) => db.tasks.createAlias(
    $_aliasNameGenerator(db.dailyInstances.taskId, db.tasks.id),
  );

  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<String>('task_id')!;

    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DailyInstancesTableFilterComposer
    extends Composer<_$AppDatabase, $DailyInstancesTable> {
  $$DailyInstancesTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TaskStatus, TaskStatus, int> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get snoozeUntil => $composableBuilder(
    column: $table.snoozeUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get skipped => $composableBuilder(
    column: $table.skipped,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Priority?, Priority, int> get priority =>
      $composableBuilder(
        column: $table.priority,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get labels => $composableBuilder(
    column: $table.labels,
    builder: (column) => ColumnFilters(column),
  );

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyInstancesTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyInstancesTable> {
  $$DailyInstancesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get snoozeUntil => $composableBuilder(
    column: $table.snoozeUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get skipped => $composableBuilder(
    column: $table.skipped,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get labels => $composableBuilder(
    column: $table.labels,
    builder: (column) => ColumnOrderings(column),
  );

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyInstancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyInstancesTable> {
  $$DailyInstancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TaskStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get snoozeUntil => $composableBuilder(
    column: $table.snoozeUntil,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get skipped =>
      $composableBuilder(column: $table.skipped, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Priority?, int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get labels =>
      $composableBuilder(column: $table.labels, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyInstancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyInstancesTable,
          DailyInstance,
          $$DailyInstancesTableFilterComposer,
          $$DailyInstancesTableOrderingComposer,
          $$DailyInstancesTableAnnotationComposer,
          $$DailyInstancesTableCreateCompanionBuilder,
          $$DailyInstancesTableUpdateCompanionBuilder,
          (DailyInstance, $$DailyInstancesTableReferences),
          DailyInstance,
          PrefetchHooks Function({bool taskId})
        > {
  $$DailyInstancesTableTableManager(
    _$AppDatabase db,
    $DailyInstancesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyInstancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyInstancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyInstancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<TaskStatus> status = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<DateTime?> snoozeUntil = const Value.absent(),
                Value<bool> skipped = const Value.absent(),
                Value<Priority?> priority = const Value.absent(),
                Value<String?> labels = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyInstancesCompanion(
                id: id,
                taskId: taskId,
                date: date,
                status: status,
                resolvedAt: resolvedAt,
                snoozeUntil: snoozeUntil,
                skipped: skipped,
                priority: priority,
                labels: labels,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String taskId,
                required DateTime date,
                required TaskStatus status,
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<DateTime?> snoozeUntil = const Value.absent(),
                Value<bool> skipped = const Value.absent(),
                Value<Priority?> priority = const Value.absent(),
                Value<String?> labels = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyInstancesCompanion.insert(
                id: id,
                taskId: taskId,
                date: date,
                status: status,
                resolvedAt: resolvedAt,
                snoozeUntil: snoozeUntil,
                skipped: skipped,
                priority: priority,
                labels: labels,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DailyInstancesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (taskId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.taskId,
                                referencedTable: $$DailyInstancesTableReferences
                                    ._taskIdTable(db),
                                referencedColumn:
                                    $$DailyInstancesTableReferences
                                        ._taskIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DailyInstancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyInstancesTable,
      DailyInstance,
      $$DailyInstancesTableFilterComposer,
      $$DailyInstancesTableOrderingComposer,
      $$DailyInstancesTableAnnotationComposer,
      $$DailyInstancesTableCreateCompanionBuilder,
      $$DailyInstancesTableUpdateCompanionBuilder,
      (DailyInstance, $$DailyInstancesTableReferences),
      DailyInstance,
      PrefetchHooks Function({bool taskId})
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      Value<int> id,
      required DateTime bedtime,
      required DateTime morningCheckin,
      required NotificationMode notificationMode,
      Value<bool> onboardingCompleted,
      Value<bool> notificationPermissionAsked,
      Value<int> notificationBannerDismissals,
      Value<DateTime?> lastBannerDismissedAt,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<int> id,
      Value<DateTime> bedtime,
      Value<DateTime> morningCheckin,
      Value<NotificationMode> notificationMode,
      Value<bool> onboardingCompleted,
      Value<bool> notificationPermissionAsked,
      Value<int> notificationBannerDismissals,
      Value<DateTime?> lastBannerDismissedAt,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
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

  ColumnFilters<DateTime> get bedtime => $composableBuilder(
    column: $table.bedtime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get morningCheckin => $composableBuilder(
    column: $table.morningCheckin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<NotificationMode, NotificationMode, int>
  get notificationMode => $composableBuilder(
    column: $table.notificationMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationPermissionAsked => $composableBuilder(
    column: $table.notificationPermissionAsked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notificationBannerDismissals => $composableBuilder(
    column: $table.notificationBannerDismissals,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastBannerDismissedAt => $composableBuilder(
    column: $table.lastBannerDismissedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get bedtime => $composableBuilder(
    column: $table.bedtime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get morningCheckin => $composableBuilder(
    column: $table.morningCheckin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notificationMode => $composableBuilder(
    column: $table.notificationMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationPermissionAsked => $composableBuilder(
    column: $table.notificationPermissionAsked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notificationBannerDismissals => $composableBuilder(
    column: $table.notificationBannerDismissals,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastBannerDismissedAt => $composableBuilder(
    column: $table.lastBannerDismissedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get bedtime =>
      $composableBuilder(column: $table.bedtime, builder: (column) => column);

  GeneratedColumn<DateTime> get morningCheckin => $composableBuilder(
    column: $table.morningCheckin,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<NotificationMode, int>
  get notificationMode => $composableBuilder(
    column: $table.notificationMode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notificationPermissionAsked => $composableBuilder(
    column: $table.notificationPermissionAsked,
    builder: (column) => column,
  );

  GeneratedColumn<int> get notificationBannerDismissals => $composableBuilder(
    column: $table.notificationBannerDismissals,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastBannerDismissedAt => $composableBuilder(
    column: $table.lastBannerDismissedAt,
    builder: (column) => column,
  );
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> bedtime = const Value.absent(),
                Value<DateTime> morningCheckin = const Value.absent(),
                Value<NotificationMode> notificationMode = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<bool> notificationPermissionAsked = const Value.absent(),
                Value<int> notificationBannerDismissals = const Value.absent(),
                Value<DateTime?> lastBannerDismissedAt = const Value.absent(),
              }) => SettingsCompanion(
                id: id,
                bedtime: bedtime,
                morningCheckin: morningCheckin,
                notificationMode: notificationMode,
                onboardingCompleted: onboardingCompleted,
                notificationPermissionAsked: notificationPermissionAsked,
                notificationBannerDismissals: notificationBannerDismissals,
                lastBannerDismissedAt: lastBannerDismissedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime bedtime,
                required DateTime morningCheckin,
                required NotificationMode notificationMode,
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<bool> notificationPermissionAsked = const Value.absent(),
                Value<int> notificationBannerDismissals = const Value.absent(),
                Value<DateTime?> lastBannerDismissedAt = const Value.absent(),
              }) => SettingsCompanion.insert(
                id: id,
                bedtime: bedtime,
                morningCheckin: morningCheckin,
                notificationMode: notificationMode,
                onboardingCompleted: onboardingCompleted,
                notificationPermissionAsked: notificationPermissionAsked,
                notificationBannerDismissals: notificationBannerDismissals,
                lastBannerDismissedAt: lastBannerDismissedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      required String entityType,
      required String entityId,
      required String action,
      required String payload,
      required DateTime createdAt,
      Value<bool> synced,
      Value<int> retryCount,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> action,
      Value<String> payload,
      Value<DateTime> createdAt,
      Value<bool> synced,
      Value<int> retryCount,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
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

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
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

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueData,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                action: action,
                payload: payload,
                createdAt: createdAt,
                synced: synced,
                retryCount: retryCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityType,
                required String entityId,
                required String action,
                required String payload,
                required DateTime createdAt,
                Value<bool> synced = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                action: action,
                payload: payload,
                createdAt: createdAt,
                synced: synced,
                retryCount: retryCount,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueData,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueData,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
      ),
      SyncQueueData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$DailyInstancesTableTableManager get dailyInstances =>
      $$DailyInstancesTableTableManager(_db, _db.dailyInstances);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
