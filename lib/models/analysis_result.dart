class CategoryScore {
  final String name;
  final int score;
  final int max;

  CategoryScore({required this.name, required this.score, required this.max});

  factory CategoryScore.fromJson(Map<String, dynamic> json) => CategoryScore(
    name: json['name'] as String,
    score: json['score'] as int,
    max: json['max'] as int,
  );
}

class AnalysisResult {
  final int resumeId;
  final String fileName;
  final int overallScore;
  final List<CategoryScore> categories;
  final List<String> strengths;
  final List<String> suggestions;
  final List<String> missingKeywords;

  AnalysisResult({
    required this.resumeId,
    required this.fileName,
    required this.overallScore,
    required this.categories,
    required this.strengths,
    required this.suggestions,
    required this.missingKeywords,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) => AnalysisResult(
    resumeId: json['resumeId'] as int,
    fileName: json['fileName'] as String,
    overallScore: json['overallScore'] as int,
    categories: (json['categories'] as List)
        .map((c) => CategoryScore.fromJson(c as Map<String, dynamic>))
        .toList(),
    strengths: List<String>.from(json['strengths'] as List),
    suggestions: List<String>.from(json['suggestions'] as List),
    missingKeywords: List<String>.from(json['missingKeywords'] as List),
  );
}