import 'package:flutter/material.dart';

import '../account_card.dart';
import '../app_page.dart';
import '../info_banner.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key, required this.connected});
  final Set<String> connected;

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  static const providers = [
    CloudProvider('Google Drive', 'alex@example.com', 'G', Color(0xFF4285F4)),
    CloudProvider('Dropbox', 'Connect your Dropbox', 'D', Color(0xFF1677FF)),
    CloudProvider('JioCloud', 'Connect your JioCloud', 'J', Color(0xFFEF4C56)),
  ];

  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Your cloud accounts',
    subtitle: 'Connect accounts to see all your files together.',
    child: Column(
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
              '${widget.connected.length} of 3',
              style: const TextStyle(
                color: Color(0xFF6758E8),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...providers.map(
          (provider) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AccountCard(
              provider: provider,
              connected: widget.connected.contains(provider.name),
              onTap: () => _toggle(provider),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const InfoBanner(),
      ],
    ),
  );

  void _toggle(CloudProvider provider) {
    setState(() {
      widget.connected.contains(provider.name)
          ? widget.connected.remove(provider.name)
          : widget.connected.add(provider.name);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.connected.contains(provider.name)
              ? '${provider.name} connected'
              : '${provider.name} disconnected',
        ),
      ),
    );
  }
}
