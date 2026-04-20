class SymptomAnalysis {
  final Condition condition;
  final List<SuggestedMedicine> medicines;
  final List<String> precautions;
  final String warning;

  SymptomAnalysis({
    required this.condition,
    required this.medicines,
    required this.precautions,
    required this.warning,
  });

  factory SymptomAnalysis.fromJson(Map<String, dynamic> json) {
    return SymptomAnalysis(
      condition: Condition.fromJson(json['condition']),
      medicines: (json['medicines'] as List)
          .map((m) => SuggestedMedicine.fromJson(m))
          .toList(),
      precautions: List<String>.from(json['precautions']),
      warning: json['warning'],
    );
  }
}

class Condition {
  final String title;
  final String description;

  Condition({required this.title, required this.description});

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      title: json['title'],
      description: json['description'],
    );
  }
}

class SuggestedMedicine {
  final String name;
  final String usage;

  SuggestedMedicine({required this.name, required this.usage});

  factory SuggestedMedicine.fromJson(Map<String, dynamic> json) {
    return SuggestedMedicine(
      name: json['name'],
      usage: json['usage'],
    );
  }
}
