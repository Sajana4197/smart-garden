/// Parses a raw TFLite model class label (e.g. `"Bacterial spot (Tomato)"`)
/// into its species and disease-type parts, and canonicalizes the disease
/// part into the key used by [tfliteDiagnosisContentBank] and by
/// `RecommendationLocalDataSource` — see MODEL_INTEGRATION.md §5 and
/// CLAUDE.md's Phase 18 "Label parsing & content bank" Locked Decision.
///
/// Labels follow a `"<Disease> (<Species>)"` format, with two wrinkles this
/// parser exists to handle correctly:
/// 1. The species itself can contain parentheses (e.g. `"Corn (maize)"` in
///    `"Common rust (Corn (maize))"`), so naive "text between the first '('
///    and the last ')'" parsing would be correct here only by accident.
/// 2. The disease name can *also* contain parentheses (e.g.
///    `"Esca (Black Measles) (Grape)"`), so the split must find the *last*
///    top-level (non-nested) parenthetical group specifically, not the
///    first — otherwise "Esca" alone would be parsed as the disease and
///    "Black Measles" as a bogus species.
class TFLiteLabelParser {
  const TFLiteLabelParser._();

  /// The model's dedicated open-set rejection class (see CLAUDE.md's
  /// FAR/FRR Locked Decision) — has no associated species.
  static const unknownDiseaseRawLabel = 'Unknown Disease';

  /// Canonical key used for every "healthy" variant regardless of exact
  /// wording (`Healthy`, `healthy`, `Healthy Leaf`, ...) — deliberately a
  /// looser merge than the disease-name canonicalization below, since a
  /// "no disease present" description/recommendation is universally
  /// applicable and carries none of the risk of conflating two distinct
  /// diseases that happen to have similar-looking raw label text.
  static const healthyCanonicalLabel = 'Healthy';

  /// Splits a raw label into `(species, diseaseRaw)`. [species] is null
  /// only for [unknownDiseaseRawLabel].
  static ParsedLabel parse(String rawLabel) {
    if (rawLabel == unknownDiseaseRawLabel) {
      return const ParsedLabel(species: null, diseaseRaw: unknownDiseaseRawLabel);
    }

    final spans = _topLevelParenSpans(rawLabel);
    if (spans.isEmpty) {
      // Defensive fallback only — every real label in labels.txt has a
      // trailing "(Species)" group.
      return ParsedLabel(species: null, diseaseRaw: rawLabel.trim());
    }

    final lastSpan = spans.last;
    final species = rawLabel.substring(lastSpan.start + 1, lastSpan.end - 1);
    final diseaseRaw = rawLabel.substring(0, lastSpan.start).trim();
    return ParsedLabel(species: species, diseaseRaw: diseaseRaw);
  }

  /// Collapses a raw disease-name fragment (as returned by [parse]) into
  /// the canonical key used by the content banks. Two rules:
  /// - Any string that case-insensitively starts with "healthy" collapses
  ///   to [healthyCanonicalLabel] (see its doc comment for why).
  /// - Otherwise, an explicit lookup table merges only exact
  ///   case/spacing variants of the *same* disease name (e.g.
  ///   `"Black rot"` / `"Black Rot"`, `"Powdery mildew"` / `"Powdery
  ///   Mildew"`, `"Target spot"` / `"Target Spot"`). Deliberately NOT a
  ///   fuzzy/substring merge — e.g. "Mosaic" and "Mosaic Disease", or
  ///   "Black Rot" and "Black Spot", stay distinct, since collapsing them
  ///   risks writing content for the wrong disease.
  static String canonicalDiseaseType(String diseaseRaw) {
    if (diseaseRaw.toLowerCase().startsWith('healthy')) {
      return healthyCanonicalLabel;
    }
    return _canonicalDiseaseTypeMap[diseaseRaw] ?? diseaseRaw;
  }

  static List<_ParenSpan> _topLevelParenSpans(String text) {
    final spans = <_ParenSpan>[];
    var depth = 0;
    int? start;
    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      if (char == '(') {
        if (depth == 0) start = i;
        depth++;
      } else if (char == ')') {
        depth--;
        if (depth == 0 && start != null) {
          spans.add(_ParenSpan(start, i + 1));
          start = null;
        }
      }
    }
    return spans;
  }

  /// Raw disease-name fragment (post-species-split, pre-canonicalization)
  /// → canonical key. Built by hand from every non-healthy entry in
  /// `assets/models/labels.txt` — see the Phase 18 Locked Decision for the
  /// full reasoning behind each merge.
  static const _canonicalDiseaseTypeMap = <String, String>{
    'Apple scab': 'Apple Scab',
    'Bacterial spot': 'Bacterial Spot',
    'BacterialBlights': 'Bacterial Blights',
    'Black rot': 'Black Rot',
    'BrownSpot': 'Brown Spot',
    'Cedar apple rust': 'Cedar Apple Rust',
    'Cercospora leaf spot Gray leaf spot': 'Cercospora Leaf Spot (Gray Leaf Spot)',
    'Common rust': 'Common Rust',
    'Die Back': 'Die Back',
    'Downy Mildew': 'Downy Mildew',
    'Early blight': 'Early Blight',
    'Haunglongbing (Citrus greening)': 'Haunglongbing (Citrus Greening)',
    'Late blight': 'Late Blight',
    'Leaf blight (Isariopsis Leaf Spot)': 'Leaf Blight (Isariopsis Leaf Spot)',
    'Leaf scorch': 'Leaf Scorch',
    'LeafBlast': 'Leaf Blast',
    'Northern Leaf Blight': 'Northern Leaf Blight',
    'Powdery mildew': 'Powdery Mildew',
    'RedRot': 'Red Rot',
    'Septoria leaf spot': 'Septoria Leaf Spot',
    'Sooty Mould': 'Sooty Mould',
    'Spider mites Two-spotted spider mite': 'Spider Mites (Two-Spotted Spider Mite)',
    'Target spot': 'Target Spot',
    'Tomato mosaic virus': 'Tomato Mosaic Virus',
  };
}

class _ParenSpan {
  const _ParenSpan(this.start, this.end);
  final int start;
  final int end;
}

/// Result of [TFLiteLabelParser.parse].
class ParsedLabel {
  const ParsedLabel({required this.species, required this.diseaseRaw});

  /// Raw species text (e.g. `"Corn (maize)"`, `"Pepper, bell"`) — null only
  /// for `Unknown Disease`. Not yet display-cleaned; see
  /// `TFLiteSpeciesDisplay` for that.
  final String? species;

  /// Raw disease text, not yet canonicalized — pass to
  /// [TFLiteLabelParser.canonicalDiseaseType] before using as a content-bank
  /// key.
  final String diseaseRaw;
}
