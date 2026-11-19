import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';

import '../../features/auth/data/auth_repository.dart';
import '../logging/app_logger.dart';
import '../storage/token_storage.dart';

final dioProvider = Provider<Dio>((ref) {
    final dio = Dio(
        BaseOptions(
            baseUrl: Env.apiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 20),
            headers: {'Content-Type': 'application/json'},
        ),
    );
    dio.interceptors.add(AuthInterceptor(ref));
    dio.interceptors.add(
        LogInterceptor(
            request: true,
            requestHeader: false,
            requestBody: true,
            responseHeader: false,
            responseBody: true,
            error: true,
            logPrint: (object) => AppLogger.log(object, tag: 'Dio'),
        ),
    );
    return dio;
});

class AuthInterceptor extends Interceptor {
    AuthInterceptor(this.ref);

    final Ref ref;
    Future<bool>? _refreshRequest;

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
    void onError(DioException err, ErrorInterceptorHandler handler) async {
        final shouldRefresh =
                err.response?.statusCode == 401 &&
                err.requestOptions.extra['skipAuthRefresh'] != true &&
                err.requestOptions.extra['retriedAfterRefresh'] != true;

        if (shouldRefresh) {
            _refreshRequest ??= ref
                    .read(authRepositoryProvider)
                    .refresh()
                    .whenComplete(() => _refreshRequest = null);
            final refreshed = await _refreshRequest!;

            if (refreshed) {
                final token = await ref.read(tokenStorageProvider).access;
                final retryOptions = err.requestOptions
                    ..headers['Authorization'] = 'Bearer $token'
                    ..extra['retriedAfterRefresh'] = true;
                return handler.resolve(await ref.read(dioProvider).fetch(retryOptions));
            }
        }

        if (err.response?.statusCode == 401) {
            await ref.read(tokenStorageProvider).clear();
        }
        handler.next(err);
    }
}
