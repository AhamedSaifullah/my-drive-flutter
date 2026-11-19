import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../../core/storage/token_storage.dart';
import '../data/cloud_repository.dart';
import '../data/models/file_models.dart';
import 'file_viewer_page.dart';

class FilesPage extends ConsumerStatefulWidget {
    const FilesPage({super.key, required this.category});

    final String category;

    @override
    ConsumerState<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends ConsumerState<FilesPage> {
    final _scrollController = ScrollController();
    final _files = <CloudFile>[];
    Object? _error;
    bool _loading = true;
    bool _loadingMore = false;
    bool _hasNextPage = false;
    int _page = 1;

    @override
    void initState() {
        super.initState();
        _scrollController.addListener(_onScroll);
        _loadFiles();
    }

    @override
    void dispose() {
        _scrollController
            ..removeListener(_onScroll)
            ..dispose();
        super.dispose();
    }

    Future<void> _loadFiles({bool refresh = false}) async {
        if (_loadingMore || (!refresh && !_loading && !_hasNextPage)) return;
        if (refresh) {
            setState(() {
                _files.clear();
                _page = 1;
                _hasNextPage = false;
                _error = null;
                _loading = true;
            });
        } else if (_files.isEmpty) {
            setState(() {
                _loading = true;
                _error = null;
            });
        } else {
            setState(() => _loadingMore = true);
        }

        try {
            final result = await ref
                    .read(cloudRepositoryProvider)
                    .listFiles(category: widget.category, page: _page, limit: 50);
            if (!mounted) return;
            setState(() {
                _files.addAll(result.items);
                _page = result.page + 1;
                _hasNextPage = result.hasNextPage;
                _loading = false;
                _loadingMore = false;
                _error = null;
            });
        } catch (error) {
            if (!mounted) return;
            setState(() {
                _loading = false;
                _loadingMore = false;
                _error = error;
            });
        }
    }

    void _onScroll() {
        if (_scrollController.position.extentAfter < 500) _loadFiles();
    }

    @override
    Widget build(BuildContext context) {
        final isGrid = widget.category == 'image' || widget.category == 'video';
        return Scaffold(
            appBar: AppBar(title: Text(_categoryTitle(widget.category))),
            body: _buildBody(isGrid),
        );
    }

    Widget _buildBody(bool isGrid) {
        if (_loading && _files.isEmpty) {
            return const Center(child: CircularProgressIndicator());
        }
        if (_error != null && _files.isEmpty) {
            return _ErrorState(
                error: _error!,
                onRetry: () => _loadFiles(refresh: true),
            );
        }
        if (_files.isEmpty) {
            return RefreshIndicator(
                onRefresh: () => _loadFiles(refresh: true),
                child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                        SizedBox(height: 180),
                        Icon(Icons.folder_open_outlined, size: 56),
                        SizedBox(height: 12),
                        Center(child: Text('No files in this category.')),
                    ],
                ),
            );
        }

        return RefreshIndicator(
            onRefresh: () => _loadFiles(refresh: true),
            child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                    SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: isGrid ? _buildGrid() : _buildList(),
                    ),
                    if (_loadingMore)
                        const SliverToBoxAdapter(
                            child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(child: CircularProgressIndicator()),
                            ),
                        ),
                ],
            ),
        );
    }

    Widget _buildGrid() => SliverGrid.builder(
        itemCount: _files.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: .82,
        ),
        itemBuilder: (context, index) => _FileGridCard(
            file: _files[index],
            onTap: () => _openFile(_files[index]),
        ),
    );

    Widget _buildList() => SliverList.builder(
        itemCount: _files.length,
        itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _FileListTile(
                file: _files[index],
                onTap: () => _openFile(_files[index]),
            ),
        ),
    );

    void _openFile(CloudFile file) {
        Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => FileViewerPage(file: file)));
    }
}

class _FileGridCard extends StatelessWidget {
    const _FileGridCard({required this.file, required this.onTap});

    final CloudFile file;
    final VoidCallback onTap;

    @override
    Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
            onTap: onTap,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Expanded(child: _FilePreview(file: file)),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                        child: Text(
                            file.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                    ),
                ],
            ),
        ),
    );
}

class _FileListTile extends StatelessWidget {
    const _FileListTile({required this.file, required this.onTap});

    final CloudFile file;
    final VoidCallback onTap;

    @override
    Widget build(BuildContext context) => Card(
        child: ListTile(
            onTap: onTap,
            leading: _FileIcon(category: file.category),
            title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(
                '${_formatBytes(file.size)}  •  ${_formatDate(file.modifiedAt)}',
            ),
            trailing: const Icon(Icons.chevron_right),
        ),
    );
}

class _FilePreview extends StatelessWidget {
    const _FilePreview({required this.file});

    final CloudFile file;

    @override
    Widget build(BuildContext context) => Container(
        width: double.infinity,
        color: const Color(0xFFEDEBFF),
        child: file.thumbnailUrl == null
                ? _FileIcon(category: file.category, size: 48)
                : FutureBuilder<String?>(
                        future: const TokenStorage().access,
                        builder: (context, snapshot) {
                            final token = snapshot.data;
                            if (token == null) {
                                return _FileIcon(category: file.category, size: 48);
                            }
                            return Image.network(
                                '${Env.apiBaseUrl}files/${file.id}/thumbnail',
                                headers: {'Authorization': 'Bearer $token'},
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                        _FileIcon(category: file.category, size: 48),
                            );
                        },
                    ),
    );
}

class _FileIcon extends StatelessWidget {
    const _FileIcon({required this.category, this.size = 28});

    final String category;
    final double size;

    @override
    Widget build(BuildContext context) => Center(
        child: Icon(
            _iconForCategory(category),
            size: size,
            color: const Color(0xFF6758E8),
        ),
    );
}

class _ErrorState extends StatelessWidget {
    const _ErrorState({required this.error, required this.onRetry});

    final Object error;
    final VoidCallback onRetry;

    @override
    Widget build(BuildContext context) => Center(
        child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    const Icon(Icons.cloud_off_outlined, size: 48),
                    const SizedBox(height: 12),
                    const Text('Could not load files.'),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: onRetry, child: const Text('Try again')),
                ],
            ),
        ),
    );
}

String _categoryTitle(String category) => switch (category) {
    'image' => 'Images',
    'video' => 'Videos',
    'audio' => 'Audio',
    'document' => 'Documents',
    _ => 'Other files',
};

IconData _iconForCategory(String category) => switch (category) {
    'image' => Icons.image_outlined,
    'video' => Icons.video_library_outlined,
    'audio' => Icons.audiotrack_outlined,
    'document' => Icons.description_outlined,
    _ => Icons.insert_drive_file_outlined,
};

String _formatDate(DateTime? value) {
    if (value == null) return 'Unknown date';
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
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
    return '${value.toStringAsFixed(value >= 10 ? 0 : 1)} ${units[unitIndex]}';
}
