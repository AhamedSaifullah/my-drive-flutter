import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import 'models/file_models.dart';
import 'models/file_summary.dart';

class FileMetadataCache {
    const FileMetadataCache(this.database);

    final AppDatabase database;

    Future<void> saveSummary(String key, FileSummary summary) async {
        try {
            await database.customStatement(
                '''
                                INSERT INTO cached_file_summaries
                                        (cache_key, total_files, total_size, categories_json)
                                VALUES (?, ?, ?, ?)
                                ON CONFLICT(cache_key) DO UPDATE SET
                                        total_files = excluded.total_files,
                                        total_size = excluded.total_size,
                                        categories_json = excluded.categories_json
                                ''',
                [
                    key,
                    summary.totalFiles,
                    summary.totalSize,
                    jsonEncode(summary.toJson()['categories']),
                ],
            );
        } catch (_) {
            // Cache failures must never prevent a successful API response.
        }
    }

    Future<FileSummary?> readSummary(String key) async {
        try {
            final rows = await database
                    .customSelect(
                        'SELECT total_files, total_size, categories_json '
                        'FROM cached_file_summaries WHERE cache_key = ?',
                        variables: [Variable.withString(key)],
                    )
                    .get();
            if (rows.isEmpty) return null;
            final row = rows.first.data;
            return FileSummary.fromJson({
                'totalFiles': row['total_files'],
                'totalSize': row['total_size'],
                'categories': jsonDecode(row['categories_json'] as String),
            });
        } catch (_) {
            return null;
        }
    }

    Future<void> savePage(String key, CloudFilePage page) async {
        try {
            await database.transaction(() async {
                for (final file in page.items) {
                    await database.customStatement(
                        '''
                                                INSERT INTO cached_files
                                                        (id, name, mime_type, category, size, modified_at, thumbnail_url)
                                                VALUES (?, ?, ?, ?, ?, ?, ?)
                                                ON CONFLICT(id) DO UPDATE SET
                                                        name = excluded.name,
                                                        mime_type = excluded.mime_type,
                                                        category = excluded.category,
                                                        size = excluded.size,
                                                        modified_at = excluded.modified_at,
                                                        thumbnail_url = excluded.thumbnail_url
                                                ''',
                        [
                            file.id,
                            file.name,
                            file.mimeType,
                            file.category,
                            file.size,
                            file.modifiedAt,
                            file.thumbnailUrl,
                        ],
                    );
                }
                await database.customStatement(
                    '''
                                        INSERT INTO cached_file_pages
                                                (cache_key, item_ids, page, total, has_next_page)
                                        VALUES (?, ?, ?, ?, ?)
                                        ON CONFLICT(cache_key) DO UPDATE SET
                                                item_ids = excluded.item_ids,
                                                page = excluded.page,
                                                total = excluded.total,
                                                has_next_page = excluded.has_next_page
                                        ''',
                    [
                        key,
                        jsonEncode(page.items.map((file) => file.id).toList()),
                        page.page,
                        page.total,
                        page.hasNextPage,
                    ],
                );
            });
        } catch (_) {
            // Cache failures must never prevent a successful API response.
        }
    }

    Future<CloudFilePage?> readPage(String key) async {
        try {
            final pageRows = await database
                    .customSelect(
                        'SELECT item_ids, page, total, has_next_page '
                        'FROM cached_file_pages WHERE cache_key = ?',
                        variables: [Variable.withString(key)],
                    )
                    .get();
            if (pageRows.isEmpty) return null;
            final page = pageRows.first.data;
            final ids = (jsonDecode(page['item_ids'] as String) as List)
                    .cast<String>();
            if (ids.isEmpty) {
                return CloudFilePage(
                    items: const [],
                    page: page['page'] as int,
                    total: page['total'] as int,
                    hasNextPage: (page['has_next_page'] as int) == 1,
                );
            }

            final placeholders = List.filled(ids.length, '?').join(', ');
            final rows = await database
                    .customSelect(
                        'SELECT id, name, mime_type, category, size, modified_at, thumbnail_url '
                        'FROM cached_files WHERE id IN ($placeholders)',
                        variables: ids.map(Variable.withString).toList(),
                    )
                    .get();
            final filesById = {
                for (final row in rows) row.data['id'] as String: row.data,
            };
            final files = ids
                    .map((id) => filesById[id])
                    .whereType<Map<String, Object?>>()
                    .map(_fileFromRow)
                    .toList();
            return CloudFilePage(
                items: files,
                page: page['page'] as int,
                total: page['total'] as int,
                hasNextPage: (page['has_next_page'] as int) == 1,
            );
        } catch (_) {
            return null;
        }
    }

    CloudFile _fileFromRow(Map<String, Object?> row) => CloudFile(
        id: row['id']! as String,
        name: row['name']! as String,
        mimeType: row['mime_type']! as String,
        category: row['category']! as String,
        size: row['size']! as int,
        modifiedAt: _dateTimeFromDatabase(row['modified_at']),
        thumbnailUrl: row['thumbnail_url'] as String?,
    );

    DateTime? _dateTimeFromDatabase(Object? value) {
        if (value is DateTime) return value;
        if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
        return value == null ? null : DateTime.tryParse('$value');
    }
}
