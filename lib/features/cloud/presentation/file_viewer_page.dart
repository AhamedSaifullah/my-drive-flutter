import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../../core/config/env.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';
import '../data/models/file_models.dart';

class FileViewerPage extends StatelessWidget {
    const FileViewerPage({super.key, required this.file});

    final CloudFile file;

    @override
    Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(file.name, overflow: TextOverflow.ellipsis)),
        body: switch (file.category) {
            'image' => _ImageViewer(file: file),
            'video' => _MediaViewer(file: file, isAudio: false),
            'audio' => _MediaViewer(file: file, isAudio: true),
            _ => _DocumentViewer(file: file),
        },
    );
}

class _ImageViewer extends ConsumerWidget {
    const _ImageViewer({required this.file});

    final CloudFile file;

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final token = ref.watch(_accessTokenProvider);
        return token.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) =>
                    _ViewerError(onRetry: () => ref.invalidate(_accessTokenProvider)),
            data: (value) => value == null
                    ? _ViewerError(onRetry: () => ref.invalidate(_accessTokenProvider))
                    : Center(
                            child: InteractiveViewer(
                                child: Image.network(
                                    _contentUrl(file),
                                    headers: {'Authorization': 'Bearer $value'},
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => _ViewerError(
                                        onRetry: () => Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                                builder: (_) => FileViewerPage(file: file),
                                            ),
                                        ),
                                    ),
                                ),
                            ),
                        ),
        );
    }
}

class _MediaViewer extends ConsumerStatefulWidget {
    const _MediaViewer({required this.file, required this.isAudio});

    final CloudFile file;
    final bool isAudio;

    @override
    ConsumerState<_MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends ConsumerState<_MediaViewer> {
    VideoPlayerController? _controller;
    Object? _error;

    @override
    void initState() {
        super.initState();
        _initialize();
    }

    Future<void> _initialize() async {
        final token = await ref.read(_accessTokenProvider.future);
        if (token == null) {
            if (mounted) setState(() => _error = 'Authentication token unavailable');
            return;
        }
        final controller = VideoPlayerController.networkUrl(
            Uri.parse(_contentUrl(widget.file)),
            httpHeaders: {'Authorization': 'Bearer $token'},
        );
        try {
            await controller.initialize();
            if (!mounted) {
                await controller.dispose();
                return;
            }
            setState(() => _controller = controller);
        } catch (error) {
            await controller.dispose();
            if (mounted) setState(() => _error = error);
        }
    }

    @override
    void dispose() {
        _controller?.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        final controller = _controller;
        if (_error != null) return _ViewerError(onRetry: _retry);
        if (controller == null || !controller.value.isInitialized) {
            return const Center(child: CircularProgressIndicator());
        }
        return Center(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    if (!widget.isAudio)
                        AspectRatio(
                            aspectRatio: controller.value.aspectRatio,
                            child: VideoPlayer(controller),
                        )
                    else
                        const Icon(Icons.audiotrack, size: 96, color: Color(0xFF6758E8)),
                    const SizedBox(height: 24),
                    ValueListenableBuilder<VideoPlayerValue>(
                        valueListenable: controller,
                        builder: (context, value, child) => Column(
                            children: [
                                IconButton.filled(
                                    iconSize: 30,
                                    onPressed: () =>
                                            value.isPlaying ? controller.pause() : controller.play(),
                                    icon: Icon(value.isPlaying ? Icons.pause : Icons.play_arrow),
                                ),
                                SizedBox(
                                    width: MediaQuery.sizeOf(context).width - 32,
                                    child: VideoProgressIndicator(
                                        controller,
                                        allowScrubbing: true,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                ),
                            ],
                        ),
                    ),
                ],
            ),
        );
    }

    void _retry() {
        _controller?.dispose();
        setState(() {
            _controller = null;
            _error = null;
        });
        _initialize();
    }
}

class _DocumentViewer extends ConsumerStatefulWidget {
    const _DocumentViewer({required this.file});

    final CloudFile file;

    @override
    ConsumerState<_DocumentViewer> createState() => _DocumentViewerState();
}

class _DocumentViewerState extends ConsumerState<_DocumentViewer> {
    bool _loading = false;
    Object? _error;

    Future<void> _openDocument() async {
        setState(() {
            _loading = true;
            _error = null;
        });
        try {
            final directory = await getTemporaryDirectory();
            final path = '${directory.path}/${widget.file.id}-${widget.file.name}';
            await ref.read(dioProvider).download(_contentUrl(widget.file), path);
            await OpenFilex.open(path);
            if (mounted) setState(() => _loading = false);
        } catch (error) {
            if (mounted) {
                setState(() {
                    _loading = false;
                    _error = error;
                });
            }
        }
    }

    @override
    Widget build(BuildContext context) => Center(
        child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    const Icon(
                        Icons.description_outlined,
                        size: 72,
                        color: Color(0xFF6758E8),
                    ),
                    const SizedBox(height: 16),
                    const Text('Open this document with an installed viewer.'),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                        onPressed: _loading ? null : _openDocument,
                        icon: _loading
                                ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                : const Icon(Icons.open_in_new),
                        label: Text(_loading ? 'Preparing...' : 'Open document'),
                    ),
                    if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                            'Could not open the document.',
                            style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                    ],
                ],
            ),
        ),
    );
}

class _ViewerError extends StatelessWidget {
    const _ViewerError({this.onRetry});

    final VoidCallback? onRetry;

    @override
    Widget build(BuildContext context) => Center(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                const Text('This file could not be opened.'),
                if (onRetry != null)
                    TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
        ),
    );
}

final _accessTokenProvider = FutureProvider<String?>((ref) {
    return const TokenStorage().access;
});

String _contentUrl(CloudFile file) =>
        '${Env.apiBaseUrl}files/${file.id}/content';
