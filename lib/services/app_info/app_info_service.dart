import 'package:package_info_plus/package_info_plus.dart';

/// Thin wrapper over `package_info_plus`, mirroring the `services/storage`/
/// `services/database` singleton pattern — presentation code never calls
/// `PackageInfo.fromPlatform()` directly. Returns a plain formatted string
/// (not a DTO), matching `ImageStorageService.saveToSandbox`'s precedent for
/// simple single-value plugin wrappers. See ROADMAP.md Phase 15 (About
/// screen's live app version).
class AppInfoService {
  Future<String> getVersionLabel() async {
    final info = await PackageInfo.fromPlatform();
    return '${info.version} (${info.buildNumber})';
  }
}
