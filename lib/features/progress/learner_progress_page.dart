import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/responsive_layout.dart';
import '../dashboard/widgets/dashboard_shell.dart';
import 'progress_provider.dart';
import 'progress_summary_card.dart';
import 'progress_timeline_card.dart';

class LearnerProgressPage extends ConsumerWidget {
  const LearnerProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressProvider);

    final width = MediaQuery.of(context).size.width;

    return DashboardShell(
      title: 'Progress',

      child: progressAsync.when(
        data: (items) {
          return GridView.builder(
            padding: const EdgeInsets.all(24),

            itemCount: items.length,

            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveLayout.gridCount(width),

              crossAxisSpacing: 20,

              mainAxisSpacing: 20,

              mainAxisExtent: 380,
            ),

            itemBuilder: (context, index) {
              final item = items[index];

              return Column(
                children: [
                  Expanded(child: ProgressSummaryCard(progress: item)),

                  const SizedBox(height: 20),

                  ProgressTimelineCard(
                    attended: item.attendedSessions,

                    required: item.requiredSessions,

                    total: item.totalSessions,
                  ),
                ],
              );
            },
          );
        },

        error: (error, _) => Center(child: Text(error.toString())),

        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
