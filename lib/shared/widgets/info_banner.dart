import 'package:flutter/material.dart';

class InfoBanner extends StatelessWidget {
  const InfoBanner({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: const Color(0xFFEDEBFF),
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lock_outline, size: 18, color: Color(0xFF6758E8)),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Your files stay with their original cloud provider. My Drive only helps you access them in one place.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF514B89),
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}
