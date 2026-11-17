import 'package:dio/dio.dart';

abstract final class CloudPaths {
    static const googleLink = '/cloud/google/link';
}

class CloudApi {
    const CloudApi(this._dio);

    final Dio _dio;

    Future<dynamic> linkGoogle() async =>
            (await _dio.post(CloudPaths.googleLink)).data;
}
