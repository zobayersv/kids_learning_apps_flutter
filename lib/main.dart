import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:loadshad/services/audio_service.dart';
import 'package:loadshad/services/language_service.dart';
import 'package:loadshad/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // লোকাল ডেটা ও প্রগ্রেস সংরক্ষণের জন্য Hive ইনিশিয়ালাইজেশন
  await Hive.initFlutter();
  await Hive.openBox('game_data');
  AudioService.loadSavedSettings();
  LanguageService.loadSavedLanguage();

  //* অ্যাপ সবসময় ল্যান্ডস্কেপ মোডে রান করবে
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  //* ফুলস্ক্রিন ভিউ (স্ট্যাটাস বার ও নেভিগেশন বার হাইড)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const BanglaKidsGameApp());
}

class BanglaKidsGameApp extends StatelessWidget {
  const BanglaKidsGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'বর্ণে রঙে শব্দ শেখা',
      theme: ThemeData(
        fontFamily: 'HindSiliguri',
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
