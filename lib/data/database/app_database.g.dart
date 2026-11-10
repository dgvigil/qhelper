// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PlansTable extends Plans with TableInfo<$PlansTable, Plan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlansTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetDurationSecondsMeta =
      const VerificationMeta('targetDurationSeconds');
  @override
  late final GeneratedColumn<int> targetDurationSeconds = GeneratedColumn<int>(
    'target_duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    targetDurationSeconds,
    createdAt,
    updatedAt,
    schemaVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<Plan> instance, {
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
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('target_duration_seconds')) {
      context.handle(
        _targetDurationSecondsMeta,
        targetDurationSeconds.isAcceptableOrUnknown(
          data['target_duration_seconds']!,
          _targetDurationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetDurationSecondsMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Plan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Plan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      targetDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_duration_seconds'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
    );
  }

  @override
  $PlansTable createAlias(String alias) {
    return $PlansTable(attachedDatabase, alias);
  }
}

class Plan extends DataClass implements Insertable<Plan> {
  final String id;
  final String title;
  final String? description;
  final int targetDurationSeconds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int schemaVersion;
  const Plan({
    required this.id,
    required this.title,
    this.description,
    required this.targetDurationSeconds,
    required this.createdAt,
    required this.updatedAt,
    required this.schemaVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['target_duration_seconds'] = Variable<int>(targetDurationSeconds);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['schema_version'] = Variable<int>(schemaVersion);
    return map;
  }

  PlansCompanion toCompanion(bool nullToAbsent) {
    return PlansCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      targetDurationSeconds: Value(targetDurationSeconds),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      schemaVersion: Value(schemaVersion),
    );
  }

  factory Plan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Plan(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      targetDurationSeconds: serializer.fromJson<int>(
        json['targetDurationSeconds'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'targetDurationSeconds': serializer.toJson<int>(targetDurationSeconds),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
    };
  }

  Plan copyWith({
    String? id,
    String? title,
    Value<String?> description = const Value.absent(),
    int? targetDurationSeconds,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? schemaVersion,
  }) => Plan(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    targetDurationSeconds: targetDurationSeconds ?? this.targetDurationSeconds,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    schemaVersion: schemaVersion ?? this.schemaVersion,
  );
  Plan copyWithCompanion(PlansCompanion data) {
    return Plan(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      targetDurationSeconds: data.targetDurationSeconds.present
          ? data.targetDurationSeconds.value
          : this.targetDurationSeconds,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Plan(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('targetDurationSeconds: $targetDurationSeconds, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('schemaVersion: $schemaVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    targetDurationSeconds,
    createdAt,
    updatedAt,
    schemaVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Plan &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.targetDurationSeconds == this.targetDurationSeconds &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.schemaVersion == this.schemaVersion);
}

class PlansCompanion extends UpdateCompanion<Plan> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<int> targetDurationSeconds;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> schemaVersion;
  final Value<int> rowid;
  const PlansCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.targetDurationSeconds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlansCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    required int targetDurationSeconds,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int schemaVersion,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       targetDurationSeconds = Value(targetDurationSeconds),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       schemaVersion = Value(schemaVersion);
  static Insertable<Plan> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? targetDurationSeconds,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? schemaVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (targetDurationSeconds != null)
        'target_duration_seconds': targetDurationSeconds,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlansCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<int>? targetDurationSeconds,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? schemaVersion,
    Value<int>? rowid,
  }) {
    return PlansCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetDurationSeconds:
          targetDurationSeconds ?? this.targetDurationSeconds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      schemaVersion: schemaVersion ?? this.schemaVersion,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (targetDurationSeconds.present) {
      map['target_duration_seconds'] = Variable<int>(
        targetDurationSeconds.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlansCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('targetDurationSeconds: $targetDurationSeconds, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SegmentsTable extends Segments with TableInfo<$SegmentsTable, Segment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SegmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plans (id) ON DELETE CASCADE',
    ),
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
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estimatedDurationSecondsMeta =
      const VerificationMeta('estimatedDurationSeconds');
  @override
  late final GeneratedColumn<int> estimatedDurationSeconds =
      GeneratedColumn<int>(
        'estimated_duration_seconds',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    planId,
    title,
    sortOrder,
    estimatedDurationSeconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'segments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Segment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('estimated_duration_seconds')) {
      context.handle(
        _estimatedDurationSecondsMeta,
        estimatedDurationSeconds.isAcceptableOrUnknown(
          data['estimated_duration_seconds']!,
          _estimatedDurationSecondsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Segment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Segment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      estimatedDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_duration_seconds'],
      ),
    );
  }

  @override
  $SegmentsTable createAlias(String alias) {
    return $SegmentsTable(attachedDatabase, alias);
  }
}

class Segment extends DataClass implements Insertable<Segment> {
  final String id;
  final String planId;
  final String title;
  final int sortOrder;
  final int? estimatedDurationSeconds;
  const Segment({
    required this.id,
    required this.planId,
    required this.title,
    required this.sortOrder,
    this.estimatedDurationSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plan_id'] = Variable<String>(planId);
    map['title'] = Variable<String>(title);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || estimatedDurationSeconds != null) {
      map['estimated_duration_seconds'] = Variable<int>(
        estimatedDurationSeconds,
      );
    }
    return map;
  }

  SegmentsCompanion toCompanion(bool nullToAbsent) {
    return SegmentsCompanion(
      id: Value(id),
      planId: Value(planId),
      title: Value(title),
      sortOrder: Value(sortOrder),
      estimatedDurationSeconds: estimatedDurationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedDurationSeconds),
    );
  }

  factory Segment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Segment(
      id: serializer.fromJson<String>(json['id']),
      planId: serializer.fromJson<String>(json['planId']),
      title: serializer.fromJson<String>(json['title']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      estimatedDurationSeconds: serializer.fromJson<int?>(
        json['estimatedDurationSeconds'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'planId': serializer.toJson<String>(planId),
      'title': serializer.toJson<String>(title),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'estimatedDurationSeconds': serializer.toJson<int?>(
        estimatedDurationSeconds,
      ),
    };
  }

  Segment copyWith({
    String? id,
    String? planId,
    String? title,
    int? sortOrder,
    Value<int?> estimatedDurationSeconds = const Value.absent(),
  }) => Segment(
    id: id ?? this.id,
    planId: planId ?? this.planId,
    title: title ?? this.title,
    sortOrder: sortOrder ?? this.sortOrder,
    estimatedDurationSeconds: estimatedDurationSeconds.present
        ? estimatedDurationSeconds.value
        : this.estimatedDurationSeconds,
  );
  Segment copyWithCompanion(SegmentsCompanion data) {
    return Segment(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      title: data.title.present ? data.title.value : this.title,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      estimatedDurationSeconds: data.estimatedDurationSeconds.present
          ? data.estimatedDurationSeconds.value
          : this.estimatedDurationSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Segment(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('title: $title, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('estimatedDurationSeconds: $estimatedDurationSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, planId, title, sortOrder, estimatedDurationSeconds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Segment &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.title == this.title &&
          other.sortOrder == this.sortOrder &&
          other.estimatedDurationSeconds == this.estimatedDurationSeconds);
}

class SegmentsCompanion extends UpdateCompanion<Segment> {
  final Value<String> id;
  final Value<String> planId;
  final Value<String> title;
  final Value<int> sortOrder;
  final Value<int?> estimatedDurationSeconds;
  final Value<int> rowid;
  const SegmentsCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.title = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.estimatedDurationSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SegmentsCompanion.insert({
    required String id,
    required String planId,
    required String title,
    required int sortOrder,
    this.estimatedDurationSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       planId = Value(planId),
       title = Value(title),
       sortOrder = Value(sortOrder);
  static Insertable<Segment> custom({
    Expression<String>? id,
    Expression<String>? planId,
    Expression<String>? title,
    Expression<int>? sortOrder,
    Expression<int>? estimatedDurationSeconds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (title != null) 'title': title,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (estimatedDurationSeconds != null)
        'estimated_duration_seconds': estimatedDurationSeconds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SegmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? planId,
    Value<String>? title,
    Value<int>? sortOrder,
    Value<int?>? estimatedDurationSeconds,
    Value<int>? rowid,
  }) {
    return SegmentsCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      title: title ?? this.title,
      sortOrder: sortOrder ?? this.sortOrder,
      estimatedDurationSeconds:
          estimatedDurationSeconds ?? this.estimatedDurationSeconds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (estimatedDurationSeconds.present) {
      map['estimated_duration_seconds'] = Variable<int>(
        estimatedDurationSeconds.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SegmentsCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('title: $title, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('estimatedDurationSeconds: $estimatedDurationSeconds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivitiesTable extends Activities
    with TableInfo<$ActivitiesTable, Activity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _segmentIdMeta = const VerificationMeta(
    'segmentId',
  );
  @override
  late final GeneratedColumn<String> segmentId = GeneratedColumn<String>(
    'segment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES segments (id) ON DELETE CASCADE',
    ),
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _repetitionsMeta = const VerificationMeta(
    'repetitions',
  );
  @override
  late final GeneratedColumn<int> repetitions = GeneratedColumn<int>(
    'repetitions',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workSecondsMeta = const VerificationMeta(
    'workSeconds',
  );
  @override
  late final GeneratedColumn<int> workSeconds = GeneratedColumn<int>(
    'work_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restSecondsMeta = const VerificationMeta(
    'restSeconds',
  );
  @override
  late final GeneratedColumn<int> restSeconds = GeneratedColumn<int>(
    'rest_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roundsMeta = const VerificationMeta('rounds');
  @override
  late final GeneratedColumn<int> rounds = GeneratedColumn<int>(
    'rounds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _instructionsMeta = const VerificationMeta(
    'instructions',
  );
  @override
  late final GeneratedColumn<String> instructions = GeneratedColumn<String>(
    'instructions',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    segmentId,
    sortOrder,
    kind,
    name,
    notes,
    repetitions,
    workSeconds,
    restSeconds,
    rounds,
    instructions,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<Activity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('segment_id')) {
      context.handle(
        _segmentIdMeta,
        segmentId.isAcceptableOrUnknown(data['segment_id']!, _segmentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_segmentIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('repetitions')) {
      context.handle(
        _repetitionsMeta,
        repetitions.isAcceptableOrUnknown(
          data['repetitions']!,
          _repetitionsMeta,
        ),
      );
    }
    if (data.containsKey('work_seconds')) {
      context.handle(
        _workSecondsMeta,
        workSeconds.isAcceptableOrUnknown(
          data['work_seconds']!,
          _workSecondsMeta,
        ),
      );
    }
    if (data.containsKey('rest_seconds')) {
      context.handle(
        _restSecondsMeta,
        restSeconds.isAcceptableOrUnknown(
          data['rest_seconds']!,
          _restSecondsMeta,
        ),
      );
    }
    if (data.containsKey('rounds')) {
      context.handle(
        _roundsMeta,
        rounds.isAcceptableOrUnknown(data['rounds']!, _roundsMeta),
      );
    }
    if (data.containsKey('instructions')) {
      context.handle(
        _instructionsMeta,
        instructions.isAcceptableOrUnknown(
          data['instructions']!,
          _instructionsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Activity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Activity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      segmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}segment_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      repetitions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repetitions'],
      ),
      workSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}work_seconds'],
      ),
      restSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_seconds'],
      ),
      rounds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rounds'],
      ),
      instructions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instructions'],
      ),
    );
  }

  @override
  $ActivitiesTable createAlias(String alias) {
    return $ActivitiesTable(attachedDatabase, alias);
  }
}

class Activity extends DataClass implements Insertable<Activity> {
  final String id;
  final String segmentId;
  final int sortOrder;
  final String kind;
  final String name;
  final String? notes;
  final int? repetitions;
  final int? workSeconds;
  final int? restSeconds;
  final int? rounds;
  final String? instructions;
  const Activity({
    required this.id,
    required this.segmentId,
    required this.sortOrder,
    required this.kind,
    required this.name,
    this.notes,
    this.repetitions,
    this.workSeconds,
    this.restSeconds,
    this.rounds,
    this.instructions,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['segment_id'] = Variable<String>(segmentId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['kind'] = Variable<String>(kind);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || repetitions != null) {
      map['repetitions'] = Variable<int>(repetitions);
    }
    if (!nullToAbsent || workSeconds != null) {
      map['work_seconds'] = Variable<int>(workSeconds);
    }
    if (!nullToAbsent || restSeconds != null) {
      map['rest_seconds'] = Variable<int>(restSeconds);
    }
    if (!nullToAbsent || rounds != null) {
      map['rounds'] = Variable<int>(rounds);
    }
    if (!nullToAbsent || instructions != null) {
      map['instructions'] = Variable<String>(instructions);
    }
    return map;
  }

  ActivitiesCompanion toCompanion(bool nullToAbsent) {
    return ActivitiesCompanion(
      id: Value(id),
      segmentId: Value(segmentId),
      sortOrder: Value(sortOrder),
      kind: Value(kind),
      name: Value(name),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      repetitions: repetitions == null && nullToAbsent
          ? const Value.absent()
          : Value(repetitions),
      workSeconds: workSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(workSeconds),
      restSeconds: restSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(restSeconds),
      rounds: rounds == null && nullToAbsent
          ? const Value.absent()
          : Value(rounds),
      instructions: instructions == null && nullToAbsent
          ? const Value.absent()
          : Value(instructions),
    );
  }

  factory Activity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Activity(
      id: serializer.fromJson<String>(json['id']),
      segmentId: serializer.fromJson<String>(json['segmentId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      kind: serializer.fromJson<String>(json['kind']),
      name: serializer.fromJson<String>(json['name']),
      notes: serializer.fromJson<String?>(json['notes']),
      repetitions: serializer.fromJson<int?>(json['repetitions']),
      workSeconds: serializer.fromJson<int?>(json['workSeconds']),
      restSeconds: serializer.fromJson<int?>(json['restSeconds']),
      rounds: serializer.fromJson<int?>(json['rounds']),
      instructions: serializer.fromJson<String?>(json['instructions']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'segmentId': serializer.toJson<String>(segmentId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'kind': serializer.toJson<String>(kind),
      'name': serializer.toJson<String>(name),
      'notes': serializer.toJson<String?>(notes),
      'repetitions': serializer.toJson<int?>(repetitions),
      'workSeconds': serializer.toJson<int?>(workSeconds),
      'restSeconds': serializer.toJson<int?>(restSeconds),
      'rounds': serializer.toJson<int?>(rounds),
      'instructions': serializer.toJson<String?>(instructions),
    };
  }

  Activity copyWith({
    String? id,
    String? segmentId,
    int? sortOrder,
    String? kind,
    String? name,
    Value<String?> notes = const Value.absent(),
    Value<int?> repetitions = const Value.absent(),
    Value<int?> workSeconds = const Value.absent(),
    Value<int?> restSeconds = const Value.absent(),
    Value<int?> rounds = const Value.absent(),
    Value<String?> instructions = const Value.absent(),
  }) => Activity(
    id: id ?? this.id,
    segmentId: segmentId ?? this.segmentId,
    sortOrder: sortOrder ?? this.sortOrder,
    kind: kind ?? this.kind,
    name: name ?? this.name,
    notes: notes.present ? notes.value : this.notes,
    repetitions: repetitions.present ? repetitions.value : this.repetitions,
    workSeconds: workSeconds.present ? workSeconds.value : this.workSeconds,
    restSeconds: restSeconds.present ? restSeconds.value : this.restSeconds,
    rounds: rounds.present ? rounds.value : this.rounds,
    instructions: instructions.present ? instructions.value : this.instructions,
  );
  Activity copyWithCompanion(ActivitiesCompanion data) {
    return Activity(
      id: data.id.present ? data.id.value : this.id,
      segmentId: data.segmentId.present ? data.segmentId.value : this.segmentId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      kind: data.kind.present ? data.kind.value : this.kind,
      name: data.name.present ? data.name.value : this.name,
      notes: data.notes.present ? data.notes.value : this.notes,
      repetitions: data.repetitions.present
          ? data.repetitions.value
          : this.repetitions,
      workSeconds: data.workSeconds.present
          ? data.workSeconds.value
          : this.workSeconds,
      restSeconds: data.restSeconds.present
          ? data.restSeconds.value
          : this.restSeconds,
      rounds: data.rounds.present ? data.rounds.value : this.rounds,
      instructions: data.instructions.present
          ? data.instructions.value
          : this.instructions,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Activity(')
          ..write('id: $id, ')
          ..write('segmentId: $segmentId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('repetitions: $repetitions, ')
          ..write('workSeconds: $workSeconds, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('rounds: $rounds, ')
          ..write('instructions: $instructions')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    segmentId,
    sortOrder,
    kind,
    name,
    notes,
    repetitions,
    workSeconds,
    restSeconds,
    rounds,
    instructions,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Activity &&
          other.id == this.id &&
          other.segmentId == this.segmentId &&
          other.sortOrder == this.sortOrder &&
          other.kind == this.kind &&
          other.name == this.name &&
          other.notes == this.notes &&
          other.repetitions == this.repetitions &&
          other.workSeconds == this.workSeconds &&
          other.restSeconds == this.restSeconds &&
          other.rounds == this.rounds &&
          other.instructions == this.instructions);
}

class ActivitiesCompanion extends UpdateCompanion<Activity> {
  final Value<String> id;
  final Value<String> segmentId;
  final Value<int> sortOrder;
  final Value<String> kind;
  final Value<String> name;
  final Value<String?> notes;
  final Value<int?> repetitions;
  final Value<int?> workSeconds;
  final Value<int?> restSeconds;
  final Value<int?> rounds;
  final Value<String?> instructions;
  final Value<int> rowid;
  const ActivitiesCompanion({
    this.id = const Value.absent(),
    this.segmentId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.kind = const Value.absent(),
    this.name = const Value.absent(),
    this.notes = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.workSeconds = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.rounds = const Value.absent(),
    this.instructions = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivitiesCompanion.insert({
    required String id,
    required String segmentId,
    required int sortOrder,
    required String kind,
    required String name,
    this.notes = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.workSeconds = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.rounds = const Value.absent(),
    this.instructions = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       segmentId = Value(segmentId),
       sortOrder = Value(sortOrder),
       kind = Value(kind),
       name = Value(name);
  static Insertable<Activity> custom({
    Expression<String>? id,
    Expression<String>? segmentId,
    Expression<int>? sortOrder,
    Expression<String>? kind,
    Expression<String>? name,
    Expression<String>? notes,
    Expression<int>? repetitions,
    Expression<int>? workSeconds,
    Expression<int>? restSeconds,
    Expression<int>? rounds,
    Expression<String>? instructions,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (segmentId != null) 'segment_id': segmentId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (kind != null) 'kind': kind,
      if (name != null) 'name': name,
      if (notes != null) 'notes': notes,
      if (repetitions != null) 'repetitions': repetitions,
      if (workSeconds != null) 'work_seconds': workSeconds,
      if (restSeconds != null) 'rest_seconds': restSeconds,
      if (rounds != null) 'rounds': rounds,
      if (instructions != null) 'instructions': instructions,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? segmentId,
    Value<int>? sortOrder,
    Value<String>? kind,
    Value<String>? name,
    Value<String?>? notes,
    Value<int?>? repetitions,
    Value<int?>? workSeconds,
    Value<int?>? restSeconds,
    Value<int?>? rounds,
    Value<String?>? instructions,
    Value<int>? rowid,
  }) {
    return ActivitiesCompanion(
      id: id ?? this.id,
      segmentId: segmentId ?? this.segmentId,
      sortOrder: sortOrder ?? this.sortOrder,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      repetitions: repetitions ?? this.repetitions,
      workSeconds: workSeconds ?? this.workSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      rounds: rounds ?? this.rounds,
      instructions: instructions ?? this.instructions,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (segmentId.present) {
      map['segment_id'] = Variable<String>(segmentId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (repetitions.present) {
      map['repetitions'] = Variable<int>(repetitions.value);
    }
    if (workSeconds.present) {
      map['work_seconds'] = Variable<int>(workSeconds.value);
    }
    if (restSeconds.present) {
      map['rest_seconds'] = Variable<int>(restSeconds.value);
    }
    if (rounds.present) {
      map['rounds'] = Variable<int>(rounds.value);
    }
    if (instructions.present) {
      map['instructions'] = Variable<String>(instructions.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('segmentId: $segmentId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('repetitions: $repetitions, ')
          ..write('workSeconds: $workSeconds, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('rounds: $rounds, ')
          ..write('instructions: $instructions, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourcePlanIdMeta = const VerificationMeta(
    'sourcePlanId',
  );
  @override
  late final GeneratedColumn<String> sourcePlanId = GeneratedColumn<String>(
    'source_plan_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plans (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _planSnapshotMeta = const VerificationMeta(
    'planSnapshot',
  );
  @override
  late final GeneratedColumn<String> planSnapshot = GeneratedColumn<String>(
    'plan_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtWallMeta = const VerificationMeta(
    'startedAtWall',
  );
  @override
  late final GeneratedColumn<DateTime> startedAtWall =
      GeneratedColumn<DateTime>(
        'started_at_wall',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _deadlineAtWallMeta = const VerificationMeta(
    'deadlineAtWall',
  );
  @override
  late final GeneratedColumn<DateTime> deadlineAtWall =
      GeneratedColumn<DateTime>(
        'deadline_at_wall',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
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
  static const VerificationMeta _updatedAtWallMeta = const VerificationMeta(
    'updatedAtWall',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtWall =
      GeneratedColumn<DateTime>(
        'updated_at_wall',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _workingPlanMeta = const VerificationMeta(
    'workingPlan',
  );
  @override
  late final GeneratedColumn<String> workingPlan = GeneratedColumn<String>(
    'working_plan',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeSegmentIdMeta = const VerificationMeta(
    'activeSegmentId',
  );
  @override
  late final GeneratedColumn<String> activeSegmentId = GeneratedColumn<String>(
    'active_segment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeActivityIdMeta = const VerificationMeta(
    'activeActivityId',
  );
  @override
  late final GeneratedColumn<String> activeActivityId = GeneratedColumn<String>(
    'active_activity_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _masterTimerStateMeta = const VerificationMeta(
    'masterTimerState',
  );
  @override
  late final GeneratedColumn<String> masterTimerState = GeneratedColumn<String>(
    'master_timer_state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intervalTimerStateMeta =
      const VerificationMeta('intervalTimerState');
  @override
  late final GeneratedColumn<String> intervalTimerState =
      GeneratedColumn<String>(
        'interval_timer_state',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourcePlanId,
    planSnapshot,
    startedAtWall,
    deadlineAtWall,
    status,
    updatedAtWall,
    workingPlan,
    activeSegmentId,
    activeActivityId,
    masterTimerState,
    intervalTimerState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_plan_id')) {
      context.handle(
        _sourcePlanIdMeta,
        sourcePlanId.isAcceptableOrUnknown(
          data['source_plan_id']!,
          _sourcePlanIdMeta,
        ),
      );
    }
    if (data.containsKey('plan_snapshot')) {
      context.handle(
        _planSnapshotMeta,
        planSnapshot.isAcceptableOrUnknown(
          data['plan_snapshot']!,
          _planSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_planSnapshotMeta);
    }
    if (data.containsKey('started_at_wall')) {
      context.handle(
        _startedAtWallMeta,
        startedAtWall.isAcceptableOrUnknown(
          data['started_at_wall']!,
          _startedAtWallMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedAtWallMeta);
    }
    if (data.containsKey('deadline_at_wall')) {
      context.handle(
        _deadlineAtWallMeta,
        deadlineAtWall.isAcceptableOrUnknown(
          data['deadline_at_wall']!,
          _deadlineAtWallMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deadlineAtWallMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('updated_at_wall')) {
      context.handle(
        _updatedAtWallMeta,
        updatedAtWall.isAcceptableOrUnknown(
          data['updated_at_wall']!,
          _updatedAtWallMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtWallMeta);
    }
    if (data.containsKey('working_plan')) {
      context.handle(
        _workingPlanMeta,
        workingPlan.isAcceptableOrUnknown(
          data['working_plan']!,
          _workingPlanMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workingPlanMeta);
    }
    if (data.containsKey('active_segment_id')) {
      context.handle(
        _activeSegmentIdMeta,
        activeSegmentId.isAcceptableOrUnknown(
          data['active_segment_id']!,
          _activeSegmentIdMeta,
        ),
      );
    }
    if (data.containsKey('active_activity_id')) {
      context.handle(
        _activeActivityIdMeta,
        activeActivityId.isAcceptableOrUnknown(
          data['active_activity_id']!,
          _activeActivityIdMeta,
        ),
      );
    }
    if (data.containsKey('master_timer_state')) {
      context.handle(
        _masterTimerStateMeta,
        masterTimerState.isAcceptableOrUnknown(
          data['master_timer_state']!,
          _masterTimerStateMeta,
        ),
      );
    }
    if (data.containsKey('interval_timer_state')) {
      context.handle(
        _intervalTimerStateMeta,
        intervalTimerState.isAcceptableOrUnknown(
          data['interval_timer_state']!,
          _intervalTimerStateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourcePlanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_plan_id'],
      ),
      planSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_snapshot'],
      )!,
      startedAtWall: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at_wall'],
      )!,
      deadlineAtWall: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deadline_at_wall'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      updatedAtWall: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_wall'],
      )!,
      workingPlan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}working_plan'],
      )!,
      activeSegmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_segment_id'],
      ),
      activeActivityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_activity_id'],
      ),
      masterTimerState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}master_timer_state'],
      ),
      intervalTimerState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interval_timer_state'],
      ),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final String id;

  /// Cleared (not deleted) when the saved plan is deleted.
  final String? sourcePlanId;

  /// The plan as JSON, copied at start.
  final String planSnapshot;
  final DateTime startedAtWall;
  final DateTime deadlineAtWall;
  final String status;
  final DateTime updatedAtWall;

  /// Snapshot plus session-only edits (audibles), as JSON.
  final String workingPlan;
  final String? activeSegmentId;
  final String? activeActivityId;
  final String? masterTimerState;
  final String? intervalTimerState;
  const Session({
    required this.id,
    this.sourcePlanId,
    required this.planSnapshot,
    required this.startedAtWall,
    required this.deadlineAtWall,
    required this.status,
    required this.updatedAtWall,
    required this.workingPlan,
    this.activeSegmentId,
    this.activeActivityId,
    this.masterTimerState,
    this.intervalTimerState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || sourcePlanId != null) {
      map['source_plan_id'] = Variable<String>(sourcePlanId);
    }
    map['plan_snapshot'] = Variable<String>(planSnapshot);
    map['started_at_wall'] = Variable<DateTime>(startedAtWall);
    map['deadline_at_wall'] = Variable<DateTime>(deadlineAtWall);
    map['status'] = Variable<String>(status);
    map['updated_at_wall'] = Variable<DateTime>(updatedAtWall);
    map['working_plan'] = Variable<String>(workingPlan);
    if (!nullToAbsent || activeSegmentId != null) {
      map['active_segment_id'] = Variable<String>(activeSegmentId);
    }
    if (!nullToAbsent || activeActivityId != null) {
      map['active_activity_id'] = Variable<String>(activeActivityId);
    }
    if (!nullToAbsent || masterTimerState != null) {
      map['master_timer_state'] = Variable<String>(masterTimerState);
    }
    if (!nullToAbsent || intervalTimerState != null) {
      map['interval_timer_state'] = Variable<String>(intervalTimerState);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      sourcePlanId: sourcePlanId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourcePlanId),
      planSnapshot: Value(planSnapshot),
      startedAtWall: Value(startedAtWall),
      deadlineAtWall: Value(deadlineAtWall),
      status: Value(status),
      updatedAtWall: Value(updatedAtWall),
      workingPlan: Value(workingPlan),
      activeSegmentId: activeSegmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(activeSegmentId),
      activeActivityId: activeActivityId == null && nullToAbsent
          ? const Value.absent()
          : Value(activeActivityId),
      masterTimerState: masterTimerState == null && nullToAbsent
          ? const Value.absent()
          : Value(masterTimerState),
      intervalTimerState: intervalTimerState == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalTimerState),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<String>(json['id']),
      sourcePlanId: serializer.fromJson<String?>(json['sourcePlanId']),
      planSnapshot: serializer.fromJson<String>(json['planSnapshot']),
      startedAtWall: serializer.fromJson<DateTime>(json['startedAtWall']),
      deadlineAtWall: serializer.fromJson<DateTime>(json['deadlineAtWall']),
      status: serializer.fromJson<String>(json['status']),
      updatedAtWall: serializer.fromJson<DateTime>(json['updatedAtWall']),
      workingPlan: serializer.fromJson<String>(json['workingPlan']),
      activeSegmentId: serializer.fromJson<String?>(json['activeSegmentId']),
      activeActivityId: serializer.fromJson<String?>(json['activeActivityId']),
      masterTimerState: serializer.fromJson<String?>(json['masterTimerState']),
      intervalTimerState: serializer.fromJson<String?>(
        json['intervalTimerState'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourcePlanId': serializer.toJson<String?>(sourcePlanId),
      'planSnapshot': serializer.toJson<String>(planSnapshot),
      'startedAtWall': serializer.toJson<DateTime>(startedAtWall),
      'deadlineAtWall': serializer.toJson<DateTime>(deadlineAtWall),
      'status': serializer.toJson<String>(status),
      'updatedAtWall': serializer.toJson<DateTime>(updatedAtWall),
      'workingPlan': serializer.toJson<String>(workingPlan),
      'activeSegmentId': serializer.toJson<String?>(activeSegmentId),
      'activeActivityId': serializer.toJson<String?>(activeActivityId),
      'masterTimerState': serializer.toJson<String?>(masterTimerState),
      'intervalTimerState': serializer.toJson<String?>(intervalTimerState),
    };
  }

  Session copyWith({
    String? id,
    Value<String?> sourcePlanId = const Value.absent(),
    String? planSnapshot,
    DateTime? startedAtWall,
    DateTime? deadlineAtWall,
    String? status,
    DateTime? updatedAtWall,
    String? workingPlan,
    Value<String?> activeSegmentId = const Value.absent(),
    Value<String?> activeActivityId = const Value.absent(),
    Value<String?> masterTimerState = const Value.absent(),
    Value<String?> intervalTimerState = const Value.absent(),
  }) => Session(
    id: id ?? this.id,
    sourcePlanId: sourcePlanId.present ? sourcePlanId.value : this.sourcePlanId,
    planSnapshot: planSnapshot ?? this.planSnapshot,
    startedAtWall: startedAtWall ?? this.startedAtWall,
    deadlineAtWall: deadlineAtWall ?? this.deadlineAtWall,
    status: status ?? this.status,
    updatedAtWall: updatedAtWall ?? this.updatedAtWall,
    workingPlan: workingPlan ?? this.workingPlan,
    activeSegmentId: activeSegmentId.present
        ? activeSegmentId.value
        : this.activeSegmentId,
    activeActivityId: activeActivityId.present
        ? activeActivityId.value
        : this.activeActivityId,
    masterTimerState: masterTimerState.present
        ? masterTimerState.value
        : this.masterTimerState,
    intervalTimerState: intervalTimerState.present
        ? intervalTimerState.value
        : this.intervalTimerState,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      sourcePlanId: data.sourcePlanId.present
          ? data.sourcePlanId.value
          : this.sourcePlanId,
      planSnapshot: data.planSnapshot.present
          ? data.planSnapshot.value
          : this.planSnapshot,
      startedAtWall: data.startedAtWall.present
          ? data.startedAtWall.value
          : this.startedAtWall,
      deadlineAtWall: data.deadlineAtWall.present
          ? data.deadlineAtWall.value
          : this.deadlineAtWall,
      status: data.status.present ? data.status.value : this.status,
      updatedAtWall: data.updatedAtWall.present
          ? data.updatedAtWall.value
          : this.updatedAtWall,
      workingPlan: data.workingPlan.present
          ? data.workingPlan.value
          : this.workingPlan,
      activeSegmentId: data.activeSegmentId.present
          ? data.activeSegmentId.value
          : this.activeSegmentId,
      activeActivityId: data.activeActivityId.present
          ? data.activeActivityId.value
          : this.activeActivityId,
      masterTimerState: data.masterTimerState.present
          ? data.masterTimerState.value
          : this.masterTimerState,
      intervalTimerState: data.intervalTimerState.present
          ? data.intervalTimerState.value
          : this.intervalTimerState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('sourcePlanId: $sourcePlanId, ')
          ..write('planSnapshot: $planSnapshot, ')
          ..write('startedAtWall: $startedAtWall, ')
          ..write('deadlineAtWall: $deadlineAtWall, ')
          ..write('status: $status, ')
          ..write('updatedAtWall: $updatedAtWall, ')
          ..write('workingPlan: $workingPlan, ')
          ..write('activeSegmentId: $activeSegmentId, ')
          ..write('activeActivityId: $activeActivityId, ')
          ..write('masterTimerState: $masterTimerState, ')
          ..write('intervalTimerState: $intervalTimerState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourcePlanId,
    planSnapshot,
    startedAtWall,
    deadlineAtWall,
    status,
    updatedAtWall,
    workingPlan,
    activeSegmentId,
    activeActivityId,
    masterTimerState,
    intervalTimerState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.sourcePlanId == this.sourcePlanId &&
          other.planSnapshot == this.planSnapshot &&
          other.startedAtWall == this.startedAtWall &&
          other.deadlineAtWall == this.deadlineAtWall &&
          other.status == this.status &&
          other.updatedAtWall == this.updatedAtWall &&
          other.workingPlan == this.workingPlan &&
          other.activeSegmentId == this.activeSegmentId &&
          other.activeActivityId == this.activeActivityId &&
          other.masterTimerState == this.masterTimerState &&
          other.intervalTimerState == this.intervalTimerState);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<String> id;
  final Value<String?> sourcePlanId;
  final Value<String> planSnapshot;
  final Value<DateTime> startedAtWall;
  final Value<DateTime> deadlineAtWall;
  final Value<String> status;
  final Value<DateTime> updatedAtWall;
  final Value<String> workingPlan;
  final Value<String?> activeSegmentId;
  final Value<String?> activeActivityId;
  final Value<String?> masterTimerState;
  final Value<String?> intervalTimerState;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.sourcePlanId = const Value.absent(),
    this.planSnapshot = const Value.absent(),
    this.startedAtWall = const Value.absent(),
    this.deadlineAtWall = const Value.absent(),
    this.status = const Value.absent(),
    this.updatedAtWall = const Value.absent(),
    this.workingPlan = const Value.absent(),
    this.activeSegmentId = const Value.absent(),
    this.activeActivityId = const Value.absent(),
    this.masterTimerState = const Value.absent(),
    this.intervalTimerState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    this.sourcePlanId = const Value.absent(),
    required String planSnapshot,
    required DateTime startedAtWall,
    required DateTime deadlineAtWall,
    required String status,
    required DateTime updatedAtWall,
    required String workingPlan,
    this.activeSegmentId = const Value.absent(),
    this.activeActivityId = const Value.absent(),
    this.masterTimerState = const Value.absent(),
    this.intervalTimerState = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       planSnapshot = Value(planSnapshot),
       startedAtWall = Value(startedAtWall),
       deadlineAtWall = Value(deadlineAtWall),
       status = Value(status),
       updatedAtWall = Value(updatedAtWall),
       workingPlan = Value(workingPlan);
  static Insertable<Session> custom({
    Expression<String>? id,
    Expression<String>? sourcePlanId,
    Expression<String>? planSnapshot,
    Expression<DateTime>? startedAtWall,
    Expression<DateTime>? deadlineAtWall,
    Expression<String>? status,
    Expression<DateTime>? updatedAtWall,
    Expression<String>? workingPlan,
    Expression<String>? activeSegmentId,
    Expression<String>? activeActivityId,
    Expression<String>? masterTimerState,
    Expression<String>? intervalTimerState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourcePlanId != null) 'source_plan_id': sourcePlanId,
      if (planSnapshot != null) 'plan_snapshot': planSnapshot,
      if (startedAtWall != null) 'started_at_wall': startedAtWall,
      if (deadlineAtWall != null) 'deadline_at_wall': deadlineAtWall,
      if (status != null) 'status': status,
      if (updatedAtWall != null) 'updated_at_wall': updatedAtWall,
      if (workingPlan != null) 'working_plan': workingPlan,
      if (activeSegmentId != null) 'active_segment_id': activeSegmentId,
      if (activeActivityId != null) 'active_activity_id': activeActivityId,
      if (masterTimerState != null) 'master_timer_state': masterTimerState,
      if (intervalTimerState != null)
        'interval_timer_state': intervalTimerState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? id,
    Value<String?>? sourcePlanId,
    Value<String>? planSnapshot,
    Value<DateTime>? startedAtWall,
    Value<DateTime>? deadlineAtWall,
    Value<String>? status,
    Value<DateTime>? updatedAtWall,
    Value<String>? workingPlan,
    Value<String?>? activeSegmentId,
    Value<String?>? activeActivityId,
    Value<String?>? masterTimerState,
    Value<String?>? intervalTimerState,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      sourcePlanId: sourcePlanId ?? this.sourcePlanId,
      planSnapshot: planSnapshot ?? this.planSnapshot,
      startedAtWall: startedAtWall ?? this.startedAtWall,
      deadlineAtWall: deadlineAtWall ?? this.deadlineAtWall,
      status: status ?? this.status,
      updatedAtWall: updatedAtWall ?? this.updatedAtWall,
      workingPlan: workingPlan ?? this.workingPlan,
      activeSegmentId: activeSegmentId ?? this.activeSegmentId,
      activeActivityId: activeActivityId ?? this.activeActivityId,
      masterTimerState: masterTimerState ?? this.masterTimerState,
      intervalTimerState: intervalTimerState ?? this.intervalTimerState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourcePlanId.present) {
      map['source_plan_id'] = Variable<String>(sourcePlanId.value);
    }
    if (planSnapshot.present) {
      map['plan_snapshot'] = Variable<String>(planSnapshot.value);
    }
    if (startedAtWall.present) {
      map['started_at_wall'] = Variable<DateTime>(startedAtWall.value);
    }
    if (deadlineAtWall.present) {
      map['deadline_at_wall'] = Variable<DateTime>(deadlineAtWall.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (updatedAtWall.present) {
      map['updated_at_wall'] = Variable<DateTime>(updatedAtWall.value);
    }
    if (workingPlan.present) {
      map['working_plan'] = Variable<String>(workingPlan.value);
    }
    if (activeSegmentId.present) {
      map['active_segment_id'] = Variable<String>(activeSegmentId.value);
    }
    if (activeActivityId.present) {
      map['active_activity_id'] = Variable<String>(activeActivityId.value);
    }
    if (masterTimerState.present) {
      map['master_timer_state'] = Variable<String>(masterTimerState.value);
    }
    if (intervalTimerState.present) {
      map['interval_timer_state'] = Variable<String>(intervalTimerState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('sourcePlanId: $sourcePlanId, ')
          ..write('planSnapshot: $planSnapshot, ')
          ..write('startedAtWall: $startedAtWall, ')
          ..write('deadlineAtWall: $deadlineAtWall, ')
          ..write('status: $status, ')
          ..write('updatedAtWall: $updatedAtWall, ')
          ..write('workingPlan: $workingPlan, ')
          ..write('activeSegmentId: $activeSegmentId, ')
          ..write('activeActivityId: $activeActivityId, ')
          ..write('masterTimerState: $masterTimerState, ')
          ..write('intervalTimerState: $intervalTimerState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlansTable plans = $PlansTable(this);
  late final $SegmentsTable segments = $SegmentsTable(this);
  late final $ActivitiesTable activities = $ActivitiesTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    plans,
    segments,
    activities,
    sessions,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'plans',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('segments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'segments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('activities', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'plans',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sessions', kind: UpdateKind.update)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$PlansTableCreateCompanionBuilder = PlansCompanion Function({
  required String id,
  required String title,
  Value<String?> description,
  required int targetDurationSeconds,
  required DateTime createdAt,
  required DateTime updatedAt,
  required int schemaVersion,
  Value<int> rowid,
});
typedef $$PlansTableUpdateCompanionBuilder = PlansCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String?> description,
  Value<int> targetDurationSeconds,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> schemaVersion,
  Value<int> rowid,
});

final class $$PlansTableReferences
    extends BaseReferences<_$AppDatabase, $PlansTable, Plan> {
  $$PlansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SegmentsTable, List<Segment>> _segmentsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.segments,
    aliasName: 'plans__id__segments__plan_id',
  );

  $$SegmentsTableProcessedTableManager get segmentsRefs {
    final manager = $$SegmentsTableTableManager(
      $_db,
      $_db.segments,
    ).filter((f) => f.planId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_segmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessionsTable, List<Session>> _sessionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sessions,
    aliasName: 'plans__id__sessions__source_plan_id',
  );

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.sourcePlanId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlansTableFilterComposer extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetDurationSeconds => $composableBuilder(
    column: $table.targetDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> segmentsRefs(
    Expression<bool> Function($$SegmentsTableFilterComposer f) f,
  ) {
    final $$SegmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.segments,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SegmentsTableFilterComposer(
            $db: $db,
            $table: $db.segments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionsRefs(
    Expression<bool> Function($$SessionsTableFilterComposer f) f,
  ) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.sourcePlanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlansTableOrderingComposer
    extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetDurationSeconds => $composableBuilder(
    column: $table.targetDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetDurationSeconds => $composableBuilder(
    column: $table.targetDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  Expression<T> segmentsRefs<T extends Object>(
    Expression<T> Function($$SegmentsTableAnnotationComposer a) f,
  ) {
    final $$SegmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.segments,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SegmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.segments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionsRefs<T extends Object>(
    Expression<T> Function($$SessionsTableAnnotationComposer a) f,
  ) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.sourcePlanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlansTable,
          Plan,
          $$PlansTableFilterComposer,
          $$PlansTableOrderingComposer,
          $$PlansTableAnnotationComposer,
          $$PlansTableCreateCompanionBuilder,
          $$PlansTableUpdateCompanionBuilder,
          (Plan, $$PlansTableReferences),
          Plan,
          PrefetchHooks Function({bool segmentsRefs, bool sessionsRefs})
        > {
  $$PlansTableTableManager(_$AppDatabase db, $PlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> targetDurationSeconds = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlansCompanion(
                id: id,
                title: title,
                description: description,
                targetDurationSeconds: targetDurationSeconds,
                createdAt: createdAt,
                updatedAt: updatedAt,
                schemaVersion: schemaVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> description = const Value.absent(),
                required int targetDurationSeconds,
                required DateTime createdAt,
                required DateTime updatedAt,
                required int schemaVersion,
                Value<int> rowid = const Value.absent(),
              }) => PlansCompanion.insert(
                id: id,
                title: title,
                description: description,
                targetDurationSeconds: targetDurationSeconds,
                createdAt: createdAt,
                updatedAt: updatedAt,
                schemaVersion: schemaVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlansTable, Plan>(table),
                  $$PlansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({segmentsRefs = false, sessionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (segmentsRefs) db.segments,
                    if (sessionsRefs) db.sessions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (segmentsRefs)
                        await $_getPrefetchedDataByColumns<
                          Plan,
                          $PlansTable,
                          Segment,
                          $SegmentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PlansTableReferences
                              ._segmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlansTableReferences(
                                db,
                                table,
                                p0,
                              ).segmentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'plan_id',
                          typedResults: items,
                        ),
                      if (sessionsRefs)
                        await $_getPrefetchedDataByColumns<
                          Plan,
                          $PlansTable,
                          Session,
                          $SessionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PlansTableReferences
                              ._sessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlansTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'source_plan_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlansTable,
      Plan,
      $$PlansTableFilterComposer,
      $$PlansTableOrderingComposer,
      $$PlansTableAnnotationComposer,
      $$PlansTableCreateCompanionBuilder,
      $$PlansTableUpdateCompanionBuilder,
      (Plan, $$PlansTableReferences),
      Plan,
      PrefetchHooks Function({bool segmentsRefs, bool sessionsRefs})
    >;
typedef $$SegmentsTableCreateCompanionBuilder = SegmentsCompanion Function({
  required String id,
  required String planId,
  required String title,
  required int sortOrder,
  Value<int?> estimatedDurationSeconds,
  Value<int> rowid,
});
typedef $$SegmentsTableUpdateCompanionBuilder = SegmentsCompanion Function({
  Value<String> id,
  Value<String> planId,
  Value<String> title,
  Value<int> sortOrder,
  Value<int?> estimatedDurationSeconds,
  Value<int> rowid,
});

final class $$SegmentsTableReferences
    extends BaseReferences<_$AppDatabase, $SegmentsTable, Segment> {
  $$SegmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlansTable _planIdTable(_$AppDatabase db) =>
      db.plans.createAlias('segments__plan_id__plans__id');

  $$PlansTableProcessedTableManager get planId {
    final $_column = $_itemColumn<String>('plan_id')!;

    final manager = $$PlansTableTableManager(
      $_db,
      $_db.plans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ActivitiesTable, List<Activity>>
  _activitiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.activities,
    aliasName: 'segments__id__activities__segment_id',
  );

  $$ActivitiesTableProcessedTableManager get activitiesRefs {
    final manager = $$ActivitiesTableTableManager(
      $_db,
      $_db.activities,
    ).filter((f) => f.segmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_activitiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SegmentsTableFilterComposer
    extends Composer<_$AppDatabase, $SegmentsTable> {
  $$SegmentsTableFilterComposer({
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

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedDurationSeconds => $composableBuilder(
    column: $table.estimatedDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  $$PlansTableFilterComposer get planId {
    final $$PlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableFilterComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> activitiesRefs(
    Expression<bool> Function($$ActivitiesTableFilterComposer f) f,
  ) {
    final $$ActivitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.segmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableFilterComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SegmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $SegmentsTable> {
  $$SegmentsTableOrderingComposer({
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

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedDurationSeconds => $composableBuilder(
    column: $table.estimatedDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlansTableOrderingComposer get planId {
    final $$PlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableOrderingComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SegmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SegmentsTable> {
  $$SegmentsTableAnnotationComposer({
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

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get estimatedDurationSeconds => $composableBuilder(
    column: $table.estimatedDurationSeconds,
    builder: (column) => column,
  );

  $$PlansTableAnnotationComposer get planId {
    final $$PlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableAnnotationComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> activitiesRefs<T extends Object>(
    Expression<T> Function($$ActivitiesTableAnnotationComposer a) f,
  ) {
    final $$ActivitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.segmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SegmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SegmentsTable,
          Segment,
          $$SegmentsTableFilterComposer,
          $$SegmentsTableOrderingComposer,
          $$SegmentsTableAnnotationComposer,
          $$SegmentsTableCreateCompanionBuilder,
          $$SegmentsTableUpdateCompanionBuilder,
          (Segment, $$SegmentsTableReferences),
          Segment,
          PrefetchHooks Function({bool planId, bool activitiesRefs})
        > {
  $$SegmentsTableTableManager(_$AppDatabase db, $SegmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SegmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SegmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SegmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> planId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int?> estimatedDurationSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SegmentsCompanion(
                id: id,
                planId: planId,
                title: title,
                sortOrder: sortOrder,
                estimatedDurationSeconds: estimatedDurationSeconds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String planId,
                required String title,
                required int sortOrder,
                Value<int?> estimatedDurationSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SegmentsCompanion.insert(
                id: id,
                planId: planId,
                title: title,
                sortOrder: sortOrder,
                estimatedDurationSeconds: estimatedDurationSeconds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SegmentsTable, Segment>(table),
                  $$SegmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({planId = false, activitiesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (activitiesRefs) db.activities],
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
                    if (planId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.planId,
                        referencedTable: $$SegmentsTableReferences._planIdTable(
                          db,
                        ),
                        referencedColumn: $$SegmentsTableReferences
                            ._planIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (activitiesRefs)
                    await $_getPrefetchedDataByColumns<
                      Segment,
                      $SegmentsTable,
                      Activity,
                      $ActivitiesTable
                    >(
                      currentTable: table,
                      referencedTable: $$SegmentsTableReferences
                          ._activitiesRefsTable(db),
                      managerFromTypedResult: (p0) => $$SegmentsTableReferences(
                        db,
                        table,
                        p0,
                      ).activitiesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'segment_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SegmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SegmentsTable,
      Segment,
      $$SegmentsTableFilterComposer,
      $$SegmentsTableOrderingComposer,
      $$SegmentsTableAnnotationComposer,
      $$SegmentsTableCreateCompanionBuilder,
      $$SegmentsTableUpdateCompanionBuilder,
      (Segment, $$SegmentsTableReferences),
      Segment,
      PrefetchHooks Function({bool planId, bool activitiesRefs})
    >;
typedef $$ActivitiesTableCreateCompanionBuilder = ActivitiesCompanion Function({
  required String id,
  required String segmentId,
  required int sortOrder,
  required String kind,
  required String name,
  Value<String?> notes,
  Value<int?> repetitions,
  Value<int?> workSeconds,
  Value<int?> restSeconds,
  Value<int?> rounds,
  Value<String?> instructions,
  Value<int> rowid,
});
typedef $$ActivitiesTableUpdateCompanionBuilder = ActivitiesCompanion Function({
  Value<String> id,
  Value<String> segmentId,
  Value<int> sortOrder,
  Value<String> kind,
  Value<String> name,
  Value<String?> notes,
  Value<int?> repetitions,
  Value<int?> workSeconds,
  Value<int?> restSeconds,
  Value<int?> rounds,
  Value<String?> instructions,
  Value<int> rowid,
});

final class $$ActivitiesTableReferences
    extends BaseReferences<_$AppDatabase, $ActivitiesTable, Activity> {
  $$ActivitiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SegmentsTable _segmentIdTable(_$AppDatabase db) =>
      db.segments.createAlias('activities__segment_id__segments__id');

  $$SegmentsTableProcessedTableManager get segmentId {
    final $_column = $_itemColumn<String>('segment_id')!;

    final manager = $$SegmentsTableTableManager(
      $_db,
      $_db.segments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_segmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableFilterComposer({
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

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get workSeconds => $composableBuilder(
    column: $table.workSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rounds => $composableBuilder(
    column: $table.rounds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => ColumnFilters(column),
  );

  $$SegmentsTableFilterComposer get segmentId {
    final $$SegmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.segmentId,
      referencedTable: $db.segments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SegmentsTableFilterComposer(
            $db: $db,
            $table: $db.segments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableOrderingComposer({
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

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get workSeconds => $composableBuilder(
    column: $table.workSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rounds => $composableBuilder(
    column: $table.rounds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => ColumnOrderings(column),
  );

  $$SegmentsTableOrderingComposer get segmentId {
    final $$SegmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.segmentId,
      referencedTable: $db.segments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SegmentsTableOrderingComposer(
            $db: $db,
            $table: $db.segments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get workSeconds => $composableBuilder(
    column: $table.workSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rounds =>
      $composableBuilder(column: $table.rounds, builder: (column) => column);

  GeneratedColumn<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => column,
  );

  $$SegmentsTableAnnotationComposer get segmentId {
    final $$SegmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.segmentId,
      referencedTable: $db.segments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SegmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.segments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivitiesTable,
          Activity,
          $$ActivitiesTableFilterComposer,
          $$ActivitiesTableOrderingComposer,
          $$ActivitiesTableAnnotationComposer,
          $$ActivitiesTableCreateCompanionBuilder,
          $$ActivitiesTableUpdateCompanionBuilder,
          (Activity, $$ActivitiesTableReferences),
          Activity,
          PrefetchHooks Function({bool segmentId})
        > {
  $$ActivitiesTableTableManager(_$AppDatabase db, $ActivitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> segmentId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> repetitions = const Value.absent(),
                Value<int?> workSeconds = const Value.absent(),
                Value<int?> restSeconds = const Value.absent(),
                Value<int?> rounds = const Value.absent(),
                Value<String?> instructions = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesCompanion(
                id: id,
                segmentId: segmentId,
                sortOrder: sortOrder,
                kind: kind,
                name: name,
                notes: notes,
                repetitions: repetitions,
                workSeconds: workSeconds,
                restSeconds: restSeconds,
                rounds: rounds,
                instructions: instructions,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String segmentId,
                required int sortOrder,
                required String kind,
                required String name,
                Value<String?> notes = const Value.absent(),
                Value<int?> repetitions = const Value.absent(),
                Value<int?> workSeconds = const Value.absent(),
                Value<int?> restSeconds = const Value.absent(),
                Value<int?> rounds = const Value.absent(),
                Value<String?> instructions = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesCompanion.insert(
                id: id,
                segmentId: segmentId,
                sortOrder: sortOrder,
                kind: kind,
                name: name,
                notes: notes,
                repetitions: repetitions,
                workSeconds: workSeconds,
                restSeconds: restSeconds,
                rounds: rounds,
                instructions: instructions,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ActivitiesTable, Activity>(table),
                  $$ActivitiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({segmentId = false}) {
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
                    if (segmentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.segmentId,
                        referencedTable: $$ActivitiesTableReferences
                            ._segmentIdTable(db),
                        referencedColumn: $$ActivitiesTableReferences
                            ._segmentIdTable(db)
                            .id,
                      ) as T;
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

typedef $$ActivitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivitiesTable,
      Activity,
      $$ActivitiesTableFilterComposer,
      $$ActivitiesTableOrderingComposer,
      $$ActivitiesTableAnnotationComposer,
      $$ActivitiesTableCreateCompanionBuilder,
      $$ActivitiesTableUpdateCompanionBuilder,
      (Activity, $$ActivitiesTableReferences),
      Activity,
      PrefetchHooks Function({bool segmentId})
    >;
typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  required String id,
  Value<String?> sourcePlanId,
  required String planSnapshot,
  required DateTime startedAtWall,
  required DateTime deadlineAtWall,
  required String status,
  required DateTime updatedAtWall,
  required String workingPlan,
  Value<String?> activeSegmentId,
  Value<String?> activeActivityId,
  Value<String?> masterTimerState,
  Value<String?> intervalTimerState,
  Value<int> rowid,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<String> id,
  Value<String?> sourcePlanId,
  Value<String> planSnapshot,
  Value<DateTime> startedAtWall,
  Value<DateTime> deadlineAtWall,
  Value<String> status,
  Value<DateTime> updatedAtWall,
  Value<String> workingPlan,
  Value<String?> activeSegmentId,
  Value<String?> activeActivityId,
  Value<String?> masterTimerState,
  Value<String?> intervalTimerState,
  Value<int> rowid,
});

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlansTable _sourcePlanIdTable(_$AppDatabase db) =>
      db.plans.createAlias('sessions__source_plan_id__plans__id');

  $$PlansTableProcessedTableManager? get sourcePlanId {
    final $_column = $_itemColumn<String>('source_plan_id');
    if ($_column == null) return null;
    final manager = $$PlansTableTableManager(
      $_db,
      $_db.plans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourcePlanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
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

  ColumnFilters<String> get planSnapshot => $composableBuilder(
    column: $table.planSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAtWall => $composableBuilder(
    column: $table.startedAtWall,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deadlineAtWall => $composableBuilder(
    column: $table.deadlineAtWall,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtWall => $composableBuilder(
    column: $table.updatedAtWall,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workingPlan => $composableBuilder(
    column: $table.workingPlan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeSegmentId => $composableBuilder(
    column: $table.activeSegmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeActivityId => $composableBuilder(
    column: $table.activeActivityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get masterTimerState => $composableBuilder(
    column: $table.masterTimerState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get intervalTimerState => $composableBuilder(
    column: $table.intervalTimerState,
    builder: (column) => ColumnFilters(column),
  );

  $$PlansTableFilterComposer get sourcePlanId {
    final $$PlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourcePlanId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableFilterComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
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

  ColumnOrderings<String> get planSnapshot => $composableBuilder(
    column: $table.planSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAtWall => $composableBuilder(
    column: $table.startedAtWall,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deadlineAtWall => $composableBuilder(
    column: $table.deadlineAtWall,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtWall => $composableBuilder(
    column: $table.updatedAtWall,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workingPlan => $composableBuilder(
    column: $table.workingPlan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeSegmentId => $composableBuilder(
    column: $table.activeSegmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeActivityId => $composableBuilder(
    column: $table.activeActivityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get masterTimerState => $composableBuilder(
    column: $table.masterTimerState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get intervalTimerState => $composableBuilder(
    column: $table.intervalTimerState,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlansTableOrderingComposer get sourcePlanId {
    final $$PlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourcePlanId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableOrderingComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get planSnapshot => $composableBuilder(
    column: $table.planSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAtWall => $composableBuilder(
    column: $table.startedAtWall,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deadlineAtWall => $composableBuilder(
    column: $table.deadlineAtWall,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAtWall => $composableBuilder(
    column: $table.updatedAtWall,
    builder: (column) => column,
  );

  GeneratedColumn<String> get workingPlan => $composableBuilder(
    column: $table.workingPlan,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activeSegmentId => $composableBuilder(
    column: $table.activeSegmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activeActivityId => $composableBuilder(
    column: $table.activeActivityId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get masterTimerState => $composableBuilder(
    column: $table.masterTimerState,
    builder: (column) => column,
  );

  GeneratedColumn<String> get intervalTimerState => $composableBuilder(
    column: $table.intervalTimerState,
    builder: (column) => column,
  );

  $$PlansTableAnnotationComposer get sourcePlanId {
    final $$PlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourcePlanId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableAnnotationComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, $$SessionsTableReferences),
          Session,
          PrefetchHooks Function({bool sourcePlanId})
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> sourcePlanId = const Value.absent(),
                Value<String> planSnapshot = const Value.absent(),
                Value<DateTime> startedAtWall = const Value.absent(),
                Value<DateTime> deadlineAtWall = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> updatedAtWall = const Value.absent(),
                Value<String> workingPlan = const Value.absent(),
                Value<String?> activeSegmentId = const Value.absent(),
                Value<String?> activeActivityId = const Value.absent(),
                Value<String?> masterTimerState = const Value.absent(),
                Value<String?> intervalTimerState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                sourcePlanId: sourcePlanId,
                planSnapshot: planSnapshot,
                startedAtWall: startedAtWall,
                deadlineAtWall: deadlineAtWall,
                status: status,
                updatedAtWall: updatedAtWall,
                workingPlan: workingPlan,
                activeSegmentId: activeSegmentId,
                activeActivityId: activeActivityId,
                masterTimerState: masterTimerState,
                intervalTimerState: intervalTimerState,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> sourcePlanId = const Value.absent(),
                required String planSnapshot,
                required DateTime startedAtWall,
                required DateTime deadlineAtWall,
                required String status,
                required DateTime updatedAtWall,
                required String workingPlan,
                Value<String?> activeSegmentId = const Value.absent(),
                Value<String?> activeActivityId = const Value.absent(),
                Value<String?> masterTimerState = const Value.absent(),
                Value<String?> intervalTimerState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                sourcePlanId: sourcePlanId,
                planSnapshot: planSnapshot,
                startedAtWall: startedAtWall,
                deadlineAtWall: deadlineAtWall,
                status: status,
                updatedAtWall: updatedAtWall,
                workingPlan: workingPlan,
                activeSegmentId: activeSegmentId,
                activeActivityId: activeActivityId,
                masterTimerState: masterTimerState,
                intervalTimerState: intervalTimerState,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionsTable, Session>(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sourcePlanId = false}) {
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
                    if (sourcePlanId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sourcePlanId,
                        referencedTable: $$SessionsTableReferences
                            ._sourcePlanIdTable(db),
                        referencedColumn: $$SessionsTableReferences
                            ._sourcePlanIdTable(db)
                            .id,
                      ) as T;
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

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, $$SessionsTableReferences),
      Session,
      PrefetchHooks Function({bool sourcePlanId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlansTableTableManager get plans =>
      $$PlansTableTableManager(_db, _db.plans);
  $$SegmentsTableTableManager get segments =>
      $$SegmentsTableTableManager(_db, _db.segments);
  $$ActivitiesTableTableManager get activities =>
      $$ActivitiesTableTableManager(_db, _db.activities);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
}
