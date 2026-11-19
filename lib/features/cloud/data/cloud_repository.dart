import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'cloud_api.dart';
import 'file_metadata_cache.dart';
import 'models/cloud_models.dart';
import 'models/file_models.dart';
import 'models/file_summary.dart';
import 'models/sync_models.dart';

final cloudRepositoryProvider = Provider<CloudRepository>(
    (ref) => CloudRepository(
        CloudApi(ref.read(dioProvider)),
        FileMetadataCache(ref.read(appDatabaseProvider)),
    ),
);

final appDatabaseProvider = Provider<AppDatabase>((ref) {
    final database = AppDatabase();
    ref.onDispose(database.close);
    return database;
});

class CloudRepository {
    const CloudRepository(this.api, this.cache);

    final CloudApi api;
    final FileMetadataCache cache;

    Future<List<CloudAccount>> listAccounts() async {
        try {
            final response = await api.listGoogleAccounts();
            final rawAccounts = response is List
                    ? response
                    : response is Map<String, dynamic> && response['data'] is List
                    ? response['data'] as List
                    : const <dynamic>[];
            return rawAccounts
                    .whereType<Map<String, dynamic>>()
                    .map(CloudAccount.fromJson)
                    .toList();
        } on DioException catch (error) {
            throw ApiException.fromDio(error);
        }
    }

    Future<String> createGoogleLink() async {
        try {
            final response = await api.linkGoogle();
            final map = response is Map<String, dynamic>
                    ? response
                    : <String, dynamic>{};
            final data = map['data'] is Map<String, dynamic>
                    ? map['data'] as Map<String, dynamic>
                    : map;
            final authorizationUrl =
                    (data['authUrl'] ?? data['authorizationUrl'] ?? data['url'] ?? '')
                            as String;

            if (authorizationUrl.isEmpty) {
                throw const ApiException('Google authorization URL was not returned');
            }
            return authorizationUrl;
        } on DioException catch (error) {
            throw ApiException.fromDio(error);
        }
    }

    Future<void> unlinkAccount(String accountId) async {
        try {
            await api.unlinkAccount(accountId);
        } on DioException catch (error) {
            throw ApiException.fromDio(error);
        }
    }

    Future<FileSummary> getFilesSummary({String? accountId}) async {
        try {
            final response = await api.getFilesSummary(accountId: accountId);
            final map = response is Map<String, dynamic>
                    ? response
                    : <String, dynamic>{};
            final data = map['data'] is Map<String, dynamic>
                    ? map['data'] as Map<String, dynamic>
                    : map;
            final summary = FileSummary.fromJson(data);
            await cache.saveSummary(accountId ?? 'all', summary);
            return summary;
        } on DioException catch (error) {
            final cached = await cache.readSummary(accountId ?? 'all');
            if (cached != null) return cached;
            throw ApiException.fromDio(error);
        }
    }

    Future<CloudFilePage> listFiles({
        String? category,
        String? accountId,
        int page = 1,
        int limit = 20,
        String sort = 'modifiedAt',
        String order = 'desc',
    }) async {
        try {
            final response = await api.listFiles(
                category: category,
                accountId: accountId,
                page: page,
                limit: limit,
                sort: sort,
                order: order,
            );
            final result = CloudFilePage.fromJson(response);
            await cache.savePage(
                _pageCacheKey(
                    category: category,
                    accountId: accountId,
                    page: page,
                    limit: limit,
                    sort: sort,
                    order: order,
                ),
                result,
            );
            return result;
        } on DioException catch (error) {
            final cached = await cache.readPage(
                _pageCacheKey(
                    category: category,
                    accountId: accountId,
                    page: page,
                    limit: limit,
                    sort: sort,
                    order: order,
                ),
            );
            if (cached != null) return cached;
            throw ApiException.fromDio(error);
        }
    }

    Future<CloudFilePage> searchFiles({
        required String query,
        String? accountId,
        int page = 1,
        int limit = 50,
    }) async {
        try {
            final response = await api.searchFiles(
                query: query,
                accountId: accountId,
                page: page,
                limit: limit,
            );
            final result = CloudFilePage.fromJson(response);
            await cache.savePage(
                _searchCacheKey(
                    query: query,
                    accountId: accountId,
                    page: page,
                    limit: limit,
                ),
                result,
            );
            return result;
        } on DioException catch (error) {
            final cached = await cache.readPage(
                _searchCacheKey(
                    query: query,
                    accountId: accountId,
                    page: page,
                    limit: limit,
                ),
            );
            if (cached != null) return cached;
            throw ApiException.fromDio(error);
        }
    }

    Future<void> requestAccountSync(String accountId) async {
        try {
            await api.requestAccountSync(accountId);
        } on DioException catch (error) {
            throw ApiException.fromDio(error);
        }
    }

    Future<SyncStatus> getAccountSyncStatus(String accountId) async {
        try {
            return SyncStatus.fromJson(await api.getAccountSyncStatus(accountId));
        } on DioException catch (error) {
            throw ApiException.fromDio(error);
        }
    }
}

String _pageCacheKey({
    String? category,
    String? accountId,
    required int page,
    required int limit,
    required String sort,
    required String order,
}) =>
        'category=${category ?? 'all'}|account=${accountId ?? 'all'}|page=$page|limit=$limit|sort=$sort|order=$order';

String _searchCacheKey({
    required String query,
    String? accountId,
    required int page,
    required int limit,
}) =>
        'search=${query.trim().toLowerCase()}|account=${accountId ?? 'all'}|page=$page|limit=$limit';

final cloudAccountsProvider = FutureProvider<List<CloudAccount>>((ref) async {
    return ref.read(cloudRepositoryProvider).listAccounts();
});

final fileSummaryProvider = FutureProvider<FileSummary>((ref) async {
    return ref.read(cloudRepositoryProvider).getFilesSummary();
});

final syncStatusProvider = FutureProvider.autoDispose
        .family<SyncStatus, String>((ref, accountId) async {
            final status = await ref
                    .read(cloudRepositoryProvider)
                    .getAccountSyncStatus(accountId);
            if (status.isRunning) {
                final timer = Timer(const Duration(seconds: 2), ref.invalidateSelf);
                ref.onDispose(timer.cancel);
            } else if (status.status == 'completed') {
                ref.invalidate(fileSummaryProvider);
            }
            return status;
        });
