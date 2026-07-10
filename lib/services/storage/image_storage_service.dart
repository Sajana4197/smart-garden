import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Copies raw camera/gallery output into a stable app-sandbox path — see
/// PROJECT_SPEC.md §6 ("all images stay on-device"). Camera/gallery plugins
/// hand back a volatile temp/cache path the OS can clear at any time; every
/// feature that captures/picks a photo must route it through here before
/// treating the path as durable.
class ImageStorageService {
  Future<String> saveToSandbox(File sourceFile, {required String prefix}) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final scansDirectory = Directory(p.join(documentsDirectory.path, 'scans'));
    if (!await scansDirectory.exists()) {
      await scansDirectory.create(recursive: true);
    }

    final fileName =
        '${prefix}_${DateTime.now().millisecondsSinceEpoch}${p.extension(sourceFile.path)}';
    final destinationPath = p.join(scansDirectory.path, fileName);
    final savedFile = await sourceFile.copy(destinationPath);
    return savedFile.path;
  }
}
