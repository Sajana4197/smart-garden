/// Cleans up a handful of raw species strings from `labels.txt` into a
/// nicer `PlantDiagnosisResult.plantCommonName`, and supplies the Latin
/// binomial (`plantSpeciesLatin`) for each of the dataset's 20 species —
/// see MODEL_INTEGRATION.md §5. Most raw species strings need no cleanup;
/// only the three below have awkward source formatting.
class TFLiteSpeciesDisplay {
  const TFLiteSpeciesDisplay._();

  static String commonName(String rawSpecies) {
    return _displayNameOverrides[rawSpecies] ?? rawSpecies;
  }

  static String? latinName(String rawSpecies) {
    return _latinNames[rawSpecies];
  }

  static const _displayNameOverrides = <String, String>{
    'Corn (maize)': 'Corn (Maize)',
    'Cherry (including sour)': 'Cherry (Sour)',
    'Pepper, bell': 'Bell Pepper',
  };

  static const _latinNames = <String, String>{
    'Jackfruit': 'Artocarpus heterophyllus',
    'Mango': 'Mangifera indica',
    'Cotton': 'Gossypium hirsutum',
    'Apple': 'Malus domestica',
    'Pumpkin': 'Cucurbita pepo',
    'Peach': 'Prunus persica',
    'Pepper, bell': 'Capsicum annuum',
    'Tomato': 'Solanum lycopersicum',
    'Sugarcane': 'Saccharum officinarum',
    'Cauliflower': 'Brassica oleracea var. botrytis',
    'Grape': 'Vitis vinifera',
    'Rice': 'Oryza sativa',
    'Corn (maize)': 'Zea mays',
    'Orange': 'Citrus sinensis',
    'Strawberry': 'Fragaria × ananassa',
    'Cherry (including sour)': 'Prunus cerasus',
    'Blueberry': 'Vaccinium corymbosum',
    'Raspberry': 'Rubus idaeus',
    'Soybean': 'Glycine max',
    'Potato': 'Solanum tuberosum',
  };
}
