import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/cloud/data/cloud_repository.dart';
import '../../../features/cloud/data/models/cloud_models.dart';
import '../../../features/cloud/presentation/cloud_controller.dart';
import '../app_page.dart';
import '../info_banner.dart';

class AccountsPage extends ConsumerWidget {
    const AccountsPage({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        ref.listen<AsyncValue<void>>(cloudControllerProvider, (previous, next) {
            if (previous?.isLoading != true) return;
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        next.hasError
                                ? next.error.toString()
                                : 'Cloud account updated successfully.',
                    ),
                    backgroundColor: next.hasError ? Colors.red : Colors.green,
                ),
            );
        });

        final accountsState = ref.watch(cloudAccountsProvider);
        return AppPage(
            title: 'Your cloud accounts',
            subtitle: 'Connect accounts to see all your files together.',
            child: accountsState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => _AccountsError(
                    message: error.toString(),
                    onRetry: () => ref.invalidate(cloudAccountsProvider),
                ),
                data: (accounts) => _AccountsList(
                    accounts: accounts,
                    isBusy: ref.watch(cloudControllerProvider).isLoading,
                    onLinkGoogle: () =>
                            ref.read(cloudControllerProvider.notifier).linkGoogle(),
                    onUnlink: (account) => _confirmUnlink(context, ref, account),
                ),
            ),
        );
    }

    Future<void> _confirmUnlink(
        BuildContext context,
        WidgetRef ref,
        CloudAccount account,
    ) async {
        final confirmed = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
                title: const Text('Unlink Google Drive?'),
                content: Text(
                    'Remove ${account.email} from My Drive? Its synced file metadata will also be removed.',
                ),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Cancel'),
                    ),
                    FilledButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        style: FilledButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Unlink'),
                    ),
                ],
            ),
        );
        if (confirmed != true || !context.mounted) return;
        await ref.read(cloudControllerProvider.notifier).unlinkAccount(account);
    }
}

class _AccountsList extends StatelessWidget {
    const _AccountsList({
        required this.accounts,
        required this.isBusy,
        required this.onLinkGoogle,
        required this.onUnlink,
    });

    final List<CloudAccount> accounts;
    final bool isBusy;
    final VoidCallback onLinkGoogle;
    final ValueChanged<CloudAccount> onUnlink;

    @override
    Widget build(BuildContext context) {
        final activeCount = accounts.where((account) => account.isActive).length;
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Text(
                            'Connected accounts',
                            style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                            '$activeCount of 1',
                            style: const TextStyle(
                                color: Color(0xFF6758E8),
                                fontWeight: FontWeight.w700,
                            ),
                        ),
                    ],
                ),
                const SizedBox(height: 14),
                if (accounts.isEmpty)
                    _EmptyAccounts(onLinkGoogle: onLinkGoogle, isBusy: isBusy)
                else
                    ...accounts.map(
                        (account) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _CloudAccountCard(
                                account: account,
                                isBusy: isBusy,
                                onUnlink: () => onUnlink(account),
                            ),
                        ),
                    ),
                if (accounts.isNotEmpty &&
                        accounts.every((account) => !account.isActive))
                    _EmptyAccounts(onLinkGoogle: onLinkGoogle, isBusy: isBusy),
                const SizedBox(height: 12),
                const InfoBanner(),
            ],
        );
    }
}

class _CloudAccountCard extends StatelessWidget {
    const _CloudAccountCard({
        required this.account,
        required this.isBusy,
        required this.onUnlink,
    });

    final CloudAccount account;
    final bool isBusy;
    final VoidCallback onUnlink;

    @override
    Widget build(BuildContext context) {
        final statusColor = account.isActive
                ? const Color(0xFF38B27A)
                : Colors.orange;
        return Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFDAD6FF)),
            ),
            child: Row(
                children: [
                    const CircleAvatar(
                        radius: 23,
                        backgroundColor: Color(0x184285F4),
                        child: Text(
                            'G',
                            style: TextStyle(
                                color: Color(0xFF4285F4),
                                fontWeight: FontWeight.w800,
                                fontSize: 19,
                            ),
                        ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text(
                                    account.displayName.isEmpty
                                            ? 'Google Drive'
                                            : account.displayName,
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 3),
                                Text(account.email, style: const TextStyle(fontSize: 12)),
                                const SizedBox(height: 6),
                                Chip(
                                    label: Text(_statusLabel(account.status)),
                                    labelStyle: TextStyle(
                                        color: statusColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                    ),
                                    backgroundColor: statusColor.withAlpha(24),
                                    side: BorderSide.none,
                                    visualDensity: VisualDensity.compact,
                                ),
                            ],
                        ),
                    ),
                    if (account.status != 'unlinked')
                        TextButton(
                            onPressed: isBusy ? null : onUnlink,
                            child: const Text('Unlink'),
                        ),
                ],
            ),
        );
    }

    String _statusLabel(String status) => switch (status) {
        'active' => 'Active',
        'needs_reauth' => 'Needs reauthorization',
        'unlinked' => 'Unlinked',
        'revoked' => 'Revoked',
        _ => status,
    };
}

class _EmptyAccounts extends StatelessWidget {
    const _EmptyAccounts({required this.onLinkGoogle, required this.isBusy});

    final VoidCallback onLinkGoogle;
    final bool isBusy;

    @override
    Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: const Color(0xFFEDEBFF),
            borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                const Text(
                    'No cloud accounts linked yet.',
                    style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text('Link Google Drive to start accessing your files.'),
                const SizedBox(height: 14),
                FilledButton.icon(
                    onPressed: isBusy ? null : onLinkGoogle,
                    icon: const Icon(Icons.add_link),
                    label: const Text('Link Google Drive'),
                ),
            ],
        ),
    );
}

class _AccountsError extends StatelessWidget {
    const _AccountsError({required this.message, required this.onRetry});

    final String message;
    final VoidCallback onRetry;

    @override
    Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(message, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
    );
}
