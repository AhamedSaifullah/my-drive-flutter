import 'package:flutter/material.dart';

import '../app_page.dart';
import '../quick_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Good morning, Alex',
    subtitle: 'Everything in one place.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2540),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TOTAL STORAGE',
                style: TextStyle(
                  color: Color(0xFFB4BAD0),
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 11),
              const Text(
                '18.4 GB  /  35 GB',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: const LinearProgressIndicator(
                  value: .52,
                  minHeight: 8,
                  backgroundColor: Color(0xFF454B63),
                  color: Color(0xFF8D7BF1),
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                '52% used across 1 connected account',
                style: TextStyle(color: Color(0xFFB4BAD0), fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text('Quick access', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 14),
        const Row(
          children: [
            QuickTile(
              icon: Icons.image_outlined,
              title: 'Photos',
              count: '248 files',
              color: Color(0xFFFFE9D9),
            ),
            SizedBox(width: 12),
            QuickTile(
              icon: Icons.description_outlined,
              title: 'Documents',
              count: '96 files',
              color: Color(0xFFE5E5FF),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            QuickTile(
              icon: Icons.video_library_outlined,
              title: 'Videos',
              count: '32 files',
              color: Color(0xFFDFF6EF),
            ),
            SizedBox(width: 12),
            QuickTile(
              icon: Icons.star_border,
              title: 'Starred',
              count: '18 files',
              color: Color(0xFFFFF3CF),
            ),
          ],
        ),
      ],
    ),
  );
}
