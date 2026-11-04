import 'package:hive_flutter/hive_flutter.dart';

class ProgressService {
  static Box get _box => Hive.box('game_data');

  /// মোট অর্জিত স্টার (Stars)
  static int get totalStars => _box.get('total_stars', defaultValue: 0);

  /// মোট অর্জিত কয়েন (Coins)
  static int get totalCoins => _box.get('total_coins', defaultValue: 100);

  /// স্টার যোগ করা
  static void addStars(int amount) {
    _box.put('total_stars', totalStars + amount);
  }

  /// কয়েন যোগ করা
  static void addCoins(int amount) {
    _box.put('total_coins', totalCoins + amount);
  }

  /// নির্দিষ্ট ক্যাটাগরির কতগুলো লেভেল সম্পন্ন হয়েছে
  static int getCompletedLevels(String categoryId, {int defaultVal = 0}) {
    return _box.get('completed_$categoryId', defaultValue: defaultVal);
  }

  /// ইউজার যখন কোনো ক্যাটাগরিতে ঢুকবে, কোন লেভেল থেকে খেলা শুরু হবে (Resume Level Index)
  static int getResumeLevelIndex(String categoryId, int totalLevels) {
    final completed = getCompletedLevels(categoryId);
    if (completed <= 0) return 0;
    if (completed >= totalLevels) return 0; // সব শেষ হলে আবার প্রথম থেকে খেলতে পারবে
    return completed; // যেমন: ২টি শেষ করলে ইনডেক্স ২ (অর্থাৎ ৩ নম্বর লেভেল) থেকে শুরু হবে
  }

  /// লেভেল সম্পন্ন হলে প্রগ্রেস, স্টার ও কয়েন আপডেট করা (শুধুমাত্র নতুন লেভেল পার করলে বোনাস পাবে কিংবা প্রতিবার খেললে পয়েন্ট পাবে)
  static void completeLevel({
    required String categoryId,
    required int levelNumber, // 1-based (যেমন: লেভেল ১, ২...)
    int starsEarned = 1,
    int coinsEarned = 10,
  }) {
    final currentCompleted = getCompletedLevels(categoryId);
    if (levelNumber > currentCompleted) {
      _box.put('completed_$categoryId', levelNumber);
      addStars(starsEarned);
      addCoins(coinsEarned);
    } else {
      // আগে পার করা লেভেল আবার খেললে শুধু ৫ কয়েন বোনাস পাবে
      addCoins(5);
    }
  }

  /// ক্যাটাগরি আনলক লজিক:
  /// প্রথম ৩টি ক্যাটাগরি (ফলমূল, পশুপাখি, ফুল) শুরু থেকেই আনলকড অথবা আগের ক্যাটাগরির অন্তত ১টি লেভেল পার করলেই পরের ক্যাটাগরি আনলক হবে।
  static bool isCategoryUnlocked({
    required int categoryIndex,
    required String? previousCategoryId,
    required bool defaultLocked,
  }) {
    if (!defaultLocked || categoryIndex == 0) return true;
    if (previousCategoryId == null) return true;
    // আগের ক্যাটাগরির অন্তত ২টি লেভেল (বা সব লেভেল) শেষ করলে এই ক্যাটাগরি আনলক হবে
    return getCompletedLevels(previousCategoryId) >= 2;
  }

  /// বাংলা সংখ্যায় রূপান্তর (যেমন: 100 -> ১০০)
  static String toBanglaDigits(int number) {
    const eng = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bng = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    String str = number.toString();
    for (int i = 0; i < 10; i++) {
      str = str.replaceAll(eng[i], bng[i]);
    }
    return str;
  }

  /// সব প্রগ্রেস রিসেট করে নতুন করে শুরু করা (সাউন্ড সেটিংস অক্ষুণ্ণ রেখে)
  static Future<void> resetAllProgress() async {
    final bgm = _box.get('isBgmOn', defaultValue: true);
    final sfx = _box.get('isSfxOn', defaultValue: true);
    await _box.clear();
    await _box.put('isBgmOn', bgm);
    await _box.put('isSfxOn', sfx);
    await _box.put('total_stars', 0);
    await _box.put('total_coins', 100);
  }
}
