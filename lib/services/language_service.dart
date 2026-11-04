import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'audio_service.dart';
import 'progress_service.dart';

enum AppLanguage { bn, en }

class LanguageService {
  static final ValueNotifier<AppLanguage> notifier =
      ValueNotifier<AppLanguage>(AppLanguage.bn);

  static AppLanguage get current => notifier.value;
  static bool get isBangla => notifier.value == AppLanguage.bn;
  static bool get isEnglish => notifier.value == AppLanguage.en;

  /// অ্যাপ চালুর সময় সেভ করা ভাষা লোড করা
  static void loadSavedLanguage() {
    if (Hive.isBoxOpen('game_data')) {
      final box = Hive.box('game_data');
      final saved = box.get('app_language', defaultValue: 'bn');
      notifier.value = saved == 'en' ? AppLanguage.en : AppLanguage.bn;
    }
  }

  /// এক ক্লিকে বাংলা <-> ইংরেজি পরিবর্তন করা
  static void toggleLanguage() {
    setLanguage(isBangla ? AppLanguage.en : AppLanguage.bn);
  }

  /// নির্দিষ্ট ভাষা সেট করা
  static void setLanguage(AppLanguage lang) {
    notifier.value = lang;
    if (Hive.isBoxOpen('game_data')) {
      Hive.box('game_data').put(
        'app_language',
        lang == AppLanguage.en ? 'en' : 'bn',
      );
    }
    AudioService.playPop();
  }

  /// সংখ্যা ফরম্যাট করা (বাংলা মোডে বাংলা সংখ্যা, ইংরেজি মোডে ইংরেজি সংখ্যা)
  static String formatNumber(int number) {
    return isBangla ? ProgressService.toBanglaDigits(number) : number.toString();
  }

  /// টেক্সট হেল্পার (বাংলা ও ইংরেজি টেক্সট সহজে রিটার্ন করার জন্য)
  static String tr(String bnText, String enText) {
    return isBangla ? bnText : enText;
  }
}
