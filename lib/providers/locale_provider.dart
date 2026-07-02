import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app's locale/language setting.
/// Persists choice to SharedPreferences so it survives app restarts.
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  static const String _prefKey = 'app_language';

  /// Language options shown in Settings
  static const List<LanguageOption> supportedLanguages = [
    LanguageOption(locale: Locale('en'), name: 'English', nativeName: 'English'),
    LanguageOption(locale: Locale('ms'), name: 'Malay', nativeName: 'Bahasa Melayu'),
    LanguageOption(locale: Locale('zh'), name: 'Chinese', nativeName: '中文'),
    LanguageOption(locale: Locale('ta'), name: 'Tamil', nativeName: 'தமிழ்'),
  ];

  /// Load saved language preference
  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey);
    if (code != null) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  /// Change the app language
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.languageCode);
  }
}

class LanguageOption {
  final Locale locale;
  final String name;
  final String nativeName;

  const LanguageOption({
    required this.locale,
    required this.name,
    required this.nativeName,
  });
}
