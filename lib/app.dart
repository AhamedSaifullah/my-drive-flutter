import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/logging/app_logger.dart';
import 'core/navigation/app_router.dart';
import 'features/cloud/data/cloud_repository.dart';

class MyDriveApp extends ConsumerStatefulWidget {
    const MyDriveApp({super.key});

    @override
    ConsumerState<MyDriveApp> createState() => _MyDriveAppState();
}

class _MyDriveAppState extends ConsumerState<MyDriveApp> {
    late final AppLinks _appLinks;
    StreamSubscription<Uri>? _deepLinkSubscription;

    @override
    void initState() {
        super.initState();
        _appLinks = AppLinks();
        _listenForDeepLinks();
    }

    Future<void> _listenForDeepLinks() async {
        _deepLinkSubscription = _appLinks.uriLinkStream.listen(
            _handleDeepLink,
            onError: (Object error) {
                AppLogger.log('Deep-link error: $error', tag: 'DeepLink');
            },
        );

        try {
            final initialUri = await _appLinks.getInitialLink();
            if (initialUri != null) _handleDeepLink(initialUri);
        } catch (error) {
            AppLogger.log('Initial deep-link error: $error', tag: 'DeepLink');
        }
    }

    void _handleDeepLink(Uri uri) {
        if (uri.scheme != 'mydrive' || uri.host != 'linked') return;

        final provider = uri.queryParameters['provider'];
        final error = uri.queryParameters['error'];
        if (error != null && error.isNotEmpty) {
            AppLogger.log('Cloud link failed: $error', tag: 'DeepLink');
            appRouter.go('/home?cloudError=${Uri.encodeQueryComponent(error)}');
            return;
        }
        if (provider == null || provider.isEmpty) return;

        AppLogger.log('Cloud provider linked: $provider', tag: 'DeepLink');
        ref.invalidate(cloudAccountsProvider);
        ref.invalidate(fileSummaryProvider);
        appRouter.go('/home');
    }

    @override
    void dispose() {
        _deepLinkSubscription?.cancel();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) => MaterialApp.router(
        title: 'My Drive',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF7F8FC),
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6758E8)),
            inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE3E6EF)),
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE3E6EF)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 17,
                ),
            ),
        ),
        routerConfig: appRouter,
    );
}
