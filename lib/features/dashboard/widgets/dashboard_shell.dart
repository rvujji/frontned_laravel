import 'package:flutter/material.dart';

import 'dashboard_sidebar.dart';
import 'dashboard_topbar.dart';

class DashboardShell extends StatelessWidget {
  final Widget child;

  const DashboardShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      drawer: isMobile ? const Drawer(child: DashboardSidebar()) : null,

      body: Row(
        children: [
          if (!isMobile) const SizedBox(width: 260, child: DashboardSidebar()),

          Expanded(
            child: Column(
              children: [
                const DashboardTopbar(),

                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
