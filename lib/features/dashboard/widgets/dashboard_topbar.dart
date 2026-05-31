import 'package:flutter/material.dart';

import '../../../shared/responsive_layout.dart';

class DashboardTopbar extends StatelessWidget {
  final String? title;

  final List<Widget>? actions;

  const DashboardTopbar({super.key, this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isMobile = ResponsiveLayout.isMobile(width);

    return Container(
      height: 72,

      padding: const EdgeInsets.symmetric(horizontal: 24),

      decoration: BoxDecoration(
        color: Colors.white,

        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),

      child: Row(
        children: [
          if (isMobile)
            Builder(
              builder: (context) {
                return IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },

                  icon: const Icon(Icons.menu),
                );
              },
            ),

          if (title != null)
            Expanded(
              child: Text(
                title!,

                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            const Spacer(),

          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
