import 'package:dio/dio.dart';

class ApiException implements Exception {
    const ApiException(this.message, {this.statusCode});

    final String message;
    final int? statusCode;

    factory ApiException.fromDio(DioException error) {
        final data = error.response?.data;
        final message = data is Map<String, dynamic>
                ? (data['message'] ?? data['error'])
                : null;
        return ApiException(
            message is String && message.isNotEmpty
                    ? message
                    : error.message ?? 'Something went wrong',
            statusCode: error.response?.statusCode,
        );
    }

    @override
    String toString() => message;
}
