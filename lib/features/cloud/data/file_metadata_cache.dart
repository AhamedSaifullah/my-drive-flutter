import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'models/file_models.dart';
import 'models/file_summary.dart';

class FileMetadataCache {
    const FileMetadataCache();

    static const _fileName = 'file_metadata_cache.json';

    Future<File> _cacheFile() async {
        final directory = await getApplicationSupportDirectory();
        return File('${directory.path}/$_fileName');
    }

    Future<Map<String, dynamic>> _read() async {
        try {
            final file = await _cacheFile();
            if (!await file.exists()) return <String, dynamic>{};
            final decoded = jsonDecode(await file.readAsString());
            return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
        } catch (_) {
            return <String, dynamic>{};
        }
    }

    Future<void> _write(Map<String, dynamic> cache) async {
        try {
            final file = await _cacheFile();
            await file.parent.create(recursive: true);
            await file.writeAsString(jsonEncode(cache));
        } catch (_) {
            // A cache failure must never prevent a successful API response.
        }
    }

    Future<void> saveSummary(String key, FileSummary summary) async {
        final cache = await _read();
        cache['summary:$key'] = summary.toJson();
        await _write(cache);
    }

    Future<FileSummary?> readSummary(String key) async {
        final value = (await _read())['summary:$key'];
        return value == null ? null : FileSummary.fromJson(value);
    }

    Future<void> savePage(String key, CloudFilePage page) async {
        final cache = await _read();
        cache['page:$key'] = page.toJson();
        await _write(cache);
    }

    Future<CloudFilePage?> readPage(String key) async {
        final value = (await _read())['page:$key'];
        return value == null ? null : CloudFilePage.fromJson(value);
    }
}
