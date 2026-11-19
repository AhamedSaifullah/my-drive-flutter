import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'cloud_api.dart';
import 'models/cloud_models.dart';
import 'models/file_models.dart';
import 'models/file_summary.dart';

final cloudRepositoryProvider = Provider<CloudRepository>(
    (ref) => CloudRepository(CloudApi(ref.read(dioProvider))),
);

class CloudRepository {
    const CloudRepository(this.api);

    final CloudApi api;

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
            return FileSummary.fromJson(data);
        } on DioException catch (error) {
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
            return CloudFilePage.fromJson(response);
        } on DioException catch (error) {
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
            return CloudFilePage.fromJson(response);
        } on DioException catch (error) {
            throw ApiException.fromDio(error);
        }
    }
}

final cloudAccountsProvider = FutureProvider<List<CloudAccount>>((ref) async {
    return ref.read(cloudRepositoryProvider).listAccounts();
});

final fileSummaryProvider = FutureProvider<FileSummary>((ref) async {
    return ref.read(cloudRepositoryProvider).getFilesSummary();
});
