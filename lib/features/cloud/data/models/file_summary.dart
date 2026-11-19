class FileCategorySummary {
    const FileCategorySummary({required this.count, required this.totalSize});

    const FileCategorySummary.empty() : count = 0, totalSize = 0;

    final int count;
    final int totalSize;

    factory FileCategorySummary.fromJson(dynamic value) {
        final json = value is Map<String, dynamic>
                ? value
                : const <String, dynamic>{};
        return FileCategorySummary(
            count: _asInt(json['count']),
            totalSize: _asInt(json['totalSize']),
        );
    }
}

class FileSummary {
    const FileSummary({
        required this.totalFiles,
        required this.totalSize,
        required this.categories,
    });

    const FileSummary.empty()
        : totalFiles = 0,
            totalSize = 0,
            categories = const <String, FileCategorySummary>{};

    final int totalFiles;
    final int totalSize;
    final Map<String, FileCategorySummary> categories;

    factory FileSummary.fromJson(dynamic value) {
        final json = value is Map<String, dynamic>
                ? value
                : const <String, dynamic>{};
        final rawCategories = json['categories'];
        final categories = <String, FileCategorySummary>{};
        if (rawCategories is Map<String, dynamic>) {
            for (final entry in rawCategories.entries) {
                categories[entry.key] = FileCategorySummary.fromJson(entry.value);
            }
        }
        return FileSummary(
            totalFiles: _asInt(json['totalFiles']),
            totalSize: _asInt(json['totalSize']),
            categories: categories,
        );
    }

    FileCategorySummary category(String name) =>
            categories[name] ?? const FileCategorySummary.empty();
}

int _asInt(dynamic value) =>
        value is num ? value.toInt() : int.tryParse('$value') ?? 0;
