import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'language_service.dart';

class AudioService {
  static final AudioPlayer _bgmPlayer = AudioPlayer();
  static final AudioPlayer _voicePlayer = AudioPlayer();

  static bool isBgmOn = true;
  static bool isSfxOn = true;
  static bool _bgmInitialized = false;

  /// অ্যাপ চালুর সময় সেভ করা সাউন্ড সেটিংস লোড করা
  static void loadSavedSettings() {
    if (Hive.isBoxOpen('game_data')) {
      final box = Hive.box('game_data');
      isBgmOn = box.get('isBgmOn', defaultValue: true);
      isSfxOn = box.get('isSfxOn', defaultValue: true);
    }
  }

  static void _saveSettings() {
    if (Hive.isBoxOpen('game_data')) {
      final box = Hive.box('game_data');
      box.put('isBgmOn', isBgmOn);
      box.put('isSfxOn', isSfxOn);
    }
  }

  /// মেইন মেনুর কুইক সাউন্ড বাটনের জন্য (BGM বা SFX কোনোটা চালু থাকলে অন দেখাবে)
  static bool get isSoundOn => isBgmOn || isSfxOn;

  /// ব্যাকগ্রাউন্ড মিউজিক চালু করা (Playful BGM Loop)
  static Future<void> startBgm() async {
    if (!isBgmOn) return;
    try {
      if (!_bgmInitialized) {
        await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
        await _bgmPlayer.setVolume(0.22); // হালকা ও মিষ্টি ভলিউম
        _bgmInitialized = true;
      }
      if (_bgmPlayer.state != PlayerState.playing) {
        await _bgmPlayer.play(AssetSource('audio/sfx/bgm.m4a'));
      }
    } catch (_) {}
  }

  /// ব্যাকগ্রাউন্ড মিউজিক বন্ধ করা
  static Future<void> stopBgm() async {
    try {
      await _bgmPlayer.pause();
    } catch (_) {}
  }

  /// শুধু BGM অন/অফ টগল করা (সেটিংস স্ক্রিন থেকে)
  static Future<void> setBgm(bool value) async {
    isBgmOn = value;
    _saveSettings();
    if (isBgmOn) {
      await startBgm();
    } else {
      await stopBgm();
    }
  }

  /// শুধু SFX ও Voiceover অন/অফ টগল করা (সেটিংস স্ক্রিন থেকে)
  static Future<void> setSfx(bool value) async {
    isSfxOn = value;
    _saveSettings();
    if (isSfxOn) {
      await playClick();
    } else {
      await _voicePlayer.stop();
    }
  }

  /// মেইন মেনু থেকে এক ক্লিকে সব সাউন্ড অন/অফ টগল করা
  static Future<void> toggleSound() async {
    final nextState = !isSoundOn;
    isBgmOn = nextState;
    isSfxOn = nextState;
    _saveSettings();
    if (nextState) {
      await startBgm();
      await playClick();
    } else {
      await stopBgm();
      await _voicePlayer.stop();
    }
  }

  /// অক্ষর টাইলস ট্যাপ করলে বাবল পপ সাউন্ড (Bubble Pop SFX)
  static Future<void> playPop() async {
    HapticFeedback.selectionClick();
    if (!isSfxOn) return;
    await _playOneShot('audio/sfx/pop.m4a', volume: 0.9);
  }

  /// সাধারণ বাটন ক্লিক সাউন্ড
  static Future<void> playClick() async {
    HapticFeedback.lightImpact();
    if (!isSfxOn) return;
    await _playOneShot('audio/sfx/click.m4a', volume: 0.8);
  }

  /// সঠিক উত্তরে ট্রাম্পেট/স্টার জিংগল + বাংলা ভয়েসওভার ("শাবাশ! এটা আম!")
  static Future<void> playSuccessAndVoice(String puzzleId) async {
    HapticFeedback.mediumImpact();
    if (!isSfxOn) return;
    await _playOneShot('audio/sfx/success.m4a', volume: 0.95);
    // জিংগলের পরপরই মিষ্টি গলায় বাংলা উচ্চারণ
    Future.delayed(const Duration(milliseconds: 350), () {
      if (isSfxOn) {
        playVoice(puzzleId);
      }
    });
  }

  /// ভুল উত্তরে কার্টুনিশ "বোয়িং" সাউন্ড + ভয়েসওভার
  static Future<void> playWrong() async {
    HapticFeedback.heavyImpact();
    if (!isSfxOn) return;
    await _playOneShot('audio/sfx/boing.m4a', volume: 0.95);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (isSfxOn) {
        playVoice('wrong');
      }
    });
  }

  /// ছবির উপর ট্যাপ করলে শব্দের বাংলা উচ্চারণ (যেমন: "আম", "আপেল")
  static Future<void> playWordHint(String puzzleId) async {
    HapticFeedback.selectionClick();
    if (!isSfxOn) return;
    await playVoice('word_$puzzleId');
  }

  /// যেকোনো বাংলা বা ইংরেজি ভয়েসওভার প্লে করা (বর্তমান ভাষা অনুযায়ী)
  static Future<void> playVoice(String key) async {
    if (!isSfxOn) return;
    try {
      final localizedKey = LanguageService.isEnglish ? 'en_$key' : key;
      await _voicePlayer.stop();
      await _voicePlayer.setVolume(1.0);
      await _voicePlayer.play(AssetSource('audio/voice/$localizedKey.m4a'));
    } catch (_) {}
  }

  /// ছোট SFX প্লে করে অটো-ডিসপোজ করা (যাতে পরপর দ্রুত ট্যাপ করলেও কোনো সাউন্ড মিস না হয়)
  static Future<void> _playOneShot(
    String assetPath, {
    double volume = 1.0,
  }) async {
    try {
      final player = AudioPlayer();
      await player.setVolume(volume);
      player.onPlayerComplete.listen((_) => player.dispose());
      await player.play(AssetSource(assetPath));
    } catch (_) {}
  }
}
