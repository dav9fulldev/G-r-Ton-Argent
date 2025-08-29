import 'lib/services/localization_service.dart';

void main() {
  print('🧪 Test des langues disponibles\n');
  
  print('📋 Langues supportées:');
  for (final locale in LocalizationService.supportedLocales) {
    print('  ${locale.languageCode}_${locale.countryCode}');
  }
  
  print('\n🏳️ Noms des langues:');
  final languageNames = LocalizationService.languageNames;
  for (final entry in languageNames.entries) {
    print('  ${entry.key}: ${entry.value}');
  }
  
  print('\n🎌 Drapeaux des langues:');
  final languageFlags = LocalizationService.languageFlags;
  for (final entry in languageFlags.entries) {
    print('  ${entry.key}: ${entry.value}');
  }
  
  print('\n📝 Langues disponibles (format complet):');
  final availableLanguages = LocalizationService().getAvailableLanguages();
  for (final language in availableLanguages) {
    print('  ${language['flag']} ${language['name']} (${language['code']})');
  }
  
  print('\n✅ Test terminé ! L\'espagnol a été supprimé avec succès.');
}
