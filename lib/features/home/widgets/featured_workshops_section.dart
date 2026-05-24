import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/responsive_layout.dart';
import '../../workshops/widgets/compact_workshop_card.dart';
import '../../workshops/workshop_provider.dart';

class FeaturedWorkshopsSection extends ConsumerWidget {
  const FeaturedWorkshopsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workshopsAsync = ref.watch(workshopsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Featured Workshops',

            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          workshopsAsync.when(
            loading: () {
              return const Center(child: CircularProgressIndicator());
            },

            error: (error, stackTrace) {
              return Text(error.toString());
            },

            data: (pagination) {
              final workshops = pagination.workshops.take(4).toList();

              return LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  final crossAxisCount = ResponsiveLayout.gridCount(width);

                  return GridView.builder(
                    shrinkWrap: true,

                    physics: const NeverScrollableScrollPhysics(),

                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,

                      crossAxisSpacing: 16,

                      mainAxisSpacing: 16,

                      mainAxisExtent: 340,
                    ),

                    itemCount: workshops.length,

                    itemBuilder: (context, index) {
                      return CompactWorkshopCard(workshop: workshops[index]);
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
