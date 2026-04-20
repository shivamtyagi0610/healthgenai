import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/ai_promo_banner.dart';
import '../widgets/categories_section.dart';
import '../widgets/featured_medicines_section.dart';
import '../widgets/home_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/quick_actions_row.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              HomeHeader(),
              SizedBox(height: 24),
              HomeSearchBar(),
              SizedBox(height: 24),
              AIPromoBanner(),
              SizedBox(height: 32),
              CategoriesSection(),
              SizedBox(height: 32),
              QuickActionsRow(),
              SizedBox(height: 32),
              FeaturedMedicinesSection(),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

