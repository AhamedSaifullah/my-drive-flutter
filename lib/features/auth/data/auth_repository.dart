import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
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
            await api.createUser(request);
        } on DioException catch (e) {
            throw ApiException.fromDio(e);
        }
    }

    Future<void> login(LoginRequest request) async {
        try {
            final session = AuthSession.fromJson(await api.loginUser(request));
            if (session.accessToken.isEmpty)
                throw const ApiException(
                    'Login response did not include an access token',
                );
            await const TokenStorage().save(
                session.accessToken,
                session.refreshToken,
            );
        } on DioException catch (e) {
            throw ApiException.fromDio(e);
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

    Future<bool> refresh() async {
        final refreshToken = await const TokenStorage().refresh;
        if (refreshToken == null || refreshToken.isEmpty) return false;
        try {
            final session = AuthSession.fromJson(await api.refresh(refreshToken));
            if (session.accessToken.isEmpty) return false;
            await const TokenStorage().save(
                session.accessToken,
                session.refreshToken.isEmpty ? refreshToken : session.refreshToken,
            );
            return true;
        } on DioException {
            await const TokenStorage().clear();
            return false;
        }
    }
}
