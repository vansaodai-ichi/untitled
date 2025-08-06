import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class Language {
  static String _currentLangCode = 'km';
  
  static String get currentLangCode => _currentLangCode;
  
  static bool get isKhmer => currentLangCode == 'km';
  static bool get isEnglish => currentLangCode == 'en';
  
  static void updateLanguageCode(BuildContext context) {
    _currentLangCode = context.locale.languageCode;
  }
  
  static void changeLanguage(String langCode) {
    _currentLangCode = langCode;
  }
}
