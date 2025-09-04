import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { english, hindi, marathi }

class LanguageState {
  final AppLanguage currentLanguage;
  final Locale locale;

  const LanguageState({required this.currentLanguage, required this.locale});

  LanguageState copyWith({AppLanguage? currentLanguage, Locale? locale}) {
    return LanguageState(
      currentLanguage: currentLanguage ?? this.currentLanguage,
      locale: locale ?? this.locale,
    );
  }
}

class LanguageNotifier extends StateNotifier<LanguageState> {
  LanguageNotifier()
    : super(
        const LanguageState(
          currentLanguage: AppLanguage.english,
          locale: Locale('en', 'US'),
        ),
      ) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageIndex =
        prefs.getInt('app_language') ?? AppLanguage.english.index;
    final language = AppLanguage.values[languageIndex];
    await changeLanguage(language);
  }

  Future<void> changeLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('app_language', language.index);

    Locale locale;
    switch (language) {
      case AppLanguage.hindi:
        locale = const Locale('hi', 'IN');
        break;
      case AppLanguage.marathi:
        locale = const Locale('mr', 'IN');
        break;
      case AppLanguage.english:
      default:
        locale = const Locale('en', 'US');
        break;
    }

    state = LanguageState(currentLanguage: language, locale: locale);
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, LanguageState>(
  (ref) {
    return LanguageNotifier();
  },
);

// Translations map
class AppTranslations {
  static const Map<String, Map<String, String>> _translations = {
    // English
    'en': {
      'app_name': 'Krushak',
      'welcome': 'Welcome to Krushak',
      'sign_in': 'Sign In',
      'sign_up': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'full_name': 'Full Name',
      'phone': 'Phone Number',
      'location': 'Location',
      'home': 'Home',
      'market': 'Market',
      'diagnosis': 'Diagnosis',
      'learning': 'Learning',
      'community': 'Community',
      'account': 'Account',
      'farms': 'Farms',
      'crops': 'Crops',
      'financial_overview': 'Financial Overview',
      'income': 'Income',
      'expenses': 'Expenses',
      'profit': 'Profit',
      'weather': 'Weather',
      'temperature': 'Temperature',
      'humidity': 'Humidity',
      'rainfall': 'Rainfall',
      'wind_speed': 'Wind Speed',
      'notifications': 'Notifications',
      'settings': 'Settings',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'logout': 'Logout',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'search': 'Search',
      'filter': 'Filter',
      'sort': 'Sort',
      'high_temperature_alert': 'High Temperature Alert',
      'heavy_rain_alert': 'Heavy Rain Alert',
      'drought_warning': 'Drought Warning',
      'weather_advisory': 'Weather Advisory',
      'crop_disease_detected': 'Crop Disease Detected',
      'market_price_update': 'Market Price Update',
    },

    // Hindi
    'hi': {
      'app_name': 'कृषक',
      'welcome': 'कृषक में आपका स्वागत है',
      'sign_in': 'साइन इन करें',
      'sign_up': 'साइन अप करें',
      'email': 'ईमेल',
      'password': 'पासवर्ड',
      'full_name': 'पूरा नाम',
      'phone': 'फ़ोन नंबर',
      'location': 'स्थान',
      'home': 'होम',
      'market': 'बाज़ार',
      'diagnosis': 'निदान',
      'learning': 'सीखना',
      'community': 'समुदाय',
      'account': 'खाता',
      'farms': 'खेत',
      'crops': 'फसलें',
      'financial_overview': 'वित्तीय सिंहावलोकन',
      'income': 'आय',
      'expenses': 'खर्च',
      'profit': 'लाभ',
      'weather': 'मौसम',
      'temperature': 'तापमान',
      'humidity': 'नमी',
      'rainfall': 'वर्षा',
      'wind_speed': 'हवा की गति',
      'notifications': 'सूचनाएं',
      'settings': 'सेटिंग्स',
      'dark_mode': 'डार्क मोड',
      'language': 'भाषा',
      'logout': 'लॉग आउट',
      'save': 'सेव करें',
      'cancel': 'रद्द करें',
      'delete': 'हटाएं',
      'edit': 'संपादित करें',
      'add': 'जोड़ें',
      'search': 'खोज',
      'filter': 'फ़िल्टर',
      'sort': 'क्रमबद्ध करें',
      'high_temperature_alert': 'उच्च तापमान चेतावनी',
      'heavy_rain_alert': 'भारी बारिश चेतावनी',
      'drought_warning': 'सूखा चेतावनी',
      'weather_advisory': 'मौसम सलाह',
      'crop_disease_detected': 'फसल रोग का पता चला',
      'market_price_update': 'बाज़ार मूल्य अपडेट',
    },

    // Marathi
    'mr': {
      'app_name': 'कृषक',
      'welcome': 'कृषकमध्ये तुमचे स्वागत आहे',
      'sign_in': 'साइन इन करा',
      'sign_up': 'साइन अप करा',
      'email': 'ईमेल',
      'password': 'पासवर्ड',
      'full_name': 'पूर्ण नाव',
      'phone': 'फोन नंबर',
      'location': 'स्थान',
      'home': 'होम',
      'market': 'बाजार',
      'diagnosis': 'निदान',
      'learning': 'शिकणे',
      'community': 'समुदाय',
      'account': 'खाते',
      'farms': 'शेत',
      'crops': 'पिके',
      'financial_overview': 'आर्थिक आढावा',
      'income': 'उत्पन्न',
      'expenses': 'खर्च',
      'profit': 'नफा',
      'weather': 'हवामान',
      'temperature': 'तापमान',
      'humidity': 'आर्द्रता',
      'rainfall': 'पाऊस',
      'wind_speed': 'वाऱ्याचा वेग',
      'notifications': 'सूचना',
      'settings': 'सेटिंग्स',
      'dark_mode': 'डार्क मोड',
      'language': 'भाषा',
      'logout': 'लॉग आउट',
      'save': 'सेव्ह करा',
      'cancel': 'रद्द करा',
      'delete': 'हटवा',
      'edit': 'संपादित करा',
      'add': 'जोडा',
      'search': 'शोध',
      'filter': 'फिल्टर',
      'sort': 'क्रमवारी लावा',
      'high_temperature_alert': 'उच्च तापमान इशारा',
      'heavy_rain_alert': 'मुसळधार पाऊस इशारा',
      'drought_warning': 'दुष्काळ चेतावणी',
      'weather_advisory': 'हवामान सल्ला',
      'crop_disease_detected': 'पीक रोग आढळला',
      'market_price_update': 'बाजार भाव अपडेट',
    },
  };

  static String translate(String key, String languageCode) {
    return _translations[languageCode]?[key] ??
        _translations['en']?[key] ??
        key;
  }
}

final translationProvider = Provider.family<String, String>((ref, key) {
  final languageState = ref.watch(languageProvider);
  return AppTranslations.translate(key, languageState.locale.languageCode);
});
