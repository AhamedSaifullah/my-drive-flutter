import 'package:dio/dio.dart';

abstract final class CloudPaths {
    static const googleLink = '/cloud/google/link';
    static const googleAccounts = '/cloud/google/accounts';
    static const accounts = '/cloud/accounts';
    static const filesSummary = '/files/summary';
    static const files = '/files';
    static const fileSearch = '/files/search';

    static String accountSync(String accountId) => '$accounts/$accountId/sync';

    static String accountSyncStatus(String accountId) =>
            '$accounts/$accountId/sync/status';
}

class CloudApi {
    const CloudApi(this._dio);

    final Dio _dio;

    Future<dynamic> linkGoogle() async =>
            (await _dio.post(CloudPaths.googleLink)).data;

    Future<dynamic> listGoogleAccounts() async =>
            (await _dio.get(CloudPaths.googleAccounts)).data;

    Future<dynamic> unlinkAccount(String accountId) async =>
            (await _dio.delete('${CloudPaths.accounts}/$accountId')).data;

    Future<dynamic> getFilesSummary({String? accountId}) async => (await _dio.get(
        CloudPaths.filesSummary,
        queryParameters: {
            ...?accountId == null ? null : {'accountId': accountId},
        },
    )).data;

    Future<dynamic> listFiles({
        String? category,
        String? accountId,
        int page = 1,
        int limit = 20,
        String sort = 'modifiedAt',
        String order = 'desc',
    }) async => (await _dio.get(
        CloudPaths.files,
        queryParameters: {
            ...?category == null ? null : {'category': category},
            ...?accountId == null ? null : {'accountId': accountId},
            'page': page,
            'limit': limit,
            'sort': sort,
            'order': order,
        },
    )).data;

    Future<dynamic> searchFiles({
        required String query,
        String? accountId,
        int page = 1,
        int limit = 50,
    }) async => (await _dio.get(
        CloudPaths.fileSearch,
        queryParameters: {
            'q': query,
            ...?accountId == null ? null : {'accountId': accountId},
            'page': page,
            'limit': limit,
        },
    )).data;

    Future<dynamic> requestAccountSync(String accountId) async =>
            (await _dio.post(CloudPaths.accountSync(accountId))).data;

    Future<dynamic> getAccountSyncStatus(String accountId) async =>
            (await _dio.get(CloudPaths.accountSyncStatus(accountId))).data;
}
