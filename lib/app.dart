import 'package:flutter/material.dart';

import 'core/navigation/app_router.dart';

class MyDriveApp extends StatelessWidget {
    const MyDriveApp({super.key});

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
