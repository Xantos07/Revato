/// **SERVICE UTILITAIRE POUR LE NETTOYAGE DE TEXTE**
class TextCleaningService {
  /// **GÉNÉRATION DU NOM TECHNIQUE**
  /// Convertit "Résumé du rêve" → "resume_du_reve"
  static String generateTechnicalName(String displayName) {
    String result = displayName.toLowerCase().trim();

    // Map des caractères accentués
    const accentMap = {
      'à': 'a',
      'á': 'a',
      'â': 'a',
      'ä': 'a',
      'è': 'e',
      'é': 'e',
      'ê': 'e',
      'ë': 'e',
      'ì': 'i',
      'í': 'i',
      'î': 'i',
      'ï': 'i',
      'ò': 'o',
      'ó': 'o',
      'ô': 'o',
      'ö': 'o',
      'ù': 'u',
      'ú': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
      'ñ': 'n',
    };

    // Remplacer les accents
    accentMap.forEach((accent, replacement) {
      result = result.replaceAll(accent, replacement);
    });

    // Garder seulement lettres, chiffres et remplacer le reste par _
    result = result.replaceAll(RegExp(r'[^a-z0-9]+'), '_');

    // Nettoyer les _ en début/fin et éviter les multiples _
    result = result.replaceAll(RegExp(r'^_+|_+$'), '');
    result = result.replaceAll(RegExp(r'_+'), '_');

    return result;
  }
}
