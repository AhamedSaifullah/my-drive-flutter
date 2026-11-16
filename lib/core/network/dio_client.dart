import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';
import '../storage/token_storage.dart';
import '../../features/auth/data/auth_repository.dart';

final dioProvider = Provider<Dio>((ref) {
    final dio = Dio(
        BaseOptions(
            baseUrl: Env.apiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 20),
            headers: {'Content-Type': 'application/json'},
        ),
    );
    dio.interceptors.add(AuthInterceptor(ref, dio));
    return dio;
});

class AuthInterceptor extends Interceptor {
    AuthInterceptor(this.ref, this.dio);

    final Ref ref;
    final Dio dio;

    @override
    void onRequest(
        RequestOptions options,
        RequestInterceptorHandler handler,
    ) async {
        final token = await ref.read(tokenStorageProvider).access;
        if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
    }

    @override
    void onError(DioException error, ErrorInterceptorHandler handler) async {
        final path = error.requestOptions.path;
        final isAuthCall =
                path.contains('login-user') ||
                path.contains('create-user') ||
                path.contains('refresh');
        if (error.response?.statusCode == 401 && !isAuthCall) {
            final refreshed = await ref.read(authRepositoryProvider).refresh();
            if (refreshed) {
                final token = await ref.read(tokenStorageProvider).access;
                final request = error.requestOptions;
                request.headers['Authorization'] = 'Bearer $token';
                return handler.resolve(await dio.fetch(request));
            }
        }
        handler.next(error);
    }
}
