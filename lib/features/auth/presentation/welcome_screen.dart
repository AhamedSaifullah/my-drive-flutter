import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/brand.dart';

class WelcomeScreen extends StatelessWidget {
    const WelcomeScreen({super.key});

    @override
    Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
            child: Center(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                const Brand(),
                                const SizedBox(height: 54),
                                Container(
                                    height: 220,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                            colors: [Color(0xFF6F61ED), Color(0xFF9E82F1)],
                                        ),
                                        borderRadius: BorderRadius.circular(32),
                                    ),
                                    child: Stack(
                                        children: [
                                            Positioned(
                                                right: 24,
                                                top: 24,
                                                child: Icon(
                                                    Icons.cloud,
                                                    size: 140,
                                                    color: Colors.white.withAlpha(40),
                                                ),
                                            ),
                                            const Padding(
                                                padding: EdgeInsets.fromLTRB(25, 30, 45, 20),
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                        Text(
                                                            'Your files,\none simple space.',
                                                            style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 27,
                                                                height: 1.08,
                                                                fontWeight: FontWeight.w800,
                                                            ),
                                                        ),
                                                        SizedBox(height: 14),
                                                        Text(
                                                            'Connect every cloud.\nFind anything, anywhere.',
                                                            style: TextStyle(
                                                                color: Color(0xFFE9E5FF),
                                                                fontSize: 14,
                                                                height: 1.4,
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                                const SizedBox(height: 30),
                                Text(
                                    'Welcome to My Drive',
                                    style: Theme.of(context).textTheme.headlineMedium
                                            ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                    'A calmer way to manage all your cloud storage from one beautiful app.',
                                ),
                                const SizedBox(height: 28),
                                SizedBox(
                                    width: double.infinity,
                                    child: FilledButton(
                                        onPressed: () => context.push('/register'),
                                        child: const Text('Get started'),
                                    ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                        onPressed: () => context.push('/login'),
                                        child: const Text('I already have an account'),
                                    ),
                                ),
                                const SizedBox(height: 22),
                                const Center(
                                    child: Text(
                                        'Secure by SAIFULLAH  •  Your files stay yours',
                                        style: TextStyle(fontSize: 12, color: Color(0xFF8A92A5)),
                                    ),
                                ),
                            ],
                        ),
                    ),
                ),
            ),
        ),
    );
}
