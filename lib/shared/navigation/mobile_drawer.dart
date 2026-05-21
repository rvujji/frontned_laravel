import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MobileDrawer extends StatelessWidget {
  const MobileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.all(24),

              child: Text(
                'SkillKart',

                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),

            ListTile(
              title: const Text('Home'),

              onTap: () {
                context.go('/');
              },
            ),

            ListTile(
              title: const Text('Workshops'),

              onTap: () {
                context.go('/workshops');
              },
            ),
          ],
        ),
      ),
    );
  }
}
