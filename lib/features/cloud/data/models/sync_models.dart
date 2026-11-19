class SyncStatus {
    const SyncStatus({
        required this.accountId,
        required this.status,
        required this.processedCount,
        required this.createdCount,
        required this.updatedCount,
        required this.deletedCount,
        this.startedAt,
        this.completedAt,
        this.error,
    });

    final String accountId;
    final String status;
    final int processedCount;
    final int createdCount;
    final int updatedCount;
    final int deletedCount;
    final DateTime? startedAt;
    final DateTime? completedAt;
    final String? error;

    bool get isRunning => status == 'queued' || status == 'running';

    factory SyncStatus.fromJson(dynamic value) {
        final json = value is Map<String, dynamic>
                ? value
                : const <String, dynamic>{};
        return SyncStatus(
            accountId: '${json['accountId'] ?? ''}',
            status: '${json['status'] ?? 'not_started'}',
            processedCount: _asInt(json['processedCount']),
            createdCount: _asInt(json['createdCount']),
            updatedCount: _asInt(json['updatedCount']),
            deletedCount: _asInt(json['deletedCount']),
            startedAt: _asDate(json['startedAt']),
            completedAt: _asDate(json['completedAt']),
            error: json['error'] as String?,
        );
    }
}

int _asInt(dynamic value) =>
        value is num ? value.toInt() : int.tryParse('$value') ?? 0;

DateTime? _asDate(dynamic value) =>
        value == null ? null : DateTime.tryParse('$value');
