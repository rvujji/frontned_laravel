import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(24),

      color: Colors.grey.shade200,

      child: const Center(child: Text('© 2026 SkillGarage')),
    );
  }
}
