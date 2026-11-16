import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../data/models/auth_models.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
    AuthController.new,
);

class AuthController extends AsyncNotifier<void> {
    @override
    Future<void> build() async {}

    Future<void> login(String username, String password) async {
        state = const AsyncLoading();
        state = await AsyncValue.guard(
            () => ref
                    .read(authRepositoryProvider)
                    .login(LoginRequest(username: username, password: password)),
        );
    }

    Future<void> register(RegisterRequest request) async {
        state = const AsyncLoading();
        state = await AsyncValue.guard(
            () => ref.read(authRepositoryProvider).register(request),
        );
    }

    Future<dynamic> details() => ref.read(authRepositoryProvider).getDetails();

    Future<dynamic> updateUser(Map<String, dynamic> changes) =>
            ref.read(authRepositoryProvider).updateUser(changes);

    Future<void> logout() => ref.read(authRepositoryProvider).logout();
}
