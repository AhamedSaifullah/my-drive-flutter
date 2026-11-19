import 'package:flutter/material.dart';

class QuickTile extends StatelessWidget {
    const QuickTile({
        super.key,
        required this.icon,
        required this.title,
        required this.count,
        required this.color,
        this.onTap,
    });
    final IconData icon;
    final String title;
    final String count;
    final Color color;
    final VoidCallback? onTap;

    @override
    Widget build(BuildContext context) => Expanded(
        child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        CircleAvatar(
                            radius: 20,
                            backgroundColor: color,
                            child: Icon(icon, color: const Color(0xFF4D566B)),
                        ),
                        const SizedBox(height: 14),
                        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        Text(count, style: const TextStyle(fontSize: 12)),
                    ],
                ),
            ),
        ),
    );
}
