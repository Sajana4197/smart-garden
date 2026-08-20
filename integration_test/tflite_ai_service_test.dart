import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img_lib;
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_garden_ai/services/ai/tflite_ai_service.dart';

/// Dedicated on-device test suite for [TFLiteAIService] — see
/// MODEL_INTEGRATION.md §7 ("add a small dedicated test suite for it
/// alone (model loads, produces a well-formed PlantDiagnosisResult for a
/// known sample image)"). Requires a real device/emulator — `tflite_flutter`'s
/// FFI bindings and native `.so` libraries aren't available under plain
/// `flutter test`, only under a real Flutter engine. Run via:
///   flutter test integration_test/tflite_ai_service_test.dart -d `device`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late TFLiteAIService service;

  setUpAll(() {
    service = TFLiteAIService();
  });

  testWidgets('isReady() loads the real interpreter from assets/models/',
      (tester) async {
    final ready = await service.isReady();
    expect(
      ready,
      isTrue,
      reason: 'Interpreter failed to load — check assets/models/ '
          'registration in pubspec.yaml and that the .tflite/labels.txt '
          'files are present.',
    );
  });

  testWidgets(
      'analyzeImage() produces a well-formed PlantDiagnosisResult for a '
      'real photo run through the real on-device interpreter', (tester) async {
    // Synthetic on-device test image (no bundled sample needed) — a
    // roughly leaf-colored green gradient, large enough to be resized down
    // to the model's real input shape by TFLiteAIService itself.
    final image = img_lib.Image(width: 400, height: 400);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final g = 100 + (x % 155);
        image.setPixelRgb(x, y, 40, g, 40);
      }
    }
    final jpegBytes = img_lib.encodeJpg(image);

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/tflite_integration_test_sample.jpg');
    await file.writeAsBytes(jpegBytes);

    final result = await service.analyzeImage(file);

    expect(result.plantCommonName, isNotEmpty);
    expect(result.diagnosisLabel, isNotEmpty);
    expect(result.confidence, inInclusiveRange(0.0, 1.0));
    expect(result.description, isNotEmpty);

    // ignore: avoid_print
    print(
      'TFLiteAIService live on-device result: ${result.plantCommonName} / '
      '${result.diagnosisLabel} '
      '(${(result.confidence * 100).toStringAsFixed(1)}% confidence, '
      '${result.severity.name} severity, isHealthy=${result.isHealthy})',
    );

    await file.delete();
  });
}
