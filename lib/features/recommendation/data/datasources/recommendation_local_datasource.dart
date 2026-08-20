import '../../../../services/ai/models/plant_diagnosis_result.dart';
import '../../domain/entities/care_recommendation.dart';

class _RecommendationContent {
  const _RecommendationContent({
    required this.wateringAdvice,
    required this.lightAdvice,
    required this.treatmentSteps,
  });

  final String wateringAdvice;
  final String lightAdvice;
  final List<String> treatmentSteps;
}

/// Curated care-recommendation copy, keyed by `PlantDiagnosisResult.
/// diagnosisLabel` — covers every outcome in `mock_result_bank.dart`
/// (ROADMAP.md Phase 8). Any new diagnosisLabel a future real model
/// introduces must get an entry here, or it falls back to [_fallback] per
/// MODEL_INTEGRATION.md §3 — never a crash or blank state.
class RecommendationLocalDataSource {
  const RecommendationLocalDataSource();

  static const _contentBank = <String, _RecommendationContent>{
    'Healthy': _RecommendationContent(
      wateringAdvice:
          'Continue your current watering routine — soil moisture and '
          'drainage are working well for this plant.',
      lightAdvice:
          'Current light exposure looks appropriate; no changes needed.',
      treatmentSteps: [
        'No treatment needed right now.',
        'Recheck in 1–2 weeks as part of routine care.',
      ],
    ),
    'Powdery Mildew': _RecommendationContent(
      wateringAdvice:
          'Avoid overhead watering — water at the soil line to keep '
          'foliage dry and slow the spread of spores.',
      lightAdvice:
          'Increase air circulation and, where possible, more direct '
          'morning sun to help leaves dry out faster.',
      treatmentSteps: [
        'Remove and discard the most affected leaves.',
        'Apply a light fungicide or a diluted baking-soda spray to '
            'affected areas.',
        'Space plants further apart to improve airflow.',
      ],
    ),
    'Aphid Infestation': _RecommendationContent(
      wateringAdvice: "No change needed — this isn't a moisture issue.",
      lightAdvice:
          'Keep the plant in its current light spot; stressed plants '
          'attract more pests.',
      treatmentSteps: [
        'Spray affected stems and leaf undersides with insecticidal soap '
            'or a strong jet of water.',
        'Introduce or attract natural predators like ladybugs if growing '
            'outdoors.',
        'Recheck every few days until the colony is gone.',
      ],
    ),
    'Black Spot': _RecommendationContent(
      wateringAdvice:
          'Water at the base of the plant in the morning so leaves dry '
          'out over the course of the day.',
      lightAdvice:
          'Ensure good sun exposure and prune nearby foliage to improve '
          'airflow around the plant.',
      treatmentSteps: [
        "Remove and dispose of infected leaves — don't compost them.",
        'Apply a fungicide labeled for black spot every 7–10 days.',
        'Clean up fallen leaves around the base of the plant regularly.',
      ],
    ),
    'Downy Mildew': _RecommendationContent(
      wateringAdvice:
          'Water in the morning and avoid wetting the leaves; let the '
          'soil surface dry between waterings.',
      lightAdvice:
          'Move to a spot with better airflow and, if indoors, run a '
          'small fan nearby.',
      treatmentSteps: [
        'Remove and discard affected leaves promptly.',
        'Apply a copper-based fungicide to the remaining foliage.',
        'Reduce humidity around the plant where possible.',
      ],
    ),
    'Bacterial Wilt': _RecommendationContent(
      wateringAdvice:
          "Watering more won't help — the plant's water uptake is "
          'blocked internally.',
      lightAdvice:
          'Keep the plant in its current light; focus on removing the '
          'source rather than adjusting conditions.',
      treatmentSteps: [
        'Remove and destroy affected vines or plants promptly to protect '
            'nearby plants.',
        'Control cucumber beetles, the primary carrier, with row covers '
            'or an approved insecticide.',
        'Disinfect tools used on the plant before using them elsewhere.',
      ],
    ),
    'Root Rot': _RecommendationContent(
      wateringAdvice:
          'Stop watering until the topsoil is dry, then water less '
          'frequently and only when the top inch is dry.',
      lightAdvice:
          "Keep in indirect light while recovering — the plant's roots "
          "don't need extra stress right now.",
      treatmentSteps: [
        'Remove the plant from its pot and trim away soft, dark, mushy '
            'roots.',
        'Repot into fresh, well-draining soil and a pot with drainage '
            'holes.',
        'Hold off on fertilizer until new growth appears.',
      ],
    ),

    // --- Phase 18: entries for the real TFLiteAIService's 41 disease
    // types + "Unknown Disease" (see tflite_diagnosis_content_bank.dart —
    // these keys match its canonical disease-type keys exactly, since both
    // banks are species-agnostic and keyed the same way). "Healthy" above
    // already covers the real model's Healthy case, no duplicate needed.
    'Unknown Disease': _RecommendationContent(
      wateringAdvice:
          "We can't give watering guidance without a confirmed diagnosis "
          '— keep to a normal routine for this type of plant in the '
          'meantime.',
      lightAdvice:
          'No light changes recommended until a clearer diagnosis is '
          'available.',
      treatmentSteps: [
        "This result wasn't confident enough to act on.",
        'Try rescanning with a clearer, closer, well-lit photo of the '
            'affected area.',
        'If the plant is a species this app may not fully support yet, '
            'consider a local gardening resource for now.',
      ],
    ),
    'Algal Leaf Spot': _RecommendationContent(
      wateringAdvice:
          'Water at the base rather than overhead — standing moisture on '
          'leaves encourages algal growth.',
      lightAdvice:
          'Improve airflow and sun exposure; algae favors shaded, humid '
          'foliage.',
      treatmentSteps: [
        'Prune overcrowded branches to increase light and airflow.',
        'Remove heavily affected leaves.',
        'A copper-based spray can help in persistent cases.',
      ],
    ),
    'Anthracnose': _RecommendationContent(
      wateringAdvice:
          'Water at the soil line and avoid wetting foliage, especially '
          'late in the day.',
      lightAdvice:
          'Prune nearby growth to improve airflow and help leaves dry '
          'faster after rain or watering.',
      treatmentSteps: [
        'Remove and dispose of infected leaves, stems, or fruit — '
            "don't compost them.",
        'Apply a fungicide labeled for anthracnose.',
        'Clean up plant debris around the base regularly.',
      ],
    ),
    'Aphids': _RecommendationContent(
      wateringAdvice: "No change needed — this isn't a moisture issue.",
      lightAdvice:
          'Keep the plant in its current light spot; stressed plants '
          'attract more pests.',
      treatmentSteps: [
        'Spray affected stems and leaf undersides with insecticidal soap '
            'or a strong jet of water.',
        'Introduce or attract natural predators like ladybugs if growing '
            'outdoors.',
        'Recheck every few days until the colony is gone.',
      ],
    ),
    'Apple Scab': _RecommendationContent(
      wateringAdvice:
          'Water at the base in the morning so foliage has all day to dry.',
      lightAdvice:
          'Prune to open up the canopy — scab thrives in cool, damp, '
          'shaded conditions.',
      treatmentSteps: [
        'Rake up and dispose of fallen leaves, which harbor the fungus '
            'over winter.',
        'Apply a fungicide at bud break next season as a preventive '
            'measure.',
        'Prune out any visibly infected shoots.',
      ],
    ),
    'Bacterial Blight': _RecommendationContent(
      wateringAdvice:
          'Water at the base — splashing water is the main way this '
          'bacteria spreads.',
      lightAdvice:
          'Ensure good spacing and airflow between plants to help foliage '
          'dry quickly.',
      treatmentSteps: [
        'Remove and destroy infected leaves and stems promptly.',
        'Disinfect pruning tools between cuts.',
        'A copper-based bactericide can help slow the spread.',
      ],
    ),
    'Bacterial Blights': _RecommendationContent(
      wateringAdvice:
          'Water at the base — splashing water spreads this bacteria '
          'between plants.',
      lightAdvice:
          'Improve spacing and airflow between rows to help foliage dry '
          'quickly.',
      treatmentSteps: [
        'Remove and destroy severely streaked leaves.',
        'Disinfect any cutting tools before reuse.',
        'Avoid working in the field/garden while foliage is wet.',
      ],
    ),
    'Bacterial Canker': _RecommendationContent(
      wateringAdvice:
          'Avoid overhead watering — wounds and wet bark are the main '
          'infection points.',
      lightAdvice: 'Keep the plant in its current light; focus on pruning.',
      treatmentSteps: [
        'Prune out cankered stems well below the visible lesion, '
            'disinfecting tools between cuts.',
        'Avoid pruning during wet weather.',
        'A copper spray in dormant season can help prevent new infections.',
      ],
    ),
    'Bacterial Leaf Spot': _RecommendationContent(
      wateringAdvice:
          'Water at the base of the plant and avoid overhead sprinklers.',
      lightAdvice:
          'Space plants to improve airflow and help leaves dry quickly '
          'after rain.',
      treatmentSteps: [
        'Remove and discard affected leaves.',
        'Apply a copper-based bactericide to remaining foliage.',
        'Avoid handling wet plants to reduce spread.',
      ],
    ),
    'Bacterial Spot': _RecommendationContent(
      wateringAdvice:
          'Water at the soil line — splashing water spreads this '
          'bacteria between leaves and plants.',
      lightAdvice:
          'Space plants further apart to improve airflow and help '
          'foliage dry faster.',
      treatmentSteps: [
        'Remove and discard the most affected leaves and fruit.',
        'Apply a copper-based bactericide labeled for bacterial spot.',
        'Rotate crops next season if this is a garden bed planting.',
      ],
    ),
    'Black Rot': _RecommendationContent(
      wateringAdvice:
          'Water at the base in the morning so foliage and fruit dry '
          'quickly.',
      lightAdvice:
          'Prune to improve airflow through the canopy — humidity trapped '
          'inside encourages this fungus.',
      treatmentSteps: [
        'Remove and destroy infected fruit ("mummies"), leaves, and '
            'prunings — do not compost them.',
        'Apply a fungicide labeled for black rot starting early in the '
            'season.',
        'Prune out cankered wood during dormancy.',
      ],
    ),
    'Brown Spot': _RecommendationContent(
      wateringAdvice:
          'Avoid water stress in either direction — both drought and '
          'waterlogging make this worse.',
      lightAdvice: 'Ensure balanced soil fertility; keep in its usual light.',
      treatmentSteps: [
        'Remove severely spotted leaves.',
        'Apply a fungicide labeled for brown spot if it keeps spreading.',
        'Check that soil fertility (especially potassium) is adequate.',
      ],
    ),
    'Cedar Apple Rust': _RecommendationContent(
      wateringAdvice: 'No change needed — this spreads through the air, '
          'not through water.',
      lightAdvice: 'Keep the plant in its current light.',
      treatmentSteps: [
        'Remove nearby cedar/juniper hosts if practical — they carry the '
            'disease between seasons.',
        'Apply a fungicide starting at bud break next season.',
        'Rake and dispose of fallen infected leaves.',
      ],
    ),
    'Cercospora Leaf Spot (Gray Leaf Spot)': _RecommendationContent(
      wateringAdvice:
          'Water at the base — this fungus spreads readily on wet leaves.',
      lightAdvice: 'Improve airflow between plants to help foliage dry '
          'faster.',
      treatmentSteps: [
        'Remove severely affected lower leaves.',
        'Apply a fungicide labeled for gray leaf spot if it keeps '
            'spreading upward.',
        'Rotate crops next season if this is a garden bed planting.',
      ],
    ),
    'Common Rust': _RecommendationContent(
      wateringAdvice: 'No change needed — this spreads through the air, '
          'not through water.',
      lightAdvice: 'Keep the plant in its current light and spacing.',
      treatmentSteps: [
        'Remove heavily infected leaves if practical.',
        'A fungicide can help if infection is severe and caught early.',
        'Choose rust-resistant varieties next season if this recurs.',
      ],
    ),
    'Cutting Weevil': _RecommendationContent(
      wateringAdvice: "No change needed — this isn't a moisture issue.",
      lightAdvice: 'Keep the plant in its current light.',
      treatmentSteps: [
        'Prune off and destroy affected shoots below the entry point.',
        'Remove and destroy fallen infested shoots to prevent overwintering.',
        'An approved insecticide can help during active infestations.',
      ],
    ),
    'Die Back': _RecommendationContent(
      wateringAdvice:
          'Check drainage — waterlogged roots often trigger dieback.',
      lightAdvice: 'Keep the plant in its current light while it recovers.',
      treatmentSteps: [
        'Prune out dead/dying branches well back into healthy wood, '
            'disinfecting tools between cuts.',
        'Improve drainage and avoid wounding the trunk or roots.',
        'A fungicide may help if the cause is confirmed to be fungal.',
      ],
    ),
    'Early Blight': _RecommendationContent(
      wateringAdvice:
          'Water at the base and avoid wetting leaves — this fungus '
          'thrives on wet foliage.',
      lightAdvice:
          'Ensure good spacing and airflow between plants.',
      treatmentSteps: [
        'Remove and discard the most affected lower leaves.',
        'Apply a fungicide labeled for early blight.',
        'Mulch around the base to reduce soil splashing onto leaves.',
      ],
    ),
    'Esca (Black Measles)': _RecommendationContent(
      wateringAdvice:
          'Avoid water stress in either direction — this disease often '
          'worsens under drought stress.',
      lightAdvice: 'Keep the vine in its current light and spacing.',
      treatmentSteps: [
        'Prune out and destroy affected wood during dry weather, '
            'disinfecting tools between cuts.',
        'Avoid large pruning wounds where possible; seal them if needed.',
        'There is no cure once established — focus on slowing spread and '
            'vine stress management.',
      ],
    ),
    'Gall Midge': _RecommendationContent(
      wateringAdvice: "No change needed — this isn't a moisture issue.",
      lightAdvice: 'Keep the plant in its current light.',
      treatmentSteps: [
        'Remove and destroy affected buds/shoots to reduce the next '
            'generation.',
        'Clear fallen debris from around the base, where larvae pupate.',
        'An approved insecticide can help during active infestations.',
      ],
    ),
    'Haunglongbing (Citrus Greening)': _RecommendationContent(
      wateringAdvice:
          'Maintain consistent watering to reduce stress — there is no '
          'watering change that treats this disease.',
      lightAdvice: 'Keep the tree in its current light.',
      treatmentSteps: [
        'There is no cure — focus on controlling the Asian citrus psyllid '
            'insect that spreads it.',
        'Remove and destroy severely affected trees to protect '
            'neighboring citrus.',
        'Consult a local agricultural extension service for regional '
            'management guidance.',
      ],
    ),
    'Hispa': _RecommendationContent(
      wateringAdvice: "No change needed — this isn't a moisture issue.",
      lightAdvice: 'Keep the plant in its current light.',
      treatmentSteps: [
        'Remove and destroy visibly damaged leaves with larvae inside.',
        'Drain standing water near the field/bed where practical — '
            'adults shelter there.',
        'An approved insecticide can help during heavy infestations.',
      ],
    ),
    'Late Blight': _RecommendationContent(
      wateringAdvice:
          'Water at the base only, and avoid watering in the evening — '
          'this disease spreads fastest on wet foliage overnight.',
      lightAdvice:
          'Maximize airflow and spacing between plants immediately.',
      treatmentSteps: [
        'Remove and destroy infected plants promptly — this disease can '
            'destroy a planting within days.',
        'Apply a fungicide labeled for late blight to remaining plants '
            'as a preventive measure.',
        "Don't compost infected material.",
      ],
    ),
    'Leaf Mold': _RecommendationContent(
      wateringAdvice:
          'Water at the base and avoid wetting foliage.',
      lightAdvice:
          'Improve ventilation — this fungus thrives in humid, poorly '
          'ventilated conditions (common in greenhouses/indoors).',
      treatmentSteps: [
        'Remove and discard affected leaves.',
        'Reduce humidity and increase spacing between plants.',
        'A fungicide can help if it keeps spreading.',
      ],
    ),
    'Leaf Blight (Isariopsis Leaf Spot)': _RecommendationContent(
      wateringAdvice:
          'Water at the base — this fungus spreads on wet leaves.',
      lightAdvice: 'Prune to improve airflow through the canopy.',
      treatmentSteps: [
        'Remove and discard affected leaves.',
        'Apply a fungicide labeled for this disease if it keeps '
            'spreading.',
        'Clean up fallen leaves around the base regularly.',
      ],
    ),
    'Leaf Scorch': _RecommendationContent(
      wateringAdvice:
          'Check that watering is consistent — inconsistent moisture is '
          'a common contributor to scorch.',
      lightAdvice:
          'If scorch is severe, some afternoon shade can reduce leaf-edge '
          'stress.',
      treatmentSteps: [
        'Remove severely scorched leaves.',
        'Mulch to help retain even soil moisture.',
        'A fungicide can help if a fungal cause is confirmed.',
      ],
    ),
    'Leaf Blast': _RecommendationContent(
      wateringAdvice:
          'Avoid excess nitrogen and drought stress — both increase '
          'susceptibility.',
      lightAdvice: 'Ensure good spacing and airflow between plants.',
      treatmentSteps: [
        'Apply a fungicide labeled for rice blast promptly — this '
            'disease can spread very quickly.',
        'Avoid excess nitrogen fertilizer, which increases '
            'susceptibility.',
        'Choose blast-resistant varieties next season if this recurs.',
      ],
    ),
    'Mosaic': _RecommendationContent(
      wateringAdvice: "Watering changes won't help — this is viral, not "
          'a moisture issue.',
      lightAdvice: 'Keep the plant in its current light.',
      treatmentSteps: [
        'There is no cure — remove and destroy infected plants to '
            'protect nearby healthy ones.',
        'Control aphids and other sap-sucking insects, the main carriers.',
        'Disinfect tools between plants.',
      ],
    ),
    'Mosaic Disease': _RecommendationContent(
      wateringAdvice: "Watering changes won't help — this is viral, not "
          'a moisture issue.',
      lightAdvice: 'Keep the plant in its current light.',
      treatmentSteps: [
        'There is no cure — remove and destroy infected plants to '
            'protect nearby healthy ones.',
        'Control aphids and cucumber beetles, common carriers.',
        'Disinfect tools between plants.',
      ],
    ),
    'Northern Leaf Blight': _RecommendationContent(
      wateringAdvice:
          'Water at the base — this fungus spreads on wet leaves.',
      lightAdvice: 'Ensure good spacing and airflow between plants.',
      treatmentSteps: [
        'Remove severely affected lower leaves if practical.',
        'Apply a fungicide labeled for northern leaf blight if it '
            'reaches upper leaves before harvest.',
        'Choose resistant varieties next season if this recurs.',
      ],
    ),
    'Red Rot': _RecommendationContent(
      wateringAdvice:
          'Ensure good field drainage — waterlogging worsens this '
          'disease.',
      lightAdvice: 'Keep the plant in its current light.',
      treatmentSteps: [
        'Remove and destroy severely affected stalks.',
        'Use disease-free planting material for the next crop.',
        'Choose resistant varieties next season if this recurs.',
      ],
    ),
    'Rust': _RecommendationContent(
      wateringAdvice: 'No change needed — this spreads through the air, '
          'not through water.',
      lightAdvice: 'Improve airflow and spacing around the plant.',
      treatmentSteps: [
        'Remove heavily infected leaves if practical.',
        'A fungicide can help if infection is severe and caught early.',
        'Avoid overhead watering, which can help spores spread.',
      ],
    ),
    'Septoria Leaf Spot': _RecommendationContent(
      wateringAdvice:
          'Water at the base and avoid wetting leaves.',
      lightAdvice:
          'Ensure good spacing and airflow between plants.',
      treatmentSteps: [
        'Remove and discard affected lower leaves promptly.',
        'Apply a fungicide labeled for septoria leaf spot.',
        'Mulch around the base to reduce soil splashing onto leaves.',
      ],
    ),
    'Sooty Mould': _RecommendationContent(
      wateringAdvice: "No change needed — this isn't a moisture issue.",
      lightAdvice:
          'Improve airflow; a heavy coating can otherwise block sunlight.',
      treatmentSteps: [
        'Control the aphids, scale, or whitefly producing the honeydew '
            'this mold grows on.',
        'Gently wipe or rinse the sooty coating off leaves once pests '
            'are controlled.',
        'No fungicide is usually needed once the underlying pest is '
            'gone.',
      ],
    ),
    'Spider Mites (Two-Spotted Spider Mite)': _RecommendationContent(
      wateringAdvice:
          'Increase humidity around the plant where practical — spider '
          'mites thrive in hot, dry conditions.',
      lightAdvice: 'Keep the plant in its current light.',
      treatmentSteps: [
        'Rinse leaves (especially undersides) with a strong jet of water '
            'to dislodge mites.',
        'Apply insecticidal soap or miticide to affected areas.',
        'Recheck every few days — mite populations rebound quickly.',
      ],
    ),
    'Target Spot': _RecommendationContent(
      wateringAdvice:
          'Water at the base and avoid wetting foliage late in the day.',
      lightAdvice: 'Ensure good spacing and airflow between plants.',
      treatmentSteps: [
        'Remove and discard affected leaves.',
        'Apply a fungicide labeled for target spot if it keeps '
            'spreading.',
        'Clean up plant debris around the base regularly.',
      ],
    ),
    'Tomato Yellow Leaf Curl Virus': _RecommendationContent(
      wateringAdvice: "Watering changes won't help — this is viral, not "
          'a moisture issue.',
      lightAdvice: 'Keep the plant in its current light.',
      treatmentSteps: [
        'There is no cure — severely affected plants rarely recover; '
            'consider removal to protect nearby plants.',
        'Control whitefly, the primary carrier, with row covers or '
            'insecticidal soap.',
        'Choose resistant varieties next season if this recurs.',
      ],
    ),
    'Tomato Mosaic Virus': _RecommendationContent(
      wateringAdvice: "Watering changes won't help — this is viral, not "
          'a moisture issue.',
      lightAdvice: 'Keep the plant in its current light.',
      treatmentSteps: [
        'There is no cure — remove and destroy infected plants to '
            'protect nearby healthy ones.',
        'Wash hands and disinfect tools between plants — this virus '
            'spreads easily by contact.',
        "Avoid tobacco use around plants; the virus can spread from it.",
      ],
    ),
    'Yellow': _RecommendationContent(
      wateringAdvice:
          'Ensure consistent, adequate watering while monitoring — '
          'stress can worsen systemic infections.',
      lightAdvice: 'Keep the plant in its current light.',
      treatmentSteps: [
        'Remove and destroy severely affected stalks/plants to limit '
            'spread.',
        'Control leafhoppers or other likely insect carriers.',
        'Use disease-free planting material for the next crop.',
      ],
    ),
  };

