import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:my_drive/features/auth/presentation/auth_controller.dart';

import '../app_page.dart';

class SettingsPage extends ConsumerWidget {
    const SettingsPage({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) => AppPage(
        title: 'Settings',
        subtitle: 'Make My Drive work for you.',
        child: Column(
            children: [
                const ListTile(
                    leading: Icon(Icons.person_outline),
                    title: Text('Account'),
                    subtitle: Text('alex@example.com'),
                    trailing: Icon(Icons.chevron_right),
                ),
                const Divider(),
                const ListTile(
                    leading: Icon(Icons.notifications_none),
                    title: Text('Notifications'),
                    trailing: Icon(Icons.chevron_right),
                ),
                const ListTile(
                    leading: Icon(Icons.security_outlined),
                    title: Text('Privacy & security'),
                    trailing: Icon(Icons.chevron_right),
                ),
                const ListTile(
                    leading: Icon(Icons.help_outline),
                    title: Text('Help & support'),
                    trailing: Icon(Icons.chevron_right),
                ),
                ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Logout', style: TextStyle(color: Colors.red)),
                    onTap: () => _logout(context, ref),
                ),
            ],
        ),
    );

    Future<void> _logout(BuildContext context, WidgetRef ref) async {
        try {
            await ref.read(authControllerProvider.notifier).logout();
            if (!context.mounted) return;
            context.go('/login');
        } catch (error) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error.toString()), backgroundColor: Colors.red),
            );
        }
    }
}
