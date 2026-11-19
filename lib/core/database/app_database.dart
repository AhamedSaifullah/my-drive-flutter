import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

class AppDatabase extends GeneratedDatabase {
    AppDatabase([QueryExecutor? executor])
        : super(executor ?? driftDatabase(name: 'my_drive'));

    @override
    Iterable<TableInfo<Table, dynamic>> get allTables => const [];

    @override
    int get schemaVersion => 1;

    @override
    MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
            await customStatement('''
                                CREATE TABLE IF NOT EXISTS cached_files (
                                        id TEXT PRIMARY KEY NOT NULL,
                                        name TEXT NOT NULL,
                                        mime_type TEXT NOT NULL,
                                        category TEXT NOT NULL,
                                        size INTEGER NOT NULL,
                                        modified_at INTEGER,
                                        thumbnail_url TEXT
                                )
                        ''');
            await customStatement('''
                                CREATE TABLE IF NOT EXISTS cached_file_pages (
                                        cache_key TEXT PRIMARY KEY NOT NULL,
                                        item_ids TEXT NOT NULL,
                                        page INTEGER NOT NULL,
                                        total INTEGER NOT NULL,
                                        has_next_page INTEGER NOT NULL
                                )
                        ''');
            await customStatement('''
                                CREATE TABLE IF NOT EXISTS cached_file_summaries (
                                        cache_key TEXT PRIMARY KEY NOT NULL,
                                        total_files INTEGER NOT NULL,
                                        total_size INTEGER NOT NULL,
                                        categories_json TEXT NOT NULL
                                )
                        ''');
        },
    );
}
