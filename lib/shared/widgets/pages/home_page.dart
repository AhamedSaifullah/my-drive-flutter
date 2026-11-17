import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../../features/cloud/presentation/cloud_controller.dart';
import '../app_page.dart';
import '../quick_tile.dart';

class HomePage extends ConsumerWidget {
    const HomePage({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        ref.listen<AsyncValue<void>>(cloudControllerProvider, (previous, next) {
            if (next.hasError && !(previous?.hasError ?? false)) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(next.error.toString()),
                        backgroundColor: Colors.red,
                    ),
                );
            }
            if (next is AsyncData<void> && previous?.isLoading == true) {
                AppLogger.log('Google Drive link flow completed', tag: 'Cloud');
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Google Drive linked successfully.'),
                        backgroundColor: Colors.green,
                    ),
                );
            }
        });

        final linkState = ref.watch(cloudControllerProvider);
        final greeting = _greetingForHour(DateTime.now().hour);

        return AppPage(
            title: '$greeting, Saif',
            subtitle: 'Everything in one place.',
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    _GoogleDriveLinkCard(
                        isLoading: linkState.isLoading,
                        onPressed: () =>
                                ref.read(cloudControllerProvider.notifier).linkGoogle(),
                    ),
                    const SizedBox(height: 28),
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

    String _greetingForHour(int hour) {
        if (hour >= 5 && hour < 12) return 'Good morning';
        if (hour >= 12 && hour < 17) return 'Good afternoon';
        if (hour >= 17 && hour < 21) return 'Good evening';
        return 'Good night';
    }
}

class _GoogleDriveLinkCard extends StatelessWidget {
    const _GoogleDriveLinkCard({
        required this.isLoading,
        required this.onPressed,
    });

    final bool isLoading;
    final VoidCallback onPressed;

    @override
    Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: const Color(0xFFEDEBFF),
            borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                const Icon(Icons.cloud_outlined, color: Color(0xFF6758E8), size: 28),
                const SizedBox(height: 12),
                Text(
                    'Connect your cloud storage',
                    style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text('Link Google Drive to access your files in one place.'),
                const SizedBox(height: 16),
                FilledButton.icon(
                    onPressed: isLoading ? null : onPressed,
                    icon: isLoading
                            ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                )
                            : const Icon(Icons.add_link),
                    label: Text(
                        isLoading ? 'Opening Google Drive...' : 'Link Google Drive',
                    ),
                ),
            ],
        ),
    );
}
