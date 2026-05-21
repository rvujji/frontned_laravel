import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  const AppScaffold({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),

          child: child,
        ),
      ),
    );
  }
}
