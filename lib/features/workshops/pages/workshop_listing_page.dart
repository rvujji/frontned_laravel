import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/empty_state.dart';
import '../../../shared/error_state.dart';
import '../../../shared/navigation/app_shell.dart';
import '../../../shared/responsive_layout.dart';
import '../../categories/category_provider.dart';
import '../widgets/workshop_card.dart';
import '../workshop_provider.dart';
import '../workshop_skeleton.dart';

class WorkshopListingPage extends ConsumerStatefulWidget {
  const WorkshopListingPage({super.key});

  @override
  ConsumerState<WorkshopListingPage> createState() =>
      _WorkshopListingPageState();
}

class _WorkshopListingPageState extends ConsumerState<WorkshopListingPage> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();

    _debounce?.cancel();

    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(searchProvider.notifier).state = value;

      ref.read(currentPageProvider.notifier).state = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final workshopsAsync = ref.watch(workshopsProvider);

    final categoriesAsync = ref.watch(categoriesProvider);

    final selectedCategory = ref.watch(selectedCategoryProvider);

    return AppShell(
      child: workshopsAsync.when(
        loading: () {
          return GridView.builder(
            padding: const EdgeInsets.all(16),

            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,

              crossAxisSpacing: 16,
              mainAxisSpacing: 16,

              childAspectRatio: 1.1,
            ),

            itemCount: 8,

            itemBuilder: (context, index) {
              return const WorkshopSkeleton();
            },
          );
        },

        error: (error, stackTrace) {
          return ErrorState(
            message: error.toString(),

            onRetry: () {
              ref.invalidate(workshopsProvider);
            },
          );
        },

        data: (pagination) {
          final workshops = pagination.workshops;

          if (workshops.isEmpty) {
            return const EmptyState(
              title: 'No Workshops Found',

              message: 'Try changing your search or category filters.',
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),

                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,

                  crossAxisAlignment: WrapCrossAlignment.center,

                  children: [
                    SizedBox(
                      width: 400,

                      child: TextField(
                        controller: _searchController,

                        decoration: const InputDecoration(
                          hintText: 'Search workshops',

                          prefixIcon: Icon(Icons.search),

                          border: OutlineInputBorder(),
                        ),

                        onChanged: _onSearchChanged,
                      ),
                    ),

                    categoriesAsync.when(
                      loading: () {
                        return const SizedBox(
                          width: 24,
                          height: 24,

                          child: CircularProgressIndicator(),
                        );
                      },

                      error: (_, __) {
                        return const SizedBox();
                      },

                      data: (categories) {
                        return DropdownButton<int?>(
                          value: selectedCategory,

                          hint: const Text('Category'),

                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,

                              child: Text('All'),
                            ),

                            ...categories.map((category) {
                              return DropdownMenuItem<int?>(
                                value: category.id,

                                child: Text(category.name),
                              );
                            }),
                          ],

                          onChanged: (value) {
                            ref.read(selectedCategoryProvider.notifier).state =
                                value;

                            ref.read(currentPageProvider.notifier).state = 1;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;

                    final crossAxisCount = ResponsiveLayout.gridCount(width);

                    return Column(
                      children: [
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),

                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,

                                  crossAxisSpacing: 16,

                                  mainAxisSpacing: 16,

                                  childAspectRatio: 1.1,
                                ),

                            itemCount: workshops.length,

                            itemBuilder: (context, index) {
                              return WorkshopCard(workshop: workshops[index]);
                            },
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(16),

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              ElevatedButton(
                                onPressed: pagination.currentPage > 1
                                    ? () {
                                        ref
                                            .read(currentPageProvider.notifier)
                                            .state--;
                                      }
                                    : null,

                                child: const Text('Prev'),
                              ),

                              const SizedBox(width: 24),

                              Text(
                                'Page '
                                '${pagination.currentPage} '
                                'of '
                                '${pagination.lastPage}',
                              ),

                              const SizedBox(width: 24),

                              ElevatedButton(
                                onPressed:
                                    pagination.currentPage < pagination.lastPage
                                    ? () {
                                        ref
                                            .read(currentPageProvider.notifier)
                                            .state++;
                                      }
                                    : null,

                                child: const Text('Next'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
