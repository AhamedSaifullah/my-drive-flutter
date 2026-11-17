import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'cloud_api.dart';

final cloudRepositoryProvider = Provider<CloudRepository>(
    (ref) => CloudRepository(CloudApi(ref.read(dioProvider))),
);

class CloudRepository {
    const CloudRepository(this.api);

    final CloudApi api;

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
}
