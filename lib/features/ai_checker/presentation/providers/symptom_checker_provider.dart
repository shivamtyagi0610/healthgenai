import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:healthgenai/features/ai_checker/data/models/symptom_analysis_model.dart';
import 'dart:developer' as dev;

class SymptomCheckerState {
  final bool isLoading;
  final SymptomAnalysis? result;
  final String? error;

  SymptomCheckerState({this.isLoading = false, this.result, this.error});
}

final symptomCheckerProvider = NotifierProvider<SymptomCheckerNotifier, SymptomCheckerState>(SymptomCheckerNotifier.new);

class SymptomCheckerNotifier extends Notifier<SymptomCheckerState> {
  late final GenerativeModel _model;

  @override
  SymptomCheckerState build() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(
      model: 'gemini-flash-latest',
      apiKey: apiKey,
    );
    return SymptomCheckerState();
  }

  Future<void> analyzeSymptoms(String symptoms) async {
    state = SymptomCheckerState(isLoading: true);

    final prompt = """
Analyze the following symptoms and provide a structured health assessment.
Response MUST be in valid JSON format ONLY. 
Respond in the language the user used (Hindi/Hinglish/English).
If the symptoms are vague, provide the most likely mild condition.

Symptoms: "$symptoms"

JSON Format:
{
  "condition": {
    "title": "Condition name (e.g. Common Cold)",
    "description": "Short explanation in the user's language"
  },
  "medicines": [
    {
      "name": "Medicine name (Brand/Generic)",
      "usage": "Why/how to use"
    }
  ],
  "precautions": ["Precaution 1", "Precaution 2"],
  "warning": "Brief AI disclaimer in the user's language"
}
""";

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;
      
      if (text == null) throw Exception("Empty response from AI");

      // Clean the response (sometimes Gemini adds ```json ... ```)
      final cleanJson = text.replaceAll('```json', '').replaceAll('```', '').trim();
      final data = jsonDecode(cleanJson);
      
      state = SymptomCheckerState(
        isLoading: false,
        result: SymptomAnalysis.fromJson(data),
      );
    } catch (e) {
      dev.log("Symptom Checker Error: $e");
      state = SymptomCheckerState(
        isLoading: false,
        error: "Failed to analyze symptoms. Please try again.",
      );
    }
  }

  void reset() {
    state = SymptomCheckerState();
  }
}
