import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),

      decoration: BoxDecoration(color: Colors.indigo.shade50),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Learn Future Skills',

            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          const SizedBox(
            width: 700,

            child: Text(
              'Join premium workshops on '
              'Flutter, AI, Robotics, '
              'Cybersecurity and more.',

              style: TextStyle(fontSize: 20, height: 1.5),
            ),
          ),

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: () {
              context.go('/workshops');
            },

            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),

              child: Text('Browse Workshops'),
            ),
          ),
        ],
      ),
    );
  }
}
