import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../categories/category_provider.dart';

class CategoriesSection extends ConsumerWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Padding(
      padding: const EdgeInsets.all(24),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Categories',

            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          categoriesAsync.when(
            loading: () {
              return const CircularProgressIndicator();
            },

            error: (error, stackTrace) {
              return Text(error.toString());
            },

            data: (categories) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,

                children: categories.map((category) {
                  return Chip(label: Text(category.name));
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
