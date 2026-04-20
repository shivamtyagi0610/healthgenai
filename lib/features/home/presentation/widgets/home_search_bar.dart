import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8F4), // Very light green/grey matching UI
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: Color(0xFF6B7280),
            size: 22,
          ),
          const SizedBox(width: 12),
          Text(
            'Search medicines or symptoms',
            style: GoogleFonts.inter(
              color: const Color(0xFF6B7280),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
