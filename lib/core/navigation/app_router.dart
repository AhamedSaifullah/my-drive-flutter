import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_screen.dart';
import '../../features/dashboard/presentation/app_shell.dart';
import '../storage/token_storage.dart';

final appRouter = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) async {
        final isAuthenticated = await const TokenStorage().hasValidAccessToken();
        final isLoginRoute = state.matchedLocation == '/login';

        if (!isAuthenticated) return isLoginRoute ? null : '/login';
        if (isLoginRoute) return '/home';
        return null;
    },
    routes: [
        GoRoute(
            path: '/login',
            builder: (context, state) => const AuthScreen(login: true),
        ),
        GoRoute(path: '/home', builder: (context, state) => const AppShell()),
    ],
    errorBuilder: (context, state) =>
            Scaffold(body: Center(child: Text(state.error.toString()))),
);
