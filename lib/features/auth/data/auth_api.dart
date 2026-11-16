import 'package:dio/dio.dart';

import 'models/auth_models.dart';

abstract final class AuthPaths {
    static const createUser = '/user/create-user';
    static const loginUser = '/user/login-user';
    static const details = '/user/details';
    static const logout = '/user/logout';
    static const updateUser = '/user/update-user';
    static const refresh = '/auth/refresh';
}

class AuthApi {
    const AuthApi(this._dio);
    final Dio _dio;

    Future<dynamic> createUser(RegisterRequest request) async =>
            (await _dio.post(AuthPaths.createUser, data: request.toJson())).data;

    Future<dynamic> loginUser(LoginRequest request) async =>
            (await _dio.post(AuthPaths.loginUser, data: request.toJson())).data;

    Future<dynamic> details() async => (await _dio.get(AuthPaths.details)).data;

    Future<dynamic> logout() async => (await _dio.post(AuthPaths.logout)).data;

    Future<dynamic> updateUser(Map<String, dynamic> changes) async =>
            (await _dio.patch(AuthPaths.updateUser, data: changes)).data;

    Future<dynamic> refresh(String token) async =>
            (await _dio.post(AuthPaths.refresh, data: {'refreshToken': token})).data;
}
