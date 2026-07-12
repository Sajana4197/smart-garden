import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/plant_tip_model.dart';

/// Reads the curated tip bank from the bundled asset — no network involved,
/// matching the app's offline-first requirement (PROJECT_SPEC.md §6).
class TipBankDataSource {
  static const String _assetPath = 'assets/tips/plant_tips.json';

  Future<List<PlantTipModel>> getAllTips() async {
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((entry) => PlantTipModel.fromJson(entry as Map<String, dynamic>))
        .toList();
  }
}
