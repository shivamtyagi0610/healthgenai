import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data for Categories
    final categories = [
      {'name': 'Cold', 'icon': Icons.ac_unit_rounded, 'color': const Color(0xFF63D2A6)},
      {'name': 'Diabetes', 'icon': Icons.water_drop_outlined, 'color': const Color(0xFF63D2A6)},
      {'name': 'Diabetes\nCare', 'icon': Icons.favorite_border_rounded, 'color': const Color(0xFF63D2A6)},
      {'name': 'Fever', 'icon': Icons.thermostat_outlined, 'color': const Color(0xFF63D2A6)},
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Categories',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/home/medicines?category=All'),
              child: Text(
                'See all',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Container(
                width: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF8F2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: GestureDetector(
                  onTap: () {
                    // Pre-encode URL space to avoid issues with "Diabetes Care"
                    final routeCat = (cat['name'] as String).replaceAll('\n', ' ');
                    context.go('/home/medicines?category=$routeCat');
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          cat['icon'] as IconData,
                          color: cat['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat['name'] as String,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
