import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class Requests extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 5, max: 64)();
  TextColumn get url => text().nullable()();
  TextColumn get method => text().nullable()();
  TextColumn get body => text().nullable()();
  TextColumn get headers => text().nullable()();
  TextColumn get response => text().nullable()();
  late final project = integer().nullable().references(Projects, #id, onDelete: KeyAction.cascade)();
}

class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 3, max: 64)();
  TextColumn get variables => text().nullable()();
}

@DriftDatabase(tables: [Requests])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'app_db',
      native: const DriftNativeOptions(databaseDirectory: getApplicationSupportDirectory),
    );
  }
}
