class CloudFile {
    const CloudFile({
        required this.id,
        required this.name,
        required this.mimeType,
        required this.category,
        required this.size,
        required this.modifiedAt,
        this.thumbnailUrl,
    });

    final String id;
    final String name;
    final String mimeType;
    final String category;
    final int size;
    final DateTime? modifiedAt;
    final String? thumbnailUrl;

    Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'mimeType': mimeType,
        'category': category,
        'size': size,
        'modifiedAt': modifiedAt?.toIso8601String(),
        'thumbnailUrl': thumbnailUrl,
    };

    factory CloudFile.fromJson(Map<String, dynamic> json) => CloudFile(
        id: '${json['_id'] ?? json['id'] ?? ''}',
        name: '${json['name'] ?? 'Unnamed file'}',
        mimeType: '${json['mimeType'] ?? 'application/octet-stream'}',
        category: '${json['category'] ?? 'other'}',
        size: _asInt(json['size']),
        modifiedAt: DateTime.tryParse('${json['modifiedAt'] ?? ''}'),
        thumbnailUrl: json['thumbnailUrl'] as String?,
    );
}

class CloudFilePage {
    const CloudFilePage({
        required this.items,
        required this.page,
        required this.total,
        required this.hasNextPage,
    });

    final List<CloudFile> items;
    final int page;
    final int total;
    final bool hasNextPage;

    Map<String, dynamic> toJson() => {
        'items': items.map((file) => file.toJson()).toList(),
        'pagination': {'page': page, 'total': total, 'hasNextPage': hasNextPage},
    };

    factory CloudFilePage.fromJson(dynamic value) {
        final json = value is Map<String, dynamic>
                ? value
                : const <String, dynamic>{};
        final rawItems = json['items'] is List
                ? json['items'] as List
                : const <dynamic>[];
        final rawPagination = json['pagination'] is Map<String, dynamic>
                ? json['pagination'] as Map<String, dynamic>
                : const <String, dynamic>{};
        return CloudFilePage(
            items: rawItems
                    .whereType<Map<String, dynamic>>()
                    .map(CloudFile.fromJson)
                    .toList(),
            page: _asInt(rawPagination['page'], fallback: 1),
            total: _asInt(rawPagination['total']),
            hasNextPage: rawPagination['hasNextPage'] == true,
        );
    }
}

int _asInt(dynamic value, {int fallback = 0}) =>
        value is num ? value.toInt() : int.tryParse('$value') ?? fallback;
