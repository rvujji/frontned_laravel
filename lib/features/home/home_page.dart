import 'package:flutter/material.dart';

import '../../shared/navigation/app_shell.dart';
import 'widgets/categories_section.dart';
import 'widgets/featured_workshops_section.dart';
import 'widgets/hero_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShell(
      child: SingleChildScrollView(
        child: Column(
          children: [
            HeroSection(),

            FeaturedWorkshopsSection(),

            CategoriesSection(),
          ],
        ),
      ),
    );
  }
}
