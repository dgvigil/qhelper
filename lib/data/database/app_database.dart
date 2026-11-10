import 'package:drift/drift.dart';

part 'app_database.g.dart';

class Plans extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  IntColumn get targetDurationSeconds => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get schemaVersion => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Segments extends Table {
  TextColumn get id => text()();
  TextColumn get planId =>
      text().references(Plans, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  IntColumn get sortOrder => integer()();
  IntColumn get estimatedDurationSeconds => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Activities extends Table {
  TextColumn get id => text()();
  TextColumn get segmentId =>
      text().references(Segments, #id, onDelete: KeyAction.cascade)();
  IntColumn get sortOrder => integer()();
  TextColumn get kind => text()();
  TextColumn get name => text()();
  TextColumn get notes => text().nullable()();
  IntColumn get repetitions => integer().nullable()();
  IntColumn get workSeconds => integer().nullable()();
  IntColumn get restSeconds => integer().nullable()();
  IntColumn get rounds => integer().nullable()();
  TextColumn get instructions => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [Plans, Segments, Activities])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Schema v1 is the baseline. Migration tests begin once v2 exists.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
