import 'models/plant_diagnosis_result.dart';
import 'tflite_label_parser.dart';

/// Description/visualSymptoms/severity content for one canonical disease
/// type, keyed by [TFLiteLabelParser.canonicalDiseaseType] output — see
/// MODEL_INTEGRATION.md §5 and CLAUDE.md's Phase 18 "Label parsing &
/// content bank" Locked Decision.
class TFLiteDiagnosisContent {
  const TFLiteDiagnosisContent({
    required this.description,
    required this.visualSymptoms,
    required this.defaultSeverity,
  });

  final String description;
  final List<String> visualSymptoms;

  /// The model has no severity output (the training dataset carried no
  /// severity labels) — this is a static per-disease-type default, not
  /// derived from the model's confidence score. Confidence measures how
  /// sure the model is of the *label*; it says nothing about how advanced
  /// the disease looks in this particular photo, so conflating the two
  /// would be wrong. Revisit only if a future model version adds real
  /// severity estimation.
  final DiagnosisSeverity defaultSeverity;
}

/// Curated content bank covering every canonical disease type the real
/// TFLite model can produce (41 diseases + Healthy + Unknown Disease — see
/// `tflite_label_parser.dart` for how 71 raw model classes collapse to
/// these 43 keys). Species-agnostic by design, matching
/// `RecommendationLocalDataSource`'s existing pattern — a description here
/// is combined with the parsed species name at the call site in
/// `TFLiteAIService`, not duplicated per species.
const tfliteDiagnosisContentBank = <String, TFLiteDiagnosisContent>{
  'Healthy': TFLiteDiagnosisContent(
    description:
        'This plant shows no visible signs of disease, pests, or nutrient '
        'stress. Leaves look uniform in color with no spotting, wilting, '
        'or discoloration.',
    visualSymptoms: [],
    defaultSeverity: DiagnosisSeverity.none,
  ),
  'Algal Leaf Spot': TFLiteDiagnosisContent(
    description:
        'A parasitic algae is growing on the leaf surface, producing small '
        'raised spots. Usually cosmetic at this stage but can spread in '
        'warm, humid conditions.',
    visualSymptoms: [
      'Raised, greenish-orange velvety spots on leaves',
      'Spots may merge into larger blotches over time',
    ],
    defaultSeverity: DiagnosisSeverity.mild,
  ),
  'Anthracnose': TFLiteDiagnosisContent(
    description:
        'A fungal infection causing dark, sunken lesions on leaves, stems, '
        'or fruit. Spreads quickly in wet, humid weather.',
    visualSymptoms: [
      'Dark, sunken brown-to-black lesions',
      'Lesions may show concentric rings',
      'Affected tissue can shrivel or die back',
    ],
    defaultSeverity: DiagnosisSeverity.moderate,
  ),
  'Aphids': TFLiteDiagnosisContent(
    description:
        'Small sap-sucking insects clustering on new growth and the '
        'undersides of leaves, weakening the plant and excreting sticky '
        'honeydew.',
    visualSymptoms: [
      'Clusters of tiny insects on stems or leaf undersides',
      'Curled, distorted, or yellowing new growth',
      'Sticky residue (honeydew) on leaves',
    ],
    defaultSeverity: DiagnosisSeverity.mild,
  ),
  'Apple Scab': TFLiteDiagnosisContent(
    description:
        'A common fungal disease of apple leaves and fruit, favored by '
        'cool, wet spring weather.',
    visualSymptoms: [
      'Olive-green to dark brown scabby spots on leaves',
      'Spots may crack fruit skin',
      'Heavily infected leaves can drop early',
    ],
    defaultSeverity: DiagnosisSeverity.mild,
  ),
  'Bacterial Blight': TFLiteDiagnosisContent(
    description:
        'A bacterial infection causing water-soaked lesions that expand '
        'and kill leaf tissue, spreading readily in wet or humid '
        'conditions.',
    visualSymptoms: [
      'Water-soaked spots that turn brown and dry',
      'Lesions often ringed by a yellow halo',
      'Affected leaves may curl or drop',
    ],
    defaultSeverity: DiagnosisSeverity.moderate,
  ),
  'Bacterial Blights': TFLiteDiagnosisContent(
    description:
        'A bacterial infection producing streaking and blighted patches on '
        'leaves, capable of reducing yield if it spreads unchecked.',
    visualSymptoms: [
      'Long water-soaked streaks along leaf veins',
      'Streaks dry out and turn tan to brown',
      'Leaf tips may wither',
    ],
    defaultSeverity: DiagnosisSeverity.moderate,
  ),
  'Bacterial Canker': TFLiteDiagnosisContent(
    description:
        'A bacterial infection producing sunken, oozing lesions on stems '
        'and fruit as well as leaf spotting.',
    visualSymptoms: [
      'Sunken, dark lesions on stems or fruit',
      'Lesions may ooze a gummy discharge',
      'Small dark spots with a yellow halo on leaves',
    ],
    defaultSeverity: DiagnosisSeverity.moderate,
  ),
  'Bacterial Leaf Spot': TFLiteDiagnosisContent(
    description:
        'A bacterial infection causing small, angular, water-soaked spots '
        'that dry out and can merge into larger dead patches.',
    visualSymptoms: [
      'Small angular water-soaked spots',
      'Spots dry to a tan or brown center',
      'Yellow halo often visible around each spot',
    ],
    defaultSeverity: DiagnosisSeverity.mild,
  ),
  'Bacterial Spot': TFLiteDiagnosisContent(
    description:
        'A bacterial infection producing dark, scabby spots on leaves and '
        'fruit, spread readily by splashing water.',
    visualSymptoms: [
      'Small dark, greasy-looking spots on leaves',
      'Spots may have a yellow halo',
      'Fruit can develop raised, scabby lesions',
    ],
    defaultSeverity: DiagnosisSeverity.moderate,
  ),
  'Black Rot': TFLiteDiagnosisContent(
    description:
        'A fungal disease that rots fruit and produces leaf lesions, capable '
        'of causing serious losses if left untreated.',
    visualSymptoms: [
      'Circular brown-to-black leaf lesions',
      'Fruit shrivels into a hard, dark "mummy"',
      'Lesions may show tiny black fungal specks',
    ],
    defaultSeverity: DiagnosisSeverity.severe,
  ),
  'Black Spot': TFLiteDiagnosisContent(
    description:
        'A fungal infection producing dark, irregular spots on leaves, '
        'often followed by yellowing and premature leaf drop.',
    visualSymptoms: [
      'Black spots with fringed or feathery edges',
      'Yellowing of leaf tissue surrounding spots',
      'Premature leaf drop in advanced cases',
    ],
    defaultSeverity: DiagnosisSeverity.mild,
  ),
  'Brown Spot': TFLiteDiagnosisContent(
    description:
        'A fungal infection producing oval brown lesions on leaves, more '
        'common under low-fertility or drought-stressed conditions.',
    visualSymptoms: [
      'Small oval brown spots with a darker border',
      'Spots may have a pale yellow halo',
      'Heavily spotted leaves can dry out early',
    ],
    defaultSeverity: DiagnosisSeverity.mild,
  ),
  'Cedar Apple Rust': TFLiteDiagnosisContent(
    description:
        'A fungal disease that alternates between apple and juniper/cedar '
        'trees, producing bright rust-colored leaf spots.',
    visualSymptoms: [
      'Bright orange-yellow spots on upper leaf surface',
      'Small raised, tube-like structures on the underside',
      'Heavily infected leaves may drop early',
    ],
    defaultSeverity: DiagnosisSeverity.mild,
  ),
  'Cercospora Leaf Spot (Gray Leaf Spot)': TFLiteDiagnosisContent(
    description:
        'A fungal disease producing narrow, rectangular gray-to-tan '
        'lesions that run parallel to leaf veins, common in warm, humid '
        'weather.',
    visualSymptoms: [
      'Narrow, rectangular tan-to-gray lesions',
      'Lesions run parallel to leaf veins',
      'Lesions can merge, killing large sections of leaf',
    ],
    defaultSeverity: DiagnosisSeverity.moderate,
  ),
  'Common Rust': TFLiteDiagnosisContent(
    description:
        'A fungal disease producing small reddish-brown pustules scattered '
        'across both leaf surfaces.',
    visualSymptoms: [
      'Small, round-to-elongated reddish-brown pustules',
      'Pustules appear on both sides of the leaf',
      'Pustules turn dark brown/black as they age',
    ],
    defaultSeverity: DiagnosisSeverity.mild,
  ),
  'Cutting Weevil': TFLiteDiagnosisContent(
    description:
        'A boring pest whose larvae tunnel into stems and shoots, causing '
        'wilting and dieback of the affected part.',
    visualSymptoms: [
      'Small entry/exit holes in stems or shoots',
      'Wilting or drooping of the affected shoot tip',
      'Sawdust-like frass near entry holes',
    ],
    defaultSeverity: DiagnosisSeverity.moderate,
  ),
  'Die Back': TFLiteDiagnosisContent(
    description:
        'Progressive death of shoots and branches starting from the tip, '
        'usually caused by a fungal infection entering through wounds or '
        'stressed tissue.',
    visualSymptoms: [
      'Browning and drying starting at branch tips',
      'Dieback progressing inward toward the trunk',
      'Sparse or discolored foliage on affected branches',
    ],
    defaultSeverity: DiagnosisSeverity.severe,
  ),
  'Downy Mildew': TFLiteDiagnosisContent(
    description:
        'A fungus-like infection producing yellow patches on the upper '
        'leaf surface with a fuzzy growth underneath, favored by cool, '
        'damp conditions.',
    visualSymptoms: [
      'Pale yellow patches on upper leaf surface',
      'Grayish-white fuzzy growth on the underside',
      'Affected leaves may curl and die',
    ],
    defaultSeverity: DiagnosisSeverity.moderate,
  ),
  'Early Blight': TFLiteDiagnosisContent(
    description:
        'A common fungal disease producing dark, target-like spots that '
        'start on older, lower leaves and work upward.',
    visualSymptoms: [
      'Dark brown spots with concentric "target" rings',
      'Yellowing of leaf tissue around each spot',
      'Starts on lower/older leaves first',
    ],
    defaultSeverity: DiagnosisSeverity.moderate,
  ),
  'Esca (Black Measles)': TFLiteDiagnosisContent(
    description:
        'A serious fungal trunk disease of grapevine affecting the wood '
        'and leaves, which can weaken or kill the vine over several '
        'seasons.',
    visualSymptoms: [
      'Tiger-stripe pattern of yellow/red bands between leaf veins',
      'Dark spots on fruit ("black measles")',
      'Shoots may wilt and die suddenly in severe cases',
    ],
    defaultSeverity: DiagnosisSeverity.severe,
  ),
  'Gall Midge': TFLiteDiagnosisContent(
    description:
        'A small fly whose larvae feed inside developing shoots or fruit, '
        'causing distorted growth or premature drop.',
    visualSymptoms: [
      'Swollen or distorted new shoots/buds',
      'Premature drop of affected buds or fruit',
      'Small larvae visible if a gall is cut open',
    ],
    defaultSeverity: DiagnosisSeverity.mild,
  ),
  'Haunglongbing (Citrus Greening)': TFLiteDiagnosisContent(
    description:
        'A serious bacterial disease spread by an insect vector, causing '
        'blotchy, asymmetric yellowing and misshapen, bitter fruit. There '
        'is no cure once a tree is infected.',
    visualSymptoms: [
      'Blotchy, asymmetric yellow mottling on leaves',
      'Small, lopsided, bitter-tasting fruit',
      'Yellow shoots ("yellow dragon" appearance)',
    ],
    defaultSeverity: DiagnosisSeverity.severe,
  ),
  'Hispa': TFLiteDiagnosisContent(
    description:
        'A beetle pest whose adults and larvae scrape and tunnel through '
        'leaf tissue, leaving pale streaks.',
    visualSymptoms: [
      'Thin, whitish parallel streaks along leaf veins',
      'Small blotch mines where larvae tunnel inside the leaf',
      'Leaf tips may look scorched from heavy feeding',
    ],
    defaultSeverity: DiagnosisSeverity.mild,
  ),
  'Late Blight': TFLiteDiagnosisContent(
    description:
        'A fast-moving, historically destructive disease (the cause of the '
        '19th-century Irish potato famine) that can destroy a crop within '
        'days under cool, wet conditions.',
    visualSymptoms: [
      'Large, water-soaked, dark green-to-black blotches',
      'White fuzzy fungal growth on the underside in humid weather',
      'Rapid collapse and blackening of affected foliage',
    ],
    defaultSeverity: DiagnosisSeverity.severe,
  ),
  'Leaf Mold': TFLiteDiagnosisContent(
    description:
        'A fungal disease favored by high humidity and poor airflow, '
        'producing pale patches on top of the leaf with fuzzy mold '
        'underneath.',
    visualSymptoms: [
      'Pale yellow-green patches on upper leaf surface',
      'Olive-green to grayish fuzzy mold on the underside',
      'Affected leaves may curl and drop',
    ],
    defaultSeverity: DiagnosisSeverity.mild,
  ),
  'Leaf Blight (Isariopsis Leaf Spot)': TFLiteDiagnosisContent(
    description:
        'A fungal disease producing angular brown spots on grapevine '
        'leaves, which can lead to early defoliation if severe.',
    visualSymptoms: [
      'Angular brown-to-reddish spots between leaf veins',
      'Spots may have a yellow border',
      'Severely spotted leaves can drop early',
    ],
    defaultSeverity: DiagnosisSeverity.moderate,
  ),
  'Leaf Scorch': TFLiteDiagnosisContent(
    description:
        'Browning and drying of leaf margins and tips, often from a '
        'fungal infection or environmental stress restricting water flow '
        'to the leaf edge.',
    visualSymptoms: [
      'Brown, dry, papery leaf margins',
      'Discoloration often starts at the tip and spreads inward',
      'A darker band sometimes visible between healthy and scorched tissue',
    ],
    defaultSeverity: DiagnosisSeverity.moderate,
  ),
  'Leaf Blast': TFLiteDiagnosisContent(
    description:
        'One of the most destructive rice diseases, producing spindle-'
        'shaped lesions that can rapidly kill leaves under favorable '
        'conditions.',
    visualSymptoms: [
      'Spindle/diamond-shaped lesions with gray centers',
      'Lesions bordered by a dark brown-to-reddish margin',
      'Lesions can merge and kill the entire leaf',
    ],
    defaultSeverity: DiagnosisSeverity.severe,
  ),
  'Mosaic': TFLiteDiagnosisContent(
    description:
        'A viral infection producing an irregular light-and-dark mottled '
        'pattern on leaves, typically spread by sap-sucking insects or '
        'contaminated tools. There is no cure — management focuses on '
        'containment.',
    visualSymptoms: [
      'Irregular light green/yellow and dark green mottling',
      'Leaves may be smaller or misshapen',
      'Stunted overall growth',
    ],
    defaultSeverity: DiagnosisSeverity.moderate,
  ),
  'Mosaic Disease': TFLiteDiagnosisContent(
    description:
        'A viral infection producing a mottled, discolored leaf pattern '
        'and often stunted, distorted growth. There is no cure — '
        'management focuses on containment.',
    visualSymptoms: [
      'Mottled yellow-and-green patchwork pattern',
      'Distorted or curled leaf shape',
      'Reduced fruit set or stunted vines',
    ],
    defaultSeverity: DiagnosisSeverity.moderate,
  ),
  'Northern Leaf Blight': TFLiteDiagnosisContent(
    description:
        'A fungal disease producing long, cigar-shaped gray-green lesions '
        'that can significantly reduce yield if it reaches upper leaves '
        'before harvest.',
    visualSymptoms: [
      'Long, elliptical gray-green to tan lesions',
      'Lesions run parallel to the leaf edge',
      'Lesions can merge, killing large areas of leaf',
    ],
    defaultSeverity: DiagnosisSeverity.moderate,
  ),
  'Powdery Mildew': TFLiteDiagnosisContent(
    description:
        'A very common fungal infection appearing as a white powdery '
        'coating on leaf surfaces, favored by warm days and high '
        'humidity.',
    visualSymptoms: [
      'White to grayish powdery patches on leaves',
      'Coating can spread to stems and buds',
      'Leaves may yellow and curl in advanced cases',
    ],
    defaultSeverity: DiagnosisSeverity.mild,
  ),
  'Red Rot': TFLiteDiagnosisContent(
    description:
        'A serious fungal disease that rots the internal stalk tissue, '
        'capable of significantly reducing yield and, if severe, killing '
        'the plant.',
    visualSymptoms: [
      'Reddish discoloration inside the stalk when cut open',
      'White patches interrupting the red internal discoloration',
      'Wilting and drying of leaves',
    ],
    defaultSeverity: DiagnosisSeverity.severe,
  ),
  'Rust': TFLiteDiagnosisContent(
    description:
        'A fungal disease producing rust-colored pustules on leaf '
        'surfaces, which can reduce vigor if it builds up over the '
        'season.',
    visualSymptoms: [
      'Orange-to-reddish-brown powdery pustules',
      'Pustules mostly on the underside of leaves',
      'Heavily infected leaves may yellow and drop',
    ],
    defaultSeverity: DiagnosisSeverity.mild,
  ),
  'Septoria Leaf Spot': TFLiteDiagnosisContent(
    description:
        'A fungal disease producing many small, dark-bordered spots that '
        'start on lower leaves and spread upward in wet conditions.',
    visualSymptoms: [
      'Small circular spots with dark margins and tan centers',
      'Tiny black specks (fungal fruiting bodies) visible in spot centers',
      'Starts on lower leaves and moves upward',
    ],
    defaultSeverity: DiagnosisSeverity.mild,
  ),
  'Sooty Mould': TFLiteDiagnosisContent(
    description:
        'A dark fungal growth that develops on the sticky honeydew left '
        'by sap-sucking insects. Mostly cosmetic, but heavy coating can '
        'block sunlight from the leaf.',
    visualSymptoms: [
      'Dark, sooty-black coating on leaf surfaces',
      'Coating wipes/flakes off relatively easily',
      'Often accompanied by aphids, scale, or whitefly nearby',
    ],
    defaultSeverity: DiagnosisSeverity.mild,
  ),
  'Spider Mites (Two-Spotted Spider Mite)': TFLiteDiagnosisContent(
    description:
        'Tiny sap-sucking pests that thrive in hot, dry conditions, '
        'causing a fine stippled discoloration and sometimes visible '
        'webbing.',
    visualSymptoms: [
      'Fine yellow/white speckling (stippling) on leaves',
      'Fine webbing on the underside or between leaves',
      'Leaves may look dusty, bronzed, or dried out',
    ],
    defaultSeverity: DiagnosisSeverity.mild,
  ),
  'Target Spot': TFLiteDiagnosisContent(
    description:
        'A fungal disease producing brown lesions with concentric rings '
        'resembling a target, spreading in warm, humid conditions.',
    visualSymptoms: [
      'Brown circular lesions with concentric ring pattern',
      'Lesions may have a yellow halo',
      'Can affect leaves, stems, and fruit',
    ],
    defaultSeverity: DiagnosisSeverity.mild,
  ),
  'Tomato Yellow Leaf Curl Virus': TFLiteDiagnosisContent(
    description:
        'A serious viral disease spread by whitefly, causing severe '
        'stunting and leaf curling. There is no cure — affected plants '
        'rarely recover fully.',
    visualSymptoms: [
      'Upward curling, cupped leaves',
      'Strong yellowing along leaf margins',
      'Pronounced stunting and reduced fruit set',
    ],
    defaultSeverity: DiagnosisSeverity.severe,
  ),
  'Tomato Mosaic Virus': TFLiteDiagnosisContent(
    description:
        'A viral infection producing a mottled light-and-dark leaf '
        'pattern and distorted growth, easily spread by contact/tools. '
        'There is no cure — management focuses on containment.',
    visualSymptoms: [
      'Light green/yellow mottling mixed with dark green',
      'Narrow, fern-like distorted leaves',
      'Stunted plant growth',
    ],
    defaultSeverity: DiagnosisSeverity.moderate,
  ),
  'Yellow': TFLiteDiagnosisContent(
    description:
        'A disease causing progressive yellowing of foliage, most often '
        'linked to a systemic infection restricting the plant\'s nutrient '
        'and water flow.',
    visualSymptoms: [
      'Yellowing starting at leaf midrib and margins',
      'Yellowing progresses from older to younger leaves',
      'Overall reduced vigor and stunted growth',
    ],
    defaultSeverity: DiagnosisSeverity.moderate,
  ),
  'Unknown Disease': TFLiteDiagnosisContent(
    description:
        "This doesn't confidently match any disease this model was "
        "trained to recognize — it may be a healthy plant, a species "
        "outside this model's training set, or a photo that's unclear. "
        'Try rescanning with a clearer, closer photo of the affected area.',
    visualSymptoms: [],
    defaultSeverity: DiagnosisSeverity.none,
  ),
};
