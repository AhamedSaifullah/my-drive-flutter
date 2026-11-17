import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/dashboard/presentation/app_shell.dart';
import '../storage/token_storage.dart';

final appRouter = GoRouter(
    initialLocation: '/welcome',
    redirect: (context, state) async {
        final isAuthenticated = await const TokenStorage().hasValidAccessToken();
        final isCloudLinkCallback =
                state.uri.scheme == 'mydrive' && state.uri.host == 'linked';
        final isPublicRoute = const {
            '/welcome',
            '/login',
            '/register',
        }.contains(state.matchedLocation);

        if (isCloudLinkCallback) return isAuthenticated ? '/home' : '/login';
        if (!isAuthenticated) return isPublicRoute ? null : '/welcome';
        if (isPublicRoute) return '/home';
        return null;
    },
    routes: [
        GoRoute(
            path: '/welcome',
            builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
            path: '/login',
            builder: (context, state) => const AuthScreen(login: true),
        ),
        GoRoute(
            path: '/register',
            builder: (context, state) => const AuthScreen(login: false),
        ),
        GoRoute(path: '/home', builder: (context, state) => const AppShell()),
    ],
    errorBuilder: (context, state) =>
            Scaffold(body: Center(child: Text(state.error.toString()))),
);
