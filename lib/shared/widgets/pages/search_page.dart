import 'package:flutter/material.dart';

import '../app_page.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Search files',
    subtitle: 'Find anything across your connected clouds.',
    child: Column(
      children: [
        const TextField(
          decoration: InputDecoration(
            hintText: 'Search files and folders',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 28),
        const Icon(Icons.search, size: 54, color: Color(0xFFC8CDE0)),
        const SizedBox(height: 12),
        const Text(
          'Search across all your accounts',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        const Text(
          'Your results will appear here.',
          style: TextStyle(fontSize: 13),
        ),
      ],
    ),
  );
}
