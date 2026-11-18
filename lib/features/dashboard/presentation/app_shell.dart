import 'package:flutter/material.dart';

import '../../../shared/widgets/pages/accounts_page.dart';
import '../../../shared/widgets/pages/home_page.dart';
import '../../../shared/widgets/pages/search_page.dart';
import '../../../shared/widgets/pages/settings_page.dart';

class AppShell extends StatefulWidget {
    const AppShell({super.key, this.cloudError});

    final String? cloudError;

    @override
    State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
    int index = 1;

    @override
    void initState() {
        super.initState();
        if (widget.cloudError == null) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Google Drive linking failed: ${widget.cloudError}'),
                    backgroundColor: Colors.red,
                ),
            );
        });
    }

    @override
    Widget build(BuildContext context) {
        final pages = [
            const HomePage(),
            const AccountsPage(),
            const SearchPage(),
            const SettingsPage(),
        ];
        return Scaffold(
            body: IndexedStack(index: index, children: pages),
            bottomNavigationBar: NavigationBar(
                selectedIndex: index,
                onDestinationSelected: (value) => setState(() => index = value),
                destinations: const [
                    NavigationDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: 'Home',
                    ),
                    NavigationDestination(
                        icon: Icon(Icons.folder_outlined),
                        selectedIcon: Icon(Icons.folder),
                        label: 'List',
                    ),
                    NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
                    NavigationDestination(
                        icon: Icon(Icons.settings_outlined),
                        selectedIcon: Icon(Icons.settings),
                        label: 'Settings',
                    ),
                ],
            ),
        );
    }
}
