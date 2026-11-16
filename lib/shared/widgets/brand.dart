import 'package:flutter/material.dart';

class Brand extends StatelessWidget {
  const Brand({super.key});

  @override
  Widget build(BuildContext context) => const Row(
    children: [
      CircleAvatar(
        radius: 17,
        backgroundColor: Color(0xFFEAE7FF),
        child: Icon(Icons.cloud_done, color: Color(0xFF6758E8), size: 20),
      ),
      SizedBox(width: 10),
      Text(
        'my drive',
        style: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w800,
          color: Color(0xFF172033),
        ),
      ),
    ],
  );
}
