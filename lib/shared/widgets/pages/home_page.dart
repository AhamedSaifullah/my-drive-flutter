import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../../features/cloud/data/cloud_repository.dart';
import '../../../features/cloud/data/models/file_summary.dart';
import '../../../features/cloud/presentation/cloud_controller.dart';
import '../../../features/cloud/presentation/files_page.dart';
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
        final summaryState = ref.watch(fileSummaryProvider);
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
                    _StorageSummary(summaryState: summaryState),
                    const SizedBox(height: 28),
                    Text('Quick access', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 14),
                    _FileCategoryTiles(summaryState: summaryState),
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

class _StorageSummary extends StatelessWidget {
    const _StorageSummary({required this.summaryState});

    final AsyncValue<FileSummary> summaryState;

    @override
    Widget build(BuildContext context) {
        final summary = summaryState.value ?? const FileSummary.empty();
        final detail = summaryState.hasError
                ? 'Unable to load the latest file summary.'
                : '${summary.totalFiles} files across your connected accounts';

        return Container(
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
                    Text(
                        summaryState.isLoading
                                ? 'Loading summary...'
                                : _formatBytes(summary.totalSize),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                        ),
                    ),
                    const SizedBox(height: 15),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                            value: summaryState.isLoading ? null : 1,
                            minHeight: 8,
                            backgroundColor: const Color(0xFF454B63),
                            color: summaryState.hasError
                                    ? const Color(0xFFE57373)
                                    : const Color(0xFF8D7BF1),
                        ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                        detail,
                        style: const TextStyle(color: Color(0xFFB4BAD0), fontSize: 12),
                    ),
                ],
            ),
        );
    }
}

class _FileCategoryTiles extends StatelessWidget {
    const _FileCategoryTiles({required this.summaryState});

    final AsyncValue<FileSummary> summaryState;

    @override
    Widget build(BuildContext context) {
        final summary = summaryState.value ?? const FileSummary.empty();
        final loading = summaryState.isLoading;

        return Column(
            children: [
                Row(
                    children: [
                        _tile(
                            context,
                            summary,
                            'image',
                            'Images',
                            Icons.image_outlined,
                            const Color(0xFFFFE9D9),
                            loading,
                        ),
                        const SizedBox(width: 12),
                        _tile(
                            context,
                            summary,
                            'video',
                            'Videos',
                            Icons.video_library_outlined,
                            const Color(0xFFDFF6EF),
                            loading,
                        ),
                    ],
                ),
                const SizedBox(height: 12),
                Row(
                    children: [
                        _tile(
                            context,
                            summary,
                            'audio',
                            'Audio',
                            Icons.audiotrack_outlined,
                            const Color(0xFFFFF3CF),
                            loading,
                        ),
                        const SizedBox(width: 12),
                        _tile(
                            context,
                            summary,
                            'document',
                            'Documents',
                            Icons.description_outlined,
                            const Color(0xFFE5E5FF),
                            loading,
                        ),
                    ],
                ),
                const SizedBox(height: 12),
                Row(
                    children: [
                        _tile(
                            context,
                            summary,
                            'other',
                            'Other',
                            Icons.insert_drive_file_outlined,
                            const Color(0xFFE6EEF8),
                            loading,
                        ),
                        const Expanded(child: SizedBox()),
                    ],
                ),
                if (summaryState.hasError) ...[
                    const SizedBox(height: 10),
                    Text(
                        'Category totals are temporarily unavailable.',
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                ],
            ],
        );
    }

    Widget _tile(
        BuildContext context,
        FileSummary summary,
        String category,
        String title,
        IconData icon,
        Color color,
        bool loading,
    ) {
        final count = summary.category(category).count;
        return QuickTile(
            icon: icon,
            title: title,
            count: loading ? 'Loading...' : '$count files',
            color: color,
            onTap: loading
                    ? null
                    : () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => FilesPage(category: category)),
                        ),
        );
    }
}

String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    const units = ['KB', 'MB', 'GB', 'TB'];
    var value = bytes.toDouble();
    var unitIndex = -1;
    while (value >= 1024 && unitIndex < units.length - 1) {
        value /= 1024;
        unitIndex++;
    }
    final decimals = value >= 10 ? 0 : 1;
    return '${value.toStringAsFixed(decimals)} ${units[unitIndex]}';
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
