import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:maala_app/services/shared_pref_helper.dart';

class AppLocalizations {
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'pray': 'PRAY',
      'meditate': 'MEDITATE',
      'settings': 'Settings',
      'counter': 'Counter',
      'timer': 'Timer',
      'day': 'Day',
      'malaComplete': 'Mala Complete',
      'malasCompleted': 'malas completed',
      'chantsTotal': 'chants total',
      'enableHaptic': 'Enable Haptic Feedback',
      'keepScreenOn': 'Keep Screen On',
      'backgroundImage': 'Background Image',
      'soundtrack': 'Soundtrack',
      'counterLimit': 'Counter Limit',
      'counterLimitSub': 'Number of taps before reset',
      'focusMode': 'Focus Mode',
      'focusModeSub': 'Long-press counter to enter immersive mode',
      'language': 'Language',
      'mantra': 'Mantra',
      'mantraSub': 'Text displayed while chanting',
      'theme': 'Theme',
      'set': 'Set',
      'cancel': 'Cancel',
      'back': 'Back',
      'chooseSoundtrack': 'Choose Soundtrack',
      'chooseBackground': 'Choose Background',
      'chooseLanguage': 'Choose Language',
      'chooseTheme': 'Choose Theme',
      'setAsBackground': 'Set as Background',
      'enterCountLimit': 'Please enter a valid number (1-9999)',
      'countLimitSet': 'Counter limit set to',
      'streak': 'streak',
      'dayLabel': 'day',
      'daysLabel': 'days',
      'today': 'Today',
      'tapToCount': 'Tap anywhere to count',
      'longPressFocus': 'Long-press for focus mode',
      'rateMaala': 'Rate Maala',
      'rateMaalaSub': 'Love your practice? A review helps others find us',
    },
    'hi': {
      'pray': 'प्रार्थना',
      'meditate': 'ध्यान',
      'settings': 'सेटिंग्स',
      'counter': 'गिनती',
      'timer': 'टाइमर',
      'day': 'दिन',
      'malaComplete': 'माला पूर्ण',
      'malasCompleted': 'माला पूर्ण',
      'chantsTotal': 'कुल जप',
      'enableHaptic': 'हैप्टिक फीडबैक सक्षम करें',
      'keepScreenOn': 'स्क्रीन चालू रखें',
      'backgroundImage': 'पृष्ठभूमि छवि',
      'soundtrack': 'ध्वनि',
      'counterLimit': 'गिनती सीमा',
      'counterLimitSub': 'रीसेट से पहले टैप की संख्या',
      'focusMode': 'फोकस मोड',
      'focusModeSub': 'इमर्सिव मोड में प्रवेश के लिए काउंटर को दबाकर रखें',
      'language': 'भाषा',
      'mantra': 'मंत्र',
      'mantraSub': 'जप के दौरान प्रदर्शित पाठ',
      'theme': 'थीम',
      'set': 'सेट',
      'cancel': 'रद्द',
      'back': 'वापस',
      'chooseSoundtrack': 'ध्वनि चुनें',
      'chooseBackground': 'पृष्ठभूमि चुनें',
      'chooseLanguage': 'भाषा चुनें',
      'chooseTheme': 'थीम चुनें',
      'setAsBackground': 'पृष्ठभूमि के रूप में सेट करें',
      'enterCountLimit': 'कृपया एक मान्य संख्या दर्ज करें (1-9999)',
      'countLimitSet': 'गिनती सीमा सेट',
      'streak': 'लगातार',
      'dayLabel': 'दिन',
      'daysLabel': 'दिन',
      'today': 'आज',
      'tapToCount': 'गिनने के लिए कहीं भी टैप करें',
      'longPressFocus': 'फोकस मोड के लिए दबाकर रखें',
      'rateMaala': 'Maala को रेट करें',
      'rateMaalaSub': 'साधना पसंद आई? आपकी समीक्षा दूसरों तक पहुँचाएगी',
    },
  };

  static final ValueNotifier<String> languageNotifier =
      ValueNotifier(getLanguageCode());

  static String getLanguageCode() {
    final stored = SharedPrefHelper.getLanguageCode();
    if (stored != null) return stored;
    final sysLang = PlatformDispatcher.instance.locale.languageCode;
    return _translations.containsKey(sysLang) ? sysLang : 'en';
  }

  static void setLanguage(String code) {
    SharedPrefHelper.setLanguageCode(code);
    languageNotifier.value = code;
  }

  static String translate(String key) {
    final lang = languageNotifier.value;
    return _translations[lang]?[key] ?? _translations['en']?[key] ?? key;
  }

  static String get currentLang => languageNotifier.value;
  static bool get isHindi => currentLang == 'hi';
}
