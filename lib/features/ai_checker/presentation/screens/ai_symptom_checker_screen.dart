import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import 'package:healthgenai/features/ai_checker/presentation/providers/symptom_checker_provider.dart';
import 'package:healthgenai/features/ai_checker/data/models/symptom_analysis_model.dart';

class AiSymptomCheckerScreen extends ConsumerStatefulWidget {
  const AiSymptomCheckerScreen({super.key});

  @override
  ConsumerState<AiSymptomCheckerScreen> createState() => _AiSymptomCheckerScreenState();
}

class _AiSymptomCheckerScreenState extends ConsumerState<AiSymptomCheckerScreen> {
  final TextEditingController _symptomController = TextEditingController();

  @override
  void dispose() {
    _symptomController.dispose();
    super.dispose();
  }

  void _onAnalyze() {
    final text = _symptomController.text.trim();
    if (text.isEmpty) return;
    ref.read(symptomCheckerProvider.notifier).analyzeSymptoms(text);
  }

  @override
  Widget build(BuildContext context) {
    final checkerState = ref.watch(symptomCheckerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
              onPressed: () {
                ref.read(symptomCheckerProvider.notifier).reset();
                context.pop();
              },
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Symptom Checker',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Describe what you\'re feeling',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // Large Input Area
            Container(
              height: 180,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.divider.withValues(alpha: 0.6), width: 1.0),
              ),
              child: TextField(
                controller: _symptomController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. I have a sore throat, mild fever and a runny nose since yesterday.',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppColors.textTertiary,
                    height: 1.4,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Analyze Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: checkerState.isLoading ? null : _onAnalyze,
                icon: checkerState.isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.auto_awesome_rounded, size: 20),
                label: Text(
                  checkerState.isLoading ? 'Analyzing...' : 'Analyze with AI',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF5ED18D),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF5ED18D).withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
              ),
            ),

            if (checkerState.result != null) ...[
              const SizedBox(height: 32),
              _PossibleConditionCard(condition: checkerState.result!.condition),
              const SizedBox(height: 20),
              _SuggestedMedicinesCard(medicines: checkerState.result!.medicines),
              const SizedBox(height: 20),
              _PrecautionsCard(precautions: checkerState.result!.precautions),
              const SizedBox(height: 20),
              _DisclaimerFooter(warning: checkerState.result!.warning),
              const SizedBox(height: 40),
            ],

            if (checkerState.error != null) ...[
              const SizedBox(height: 24),
              Text(
                checkerState.error!,
                style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PossibleConditionCard extends StatelessWidget {
  final Condition condition;
  const _PossibleConditionCard({required this.condition});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFFFFF7ED), shape: BoxShape.circle),
                child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFF97316), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Possible condition',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            condition.title,
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            condition.description,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _SuggestedMedicinesCard extends StatelessWidget {
  final List<SuggestedMedicine> medicines;
  const _SuggestedMedicinesCard({required this.medicines});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle),
                child: const Icon(Icons.link_rounded, color: Color(0xFF22C55E), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Suggested medicines',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...medicines.map((SuggestedMedicine m) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.name,
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        m.usage,
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => context.go('/home/medicines'),
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: Text(
              'Browse medicines',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF22C55E),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrecautionsCard extends StatelessWidget {
  final List<String> precautions;
  const _PrecautionsCard({required this.precautions});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle),
                child: const Icon(Icons.verified_user_outlined, color: Color(0xFF22C55E), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Precautions',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...precautions.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    p,
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _DisclaimerFooter extends StatelessWidget {
  final String warning;
  const _DisclaimerFooter({required this.warning});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_rounded, color: Color(0xFFF97316), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              warning,
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
