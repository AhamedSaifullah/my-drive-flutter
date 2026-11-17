import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/storage/token_storage.dart';
import 'auth_api.dart';
import 'models/auth_models.dart';

final authRepositoryProvider = Provider<AuthRepository>(
    (ref) => AuthRepository(AuthApi(ref.read(dioProvider))),
);

class AuthRepository {
    const AuthRepository(this.api);
    final AuthApi api;

    Future<void> register(RegisterRequest request) async {
        try {
            AppLogger.log('Button clicked RegisterRequest $request', tag: 'Auth');
            await api.createUser(request);
        } on DioException catch (e) {
            throw ApiException.fromDio(e);
        }
    }

    Future<void> login(LoginRequest request) async {
        try {
            AppLogger.log(
                '[POST /user/login-user] payload: ${request.toJson()}',
                tag: 'Auth',
            );
            final response = await api.loginUser(request);
            AppLogger.log('[POST /user/login-user] response: $response', tag: 'Auth');
            final session = AuthSession.fromJson(response);
            if (session.accessToken.isEmpty) {
                throw const ApiException(
                    'Login response did not include an access token',
                );
            }
            await const TokenStorage().save(
                session.accessToken,
                session.refreshToken,
            );
        } on DioException catch (e) {
            AppLogger.log(
                '[POST /user/login-user] error: ${e.response?.data ?? e.message}',
                tag: 'Auth',
            );
            throw ApiException.fromDio(e);
        }
    }

    Future<bool> refresh() async {
        final storage = const TokenStorage();
        final refreshToken = await storage.refresh;
        if (refreshToken == null || refreshToken.isEmpty) {
            await storage.clear();
            return false;
        }

        try {
            final response = await api.refresh(refreshToken);
            final session = AuthSession.fromJson(response);
            if (session.accessToken.isEmpty) {
                await storage.clear();
                return false;
            }
            await storage.save(
                session.accessToken,
                session.refreshToken.isEmpty ? refreshToken : session.refreshToken,
            );
            return true;
        } on DioException catch (e) {
            AppLogger.log(
                '[POST /user/refresh] error: ${e.response?.data ?? e.message}',
                tag: 'Auth',
            );
            await storage.clear();
            return false;
        }
    }

    Future<dynamic> getDetails() async {
        try {
            return await api.details();
        } on DioException catch (e) {
            throw ApiException.fromDio(e);
        }
    }

    Future<void> logout() async {
        try {
            await api.logout();
        } on DioException catch (e) {
            throw ApiException.fromDio(e);
        } finally {
            await const TokenStorage().clear();
        }
    }

    Future<dynamic> updateUser(Map<String, dynamic> changes) async {
        try {
            return await api.updateUser(changes);
        } on DioException catch (e) {
            throw ApiException.fromDio(e);
        }
    }
}
