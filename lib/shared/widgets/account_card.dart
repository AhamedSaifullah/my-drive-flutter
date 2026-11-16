import 'package:flutter/material.dart';

class CloudProvider {
  const CloudProvider(this.name, this.detail, this.letter, this.color);
  final String name;
  final String detail;
  final String letter;
  final Color color;
}

class AccountCard extends StatelessWidget {
  const AccountCard({
    super.key,
    required this.provider,
    required this.connected,
    required this.onTap,
  });
  final CloudProvider provider;
  final bool connected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: connected ? const Color(0xFFDAD6FF) : const Color(0xFFE9EBF2),
      ),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 23,
          backgroundColor: provider.color.withAlpha(24),
          child: Text(
            provider.letter,
            style: TextStyle(
              color: provider.color,
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
                provider.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 3),
              Text(
                connected ? provider.detail : 'Not connected',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        connected
            ? const Icon(Icons.check_circle, color: Color(0xFF38B27A))
            : TextButton(onPressed: onTap, child: const Text('Connect')),
      ],
    ),
  );
}
