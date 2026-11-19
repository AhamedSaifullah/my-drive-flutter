import 'package:flutter/material.dart';

import 'brand.dart';

class AppPage extends StatelessWidget {
    const AppPage({
        super.key,
        required this.title,
        required this.subtitle,
        required this.child,
        this.onRefresh,
    });
    final String title;
    final String subtitle;
    final Widget child;
    final Future<void> Function()? onRefresh;

    @override
    Widget build(BuildContext context) => SafeArea(
        child: RefreshIndicator(
            onRefresh: onRefresh ?? () async {},
            notificationPredicate: (_) => onRefresh != null,
            child: SingleChildScrollView(
                physics: onRefresh == null
                        ? null
                        : const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 30),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        const Brand(),
                        const SizedBox(height: 38),
                        Text(
                            title,
                            style: Theme.of(context).textTheme.headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 7),
                        Text(subtitle),
                        const SizedBox(height: 28),
                        child,
                    ],
                ),
            ),
        ),
    );
}
