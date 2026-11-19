import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/cloud/data/cloud_repository.dart';
import '../../../features/cloud/data/models/cloud_models.dart';
import '../../../features/cloud/data/models/file_models.dart';
import '../../../features/cloud/presentation/file_viewer_page.dart';
import '../app_page.dart';

class SearchPage extends ConsumerStatefulWidget {
    const SearchPage({super.key});

    @override
    ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
    final _searchController = TextEditingController();
    Timer? _debounce;
    List<CloudFile> _results = const [];
    Object? _error;
    bool _loading = false;
    String? _accountId;
    int _searchGeneration = 0;

    @override
    void dispose() {
        _debounce?.cancel();
        _searchController.dispose();
        super.dispose();
    }

    void _onQueryChanged(String value) {
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 400), () {
            _search(query: value);
        });
        setState(() {
            _results = const [];
            _error = null;
        });
    }

    Future<void> _search({String? query}) async {
        final generation = ++_searchGeneration;
        final value = (query ?? _searchController.text).trim();
        if (value.isEmpty) {
            setState(() {
                _loading = false;
                _results = const [];
                _error = null;
            });
            return;
        }

        setState(() {
            _loading = true;
            _error = null;
        });
        try {
            final page = await ref
                    .read(cloudRepositoryProvider)
                    .searchFiles(query: value, accountId: _accountId);
            if (!mounted || generation != _searchGeneration) return;
            setState(() {
                _results = page.items;
                _loading = false;
            });
        } catch (error) {
            if (!mounted || generation != _searchGeneration) return;
            setState(() {
                _loading = false;
                _error = error;
            });
        }
    }

    @override
    Widget build(BuildContext context) => AppPage(
        title: 'Search files',
        subtitle: 'Find anything across your connected clouds.',
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                TextField(
                    controller: _searchController,
                    onChanged: _onQueryChanged,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: InputDecoration(
                        hintText: 'Search files and folders',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isEmpty
                                ? null
                                : IconButton(
                                        onPressed: () {
                                            _searchController.clear();
                                            _onQueryChanged('');
                                        },
                                        icon: const Icon(Icons.clear),
                                    ),
                    ),
                ),
                const SizedBox(height: 12),
                _AccountFilter(
                    accountId: _accountId,
                    onChanged: (value) {
                        setState(() => _accountId = value);
                        _search();
                    },
                ),
                const SizedBox(height: 24),
                if (_loading)
                    const Center(child: CircularProgressIndicator())
                else if (_error != null)
                    const _SearchMessage(
                        icon: Icons.cloud_off_outlined,
                        message: 'Search is temporarily unavailable.',
                    )
                else if (_searchController.text.trim().isEmpty)
                    const _SearchMessage(
                        icon: Icons.search,
                        message: 'Search across all your accounts',
                        detail: 'Results will appear as you type.',
                    )
                else if (_results.isEmpty)
                    const _SearchMessage(
                        icon: Icons.find_in_page_outlined,
                        message: 'No matching files found.',
                    )
                else
                    _SearchResults(files: _results),
            ],
        ),
    );
}

class _AccountFilter extends ConsumerWidget {
    const _AccountFilter({required this.accountId, required this.onChanged});

    final String? accountId;
    final ValueChanged<String?> onChanged;

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final accounts = ref.watch(cloudAccountsProvider);
        return accounts.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, stackTrace) => const Text('Account filter unavailable'),
            data: (items) => DropdownButtonFormField<String?>(
                value: accountId,
                decoration: const InputDecoration(
                    labelText: 'Filter by cloud account',
                    prefixIcon: Icon(Icons.cloud_outlined),
                ),
                items: [
                    const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All connected accounts'),
                    ),
                    ...items.map(
                        (account) => DropdownMenuItem<String?>(
                            value: account.id,
                            child: Text(account.emailOrName),
                        ),
                    ),
                ],
                onChanged: onChanged,
            ),
        );
    }
}

class _SearchResults extends StatelessWidget {
    const _SearchResults({required this.files});

    final List<CloudFile> files;

    @override
    Widget build(BuildContext context) => Column(
        children: files
                .map(
                    (file) => Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => FileViewerPage(file: file)),
                            ),
                            leading: Icon(_iconForCategory(file.category)),
                            title: Text(
                                file.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text('${_formatBytes(file.size)}  •  ${file.category}'),
                            trailing: const Icon(Icons.chevron_right),
                        ),
                    ),
                )
                .toList(),
    );
}

class _SearchMessage extends StatelessWidget {
    const _SearchMessage({
        required this.icon,
        required this.message,
        this.detail,
    });

    final IconData icon;
    final String message;
    final String? detail;

    @override
    Widget build(BuildContext context) => Center(
        child: Column(
            children: [
                Icon(icon, size: 54, color: const Color(0xFFC8CDE0)),
                const SizedBox(height: 12),
                Text(message, style: const TextStyle(fontWeight: FontWeight.w700)),
                if (detail != null) ...[
                    const SizedBox(height: 5),
                    Text(detail!, style: const TextStyle(fontSize: 13)),
                ],
            ],
        ),
    );
}

extension on CloudAccount {
    String get emailOrName => email.isNotEmpty ? email : displayName;
}

IconData _iconForCategory(String category) => switch (category) {
    'image' => Icons.image_outlined,
    'video' => Icons.video_library_outlined,
    'audio' => Icons.audiotrack_outlined,
    'document' => Icons.description_outlined,
    _ => Icons.insert_drive_file_outlined,
};

String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    const units = ['KB', 'MB', 'GB', 'TB'];
    var value = bytes.toDouble();
    var unitIndex = -1;
    while (value >= 1024 && unitIndex < units.length - 1) {
        value /= 1024;
        unitIndex++;
    }
    return '${value.toStringAsFixed(value >= 10 ? 0 : 1)} ${units[unitIndex]}';
}
