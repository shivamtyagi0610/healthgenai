import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/constants/app_colors.dart';

final aiTipsProvider = StateNotifierProvider<AITipsNotifier, AsyncValue<String>>((ref) {
  return AITipsNotifier();
});

class AITipsNotifier extends StateNotifier<AsyncValue<String>> {
  AITipsNotifier() : super(const AsyncValue.loading()) {
    getDailyTip();
  }

  Future<void> getDailyTip() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdate = prefs.getString('last_tip_date');
      final today = DateTime.now().toIso8601String().substring(0, 10);

      if (lastUpdate == today) {
        final savedTip = prefs.getString('daily_health_tip');
        if (savedTip != null) {
          state = AsyncValue.data(savedTip);
          return;
        }
      }

      // Fetch new tip from Gemini
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null) throw Exception('API Key missing');

      final model = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: apiKey);
      final response = await model.generateContent([
        Content.text(
          "Generate one unique, practical, and punchy health tip for today. "
          "Keep it under 30 words. Focus on wellness, nutrition, or mental health. "
          "Make it sound professional yet encouraging. Do not use hashtags."
        )
      ]);

      final tip = response.text ?? "Stay hydrated and keep moving for a healthy day!";
      
      await prefs.setString('daily_health_tip', tip);
      await prefs.setString('last_tip_date', today);
      
      state = AsyncValue.data(tip);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

class AIHealthTipsScreen extends ConsumerWidget {
  const AIHealthTipsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipAsync = ref.watch(aiTipsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Daily AI Tip',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildIllustration(),
            const SizedBox(height: 48),
            tipAsync.when(
              data: (tip) => _buildTipContent(context, tip),
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF3BBD70))),
              error: (err, _) => _buildErrorState(ref),
            ),
            const Spacer(),
            _buildFooter(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8F4),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome_rounded, size: 80, color: Color(0xFF3BBD70)),
            const SizedBox(height: 16),
            Text(
              'Your Health, Simplified.',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF065F46),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipContent(BuildContext context, String tip) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lightbulb_outline_rounded, color: Colors.orangeAccent, size: 20),
            const SizedBox(width: 8),
            Text(
              "TODAY'S INSIGHT",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.orangeAccent,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          tip,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            'Refreshes in 24 hours',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(WidgetRef ref) {
    return Column(
      children: [
         const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
         const SizedBox(height: 16),
         Text(
           'Failed to fetch tip',
           style: GoogleFonts.inter(fontWeight: FontWeight.w700),
         ),
         TextButton(
           onPressed: () => ref.read(aiTipsProvider.notifier).getDailyTip(),
           child: const Text('Try Again', style: TextStyle(color: Color(0xFF3BBD70))),
         ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF6B7280), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'These tips are AI-generated for wellness awareness and do not constitute formal medical advice.',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
