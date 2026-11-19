import 'package:dio/dio.dart';

abstract final class CloudPaths {
    static const googleLink = '/cloud/google/link';
    static const googleAccounts = '/cloud/google/accounts';
    static const accounts = '/cloud/accounts';
    static const filesSummary = '/files/summary';
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
        queryParameters: accountId == null ? null : {'accountId': accountId},
    )).data;
}
