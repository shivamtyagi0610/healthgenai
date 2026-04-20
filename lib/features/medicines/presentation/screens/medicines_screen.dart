import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/constants/app_colors.dart';

class MedicinesScreen extends StatefulWidget {
  final String initialCategory;

  const MedicinesScreen({
    super.key,
    required this.initialCategory,
  });

  @override
  State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  late String _selectedCategory;
  String _sortType = 'Name'; // Name -> PriceLow -> PriceHigh
  
  final List<String> _categories = [
    'All',
    'Cold',
    'Diabetes',
    'Diabetes Care',
    'Fever',
  ];

  // Mock Medicine Data
  final List<Map<String, String>> _allMedicines = [
    {
      'name': 'Aspirin 75mg',
      'price': '₹18',
      'image': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60',
      'category': 'Fever',
    },
    {
      'name': 'Cetirizine 10mg',
      'price': '₹35',
      'image': 'https://images.unsplash.com/photo-1576602976047-174e57a47881?w=500&auto=format&fit=crop&q=60',
      'category': 'Cold',
    },
    {
      'name': 'Cough Syrup 100ml',
      'price': '₹95',
      'image': 'https://images.unsplash.com/photo-1607619056574-7b8d3ee536b2?w=500&auto=format&fit=crop&q=60',
      'category': 'Cold',
    },
    {
      'name': 'Diclofenac Gel',
      'price': '₹110',
      'image': 'https://plus.unsplash.com/premium_photo-1678393527940-ba741168f000?w=500&auto=format&fit=crop&q=60',
      'category': 'All',
    },
    {
      'name': 'Glimepiride 2mg',
      'price': '₹85',
      'image': 'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=500&auto=format&fit=crop&q=60',
      'category': 'Diabetes',
    },
    {
      'name': 'Glucometer Strips',
      'price': '₹750',
      'image': 'https://images.unsplash.com/photo-1618498082410-b4aa22193b38?w=500&auto=format&fit=crop&q=60',
      'category': 'Diabetes Care',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Validate if the routed category exists, else default to All
    _selectedCategory = _categories.contains(widget.initialCategory) 
        ? widget.initialCategory 
        : 'All';
  }

  List<Map<String, String>> get _filteredMedicines {
    List<Map<String, String>> list;
    if (_selectedCategory == 'All') {
      list = List.from(_allMedicines);
    } else {
      list = _allMedicines.where((m) => m['category'] == _selectedCategory).toList();
    }

    if (_sortType == 'Name') {
      list.sort((a, b) => a['name']!.toLowerCase().compareTo(b['name']!.toLowerCase()));
    } else if (_sortType == 'PriceLow') {
      list.sort((a, b) {
        final priceA = int.parse(a['price']!.replaceAll('₹', '').replaceAll(',', ''));
        final priceB = int.parse(b['price']!.replaceAll('₹', '').replaceAll(',', ''));
        return priceA.compareTo(priceB);
      });
    } else if (_sortType == 'PriceHigh') {
      list.sort((a, b) {
        final priceA = int.parse(a['price']!.replaceAll('₹', '').replaceAll(',', ''));
        final priceB = int.parse(b['price']!.replaceAll('₹', '').replaceAll(',', ''));
        return priceB.compareTo(priceA);
      });
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final filteredMedicines = _filteredMedicines;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFEDF8F2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        title: Text(
          'Medicines',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8F4), // Clean very light green matching Home
                  borderRadius: BorderRadius.circular(16), // Rounded rectangle like home screen
                ),
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: TextField(
                  style: GoogleFonts.inter(
                    color: const Color(0xFF6B7280),
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF6B7280),
                      size: 22,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    hintText: 'Search medicines',
                    hintStyle: GoogleFonts.inter(
                      color: const Color(0xFF6B7280),
                      fontSize: 15,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    isDense: true,
                    fillColor: Colors.transparent,
                    filled: true,
                  ),
                ),
              ),
            ),

            // Horizontal Categories Scroll
            SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    child: Chip(
                      label: Text(
                        cat,
                        style: GoogleFonts.inter(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      backgroundColor: isSelected ? AppColors.primary : const Color(0xFFE2F5E9), // Selected solid green otherwise light tint
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Results count and sort row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filteredMedicines.length} results',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  // Single Cycling Sort Button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_sortType == 'Name') {
                          _sortType = 'PriceLow';
                        } else if (_sortType == 'PriceLow') {
                          _sortType = 'PriceHigh';
                        } else {
                          _sortType = 'Name';
                        }
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.swap_vert_rounded, size: 18, color: Color(0xFF2EAA58)),
                        const SizedBox(width: 6),
                        Text(
                          _sortType == 'Name' ? 'Name' : 'Price',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2EAA58),
                          ),
                        ),
                        if (_sortType != 'Name') ...[
                          const SizedBox(width: 4),
                          Icon(
                            _sortType == 'PriceLow' 
                                ? Icons.arrow_downward_rounded 
                                : Icons.arrow_upward_rounded,
                            size: 16,
                            color: const Color(0xFF2EAA58),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Medicine Grid View
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: filteredMedicines.length,
                itemBuilder: (context, index) {
                  final med = filteredMedicines[index];
                  return GestureDetector(
                    onTap: () {
                      context.push('/home/medicines/details', extra: med);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.divider, width: 0.8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Image Wrapper
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                              child: CachedNetworkImage(
                                imageUrl: med['image']!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: AppColors.surfaceVariant,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 24, height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => const Icon(Icons.error_outline),
                              ),
                            ),
                          ),
                          // Product Details
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  med['name']!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  med['price']!,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }
}
