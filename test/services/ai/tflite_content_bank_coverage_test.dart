import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_garden_ai/features/recommendation/data/datasources/recommendation_local_datasource.dart';
import 'package:smart_garden_ai/services/ai/ai_service.dart';
import 'package:smart_garden_ai/services/ai/tflite_diagnosis_content_bank.dart';
import 'package:smart_garden_ai/services/ai/tflite_label_parser.dart';

/// Exhaustiveness check: every one of the real model's 71 raw class labels
/// (assets/models/labels.txt) must resolve, after parsing/canonicalization,
/// to a real entry in *both* content banks — never a silent fallback. This
/// is what actually verifies the large hand-written content-bank work in
/// tflite_diagnosis_content_bank.dart and the Phase 18 additions to
/// recommendation_local_datasource.dart didn't miss a label.
void main() {
  final labelsFile = File('assets/models/labels.txt');
  final rawLabels = labelsFile
      .readAsLinesSync()
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

  test('labels.txt has the expected 71 entries', () {
    expect(rawLabels, hasLength(71));
  });

  test('every raw label canonicalizes to a key in tfliteDiagnosisContentBank',
      () {
    for (final rawLabel in rawLabels) {
      final parsed = TFLiteLabelParser.parse(rawLabel);
      final canonical = TFLiteLabelParser.canonicalDiseaseType(
        parsed.diseaseRaw,
      );
      expect(
        tfliteDiagnosisContentBank.containsKey(canonical),
        isTrue,
        reason: '"$rawLabel" → canonical "$canonical" has no content-bank '
            'entry',
      );
    }
  });

  test('every canonical disease type has real Recommendation content '
      '(not the generic fallback)', () {
    const recommendationDataSource = RecommendationLocalDataSource();
    // The exact fallback text from recommendation_local_datasource.dart —
    // used only to detect an unmatched key falling through to it.
    const fallbackFirstStep =
        "We don't have specific guidance for this diagnosis yet.";

    final canonicalLabels = rawLabels
        .map((raw) => TFLiteLabelParser.parse(raw))
        .map(
          (parsed) => TFLiteLabelParser.canonicalDiseaseType(
            parsed.diseaseRaw,
          ),
        )
        .toSet();

    for (final label in canonicalLabels) {
      final recommendation = recommendationDataSource.getRecommendation(
        label,
        DiagnosisSeverity.moderate,
      );
      expect(
        recommendation.treatmentSteps.first,
        isNot(fallbackFirstStep),
        reason: '"$label" has no dedicated Recommendation entry — it fell '
            'through to the generic fallback.',
      );
    }
  });
}
