import 'package:flutter_test/flutter_test.dart';
import 'package:smart_garden_ai/services/ai/tflite_label_parser.dart';

void main() {
  group('TFLiteLabelParser.parse', () {
    test('splits a simple "Disease (Species)" label', () {
      final result = TFLiteLabelParser.parse('Anthracnose (Mango)');
      expect(result.diseaseRaw, 'Anthracnose');
      expect(result.species, 'Mango');
    });

    test('handles a species that itself contains parentheses', () {
      // "Corn (maize)" as species must not be split at its own inner
      // parens — the whole "(Corn (maize))" trailing group is the species.
      final result = TFLiteLabelParser.parse(
        'Common rust (Corn (maize))',
      );
      expect(result.diseaseRaw, 'Common rust');
      expect(result.species, 'Corn (maize)');
    });

    test('handles a disease name that itself contains parentheses', () {
      // "Esca (Black Measles)" is the full disease name; "(Grape)" is a
      // separate trailing species group, not nested inside the first.
      final result = TFLiteLabelParser.parse('Esca (Black Measles) (Grape)');
      expect(result.diseaseRaw, 'Esca (Black Measles)');
      expect(result.species, 'Grape');
    });

    test('handles a species with a comma', () {
      final result = TFLiteLabelParser.parse('Bacterial spot (Pepper, bell)');
      expect(result.diseaseRaw, 'Bacterial spot');
      expect(result.species, 'Pepper, bell');
    });

    test('Unknown Disease has no species', () {
      final result = TFLiteLabelParser.parse('Unknown Disease');
      expect(result.diseaseRaw, 'Unknown Disease');
      expect(result.species, isNull);
    });
  });

  group('TFLiteLabelParser.canonicalDiseaseType', () {
    test('collapses case/spacing variants of the same disease', () {
      expect(
        TFLiteLabelParser.canonicalDiseaseType('Black rot'),
        TFLiteLabelParser.canonicalDiseaseType('Black Rot'),
      );
      expect(
        TFLiteLabelParser.canonicalDiseaseType('Powdery mildew'),
        TFLiteLabelParser.canonicalDiseaseType('Powdery Mildew'),
      );
      expect(
        TFLiteLabelParser.canonicalDiseaseType('Target spot'),
        TFLiteLabelParser.canonicalDiseaseType('Target Spot'),
      );
    });

    test('does NOT merge distinct diseases with similar names', () {
      // These are genuinely different diseases in the dataset and must
      // stay separate content-bank keys.
      expect(
        TFLiteLabelParser.canonicalDiseaseType('Mosaic'),
        isNot(TFLiteLabelParser.canonicalDiseaseType('Mosaic Disease')),
      );
      expect(
        TFLiteLabelParser.canonicalDiseaseType('Black Rot'),
        isNot(TFLiteLabelParser.canonicalDiseaseType('Black Spot')),
      );
      expect(
        TFLiteLabelParser.canonicalDiseaseType('Bacterial Blight'),
        isNot(TFLiteLabelParser.canonicalDiseaseType('BacterialBlights')),
      );
    });

    test('collapses every "healthy*" variant to the shared canonical label',
        () {
      expect(
        TFLiteLabelParser.canonicalDiseaseType('healthy'),
        TFLiteLabelParser.healthyCanonicalLabel,
      );
      expect(
        TFLiteLabelParser.canonicalDiseaseType('Healthy'),
        TFLiteLabelParser.healthyCanonicalLabel,
      );
      expect(
        TFLiteLabelParser.canonicalDiseaseType('Healthy Leaf'),
        TFLiteLabelParser.healthyCanonicalLabel,
      );
    });
  });
}
