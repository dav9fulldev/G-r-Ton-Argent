import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LocalizationService extends ChangeNotifier {
  static const List<Locale> supportedLocales = [
    Locale('fr', 'FR'), // Français
    Locale('en', 'US'), // Anglais
    Locale('es', 'ES'), // Espagnol
  ];

  static const Map<String, String> languageNames = {
    'fr': 'Français',
    'en': 'English',
    'es': 'Español',
  };

  static const Map<String, String> languageFlags = {
    'fr': '🇫🇷',
    'en': '🇺🇸',
    'es': '🇪🇸',
  };

  String getCurrentLanguage(BuildContext context) {
    return context.locale.languageCode;
  }

  Future<void> changeLanguage(BuildContext context, String languageCode) async {
    final locale = supportedLocales.firstWhere(
      (locale) => locale.languageCode == languageCode,
      orElse: () => const Locale('fr', 'FR'),
    );
    
    await context.setLocale(locale);
    notifyListeners();
  }

  String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? 'Français';
  }

  String getLanguageFlag(String languageCode) {
    return languageFlags[languageCode] ?? '🇫🇷';
  }

  List<Map<String, String>> getAvailableLanguages() {
    return languageNames.entries.map((entry) {
      return {
        'code': entry.key,
        'name': entry.value,
        'flag': languageFlags[entry.key] ?? '🇫🇷',
      };
    }).toList();
  }
}
