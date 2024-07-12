import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class TranslationService extends Translations {
  static final localeStorageKey = 'locale';

  // Définir les traductions pour chaque langue
  static Map<String, Map<String, String>> translations = {
    'en': {
      'title': 'Hello World',
      'greeting': 'Welcome to my app!',
    },
    'fr': {
      'title': 'Bonjour le monde',
      'greeting': 'Bienvenue dans mon application !',
    },
  };

  @override
  Map<String, Map<String, String>> get keys => translations;
  static Locale get locale {
    final langCode = GetStorage().read(localeStorageKey) ?? 'en';
    return Locale(langCode);
  }


  static void changeLocale(String langCode) {
    GetStorage().write(localeStorageKey, langCode);
    Get.updateLocale(Locale(langCode));
  }
}