  static const _fallback = _RecommendationContent(
    wateringAdvice:
        'Water when the top inch of soil feels dry, and avoid letting '
        'the plant sit in standing water.',
    lightAdvice:
        'Provide bright, indirect light unless you know this plant '
        'prefers otherwise.',
    treatmentSteps: [
      "We don't have specific guidance for this diagnosis yet.",
      'Monitor the plant closely and consult a local gardening resource '
          'or expert.',
      'Rescan in a few days to track any changes.',
    ],
  );

  CareRecommendation getRecommendation(
    String diagnosisLabel,
    DiagnosisSeverity severity,
  ) {
    final content = _contentBank[diagnosisLabel] ?? _fallback;
    return CareRecommendation(
      wateringAdvice: content.wateringAdvice,
      lightAdvice: content.lightAdvice,
      treatmentSteps: content.treatmentSteps,
      urgency: _urgencyFor(severity),
    );
  }

  static RecommendationUrgency _urgencyFor(DiagnosisSeverity severity) {
    switch (severity) {
      case DiagnosisSeverity.none:
      case DiagnosisSeverity.mild:
        return RecommendationUrgency.routine;
      case DiagnosisSeverity.moderate:
        return RecommendationUrgency.monitor;
      case DiagnosisSeverity.severe:
        return RecommendationUrgency.urgent;
    }
  }
}
