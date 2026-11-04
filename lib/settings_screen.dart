import 'dart:math';
import 'package:flutter/material.dart';
import 'package:loadshad/services/audio_service.dart';
import 'package:loadshad/services/language_service.dart';
import 'package:loadshad/services/progress_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  /// প্যারেন্টাল গেট (Parental Gate) দেখিয়ে সঠিক উত্তর দিলে সেটিংস স্ক্রিনে নিয়ে যাবে
  static Future<void> openWithParentalGate(
    BuildContext context, {
    VoidCallback? onClosed,
  }) async {
    final verified = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _ParentalGateDialog(),
    );

    if (verified == true && context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
      onClosed?.call();
    }
  }

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _bgmOn = AudioService.isBgmOn;
  bool _sfxOn = AudioService.isSfxOn;

  void _confirmResetProgress() {
    AudioService.playClick();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFE53935), size: 30),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'প্রগ্রেস রিসেট করবে?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFC62828),
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'সব স্টার এবং সম্পন্ন করা লেভেল মুছে যাবে এবং গেমটি একদম শুরু থেকে চালু হবে।',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF455A64),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              AudioService.playClick();
              Navigator.pop(ctx);
            },
            child: const Text(
              'না, থাক',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF546E7A),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ProgressService.resetAllProgress();
              AudioService.playPop();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'সব প্রগ্রেস সফলভাবে রিসেট করা হয়েছে!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Color(0xFF43A047),
                    duration: Duration(seconds: 2),
                  ),
                );
                setState(() {});
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'হ্যাঁ, মুছে ফেলো',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog() {
    AudioService.playClick();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.shield_rounded, color: Color(0xFF1E88E5), size: 28),
            SizedBox(width: 8),
            Text(
              'প্রাইভেসি পলিসি (Privacy Policy)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1565C0),
              ),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Text(
            '• "শব্দ মেলাই" সম্পূর্ণ শিশুদের উপযোগী একটি শিক্ষামূলক গেম।\n'
            '• এই অ্যাপটি শিশুদের কোনো ব্যক্তিগত তথ্য (নাম, ছবি, লোকেশন বা কন্টাক্ট) সংগ্রহ বা শেয়ার করে না।\n'
            '• খেলার প্রগ্রেস ও সাউন্ড সেটিংস শুধুমাত্র আপনার ডিভাইসেই (অফলাইনে) সংরক্ষিত থাকে।\n'
            '• অ্যাপটিতে শিশুদের জন্য ক্ষতিকর কোনো বিজ্ঞাপন বা এক্সটার্নাল ট্র্যাকার নেই।',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF37474F),
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              AudioService.playClick();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'বুঝেছি',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog() {
    AudioService.playClick();
    int selectedStars = 5;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: Colors.white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'অ্যাপটি কেমন লেগেছে?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFE65100),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'আপনার মতামত আমাদের আরও সুন্দর লেভেল তৈরিতে উৎসাহিত করবে!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF546E7A),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final active = index < selectedStars;
                    return GestureDetector(
                      onTap: () {
                        AudioService.playPop();
                        setDialogState(() {
                          selectedStars = index + 1;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          Icons.star_rounded,
                          size: 40,
                          color: active
                              ? const Color(0xFFFFB300)
                              : Colors.grey.shade300,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    AudioService.playClick();
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'আপনার মূল্যবান রেটিংয়ের জন্য অসংখ্য ধন্যবাদ! ❤️',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Color(0xFFFB8C00),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'রেটিং জমা দিন',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ব্যাকগ্রাউন্ড গ্রেডিয়েন্ট
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF81D4FA), Color(0xFFE1F5FE)],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // টপ বার
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          AudioService.playClick();
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB300),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFFE65100),
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                      Text(
                        LanguageService.tr(
                          'সেটিংস ও অভিভাবক কর্নার',
                          'Settings & Parents Corner',
                        ),
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE65100),
                          shadows: [
                            Shadow(
                              offset: Offset(-1, -1),
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      // সেটিংস স্ক্রিন থেকেও ভাষা পরিবর্তনের বাটন
                      GestureDetector(
                        onTap: () {
                          LanguageService.toggleLanguage();
                          setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFAB47BC),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(
                            LanguageService.isBangla
                                ? 'বাংলা ⇄ EN'
                                : 'EN ⇄ বাংলা',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // মেইন সেটিংস বডি (ল্যান্ডস্কেপ ২-কলাম লেআউট)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        // বাম পাশ: সাউন্ড কন্ট্রোল কার্ড
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFFFB300),
                                width: 3,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x22000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.music_note_rounded,
                                      color: Color(0xFFFF7043),
                                      size: 26,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'সাউন্ড সেটিংস',
                                      style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFFD84315),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                _buildToggleRow(
                                  icon: Icons.library_music_rounded,
                                  title: 'ব্যাকগ্রাউন্ড মিউজিক (BGM)',
                                  subtitle: 'হালকা কার্টুন মিউজিক',
                                  value: _bgmOn,
                                  activeColor: const Color(0xFF4CAF50),
                                  onChanged: (val) async {
                                    await AudioService.setBgm(val);
                                    setState(() => _bgmOn = val);
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildToggleRow(
                                  icon: Icons.record_voice_over_rounded,
                                  title: 'সাউন্ড ইফেক্ট ও ভয়েস (SFX)',
                                  subtitle: 'বাবল পপ ও বাংলা উচ্চারণ',
                                  value: _sfxOn,
                                  activeColor: const Color(0xFF29B6F6),
                                  onChanged: (val) async {
                                    await AudioService.setSfx(val);
                                    setState(() => _sfxOn = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 20),

                        // ডান পাশ: রিসেট প্রগ্রেস, প্রাইভেসি পলিসি ও রেটিং বাটন
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFF42A5F5),
                                width: 3,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x22000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildActionButton(
                                  icon: Icons.restart_alt_rounded,
                                  label: 'প্রগ্রেস রিসেট করো (Reset)',
                                  color: const Color(0xFFEF5350),
                                  shadowColor: const Color(0xFFC62828),
                                  onTap: _confirmResetProgress,
                                ),
                                _buildActionButton(
                                  icon: Icons.star_rate_rounded,
                                  label: 'অ্যাপটি রেটিং দিন (Rate Us)',
                                  color: const Color(0xFFFFB300),
                                  shadowColor: const Color(0xFFE65100),
                                  onTap: _showRatingDialog,
                                ),
                                _buildActionButton(
                                  icon: Icons.privacy_tip_rounded,
                                  label: 'প্রাইভেসি পলিসি (Privacy Policy)',
                                  color: const Color(0xFF26A69A),
                                  shadowColor: const Color(0xFF00695C),
                                  onTap: _showPrivacyPolicyDialog,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: activeColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: activeColor, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF263238),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF607D8B),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: activeColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color shadowColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// অভিভাবক যাচাইকরণ ডায়ালগ (Parental Gate)
class _ParentalGateDialog extends StatefulWidget {
  const _ParentalGateDialog();

  @override
  State<_ParentalGateDialog> createState() => _ParentalGateDialogState();
}

class _ParentalGateDialogState extends State<_ParentalGateDialog> {
  late int _a;
  late int _b;
  late int _correctAnswer;
  late List<int> _options;
  bool _wrongAttempt = false;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    final rnd = Random();
    _a = 2 + rnd.nextInt(7); // ২ থেকে ৮
    _b = 2 + rnd.nextInt(6); // ২ থেকে ৭
    _correctAnswer = _a + _b;

    final set = <int>{_correctAnswer};
    while (set.length < 4) {
      final candidate = _correctAnswer + rnd.nextInt(7) - 3;
      if (candidate > 0 && candidate != _correctAnswer) {
        set.add(candidate);
      }
    }
    _options = set.toList()..shuffle();
  }

  void _checkOption(int selected) {
    if (selected == _correctAnswer) {
      AudioService.playClick();
      Navigator.pop(context, true);
    } else {
      AudioService.playWrong();
      setState(() {
        _wrongAttempt = true;
        _generateQuestion();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final aBangla = ProgressService.toBanglaDigits(_a);
    final bBangla = ProgressService.toBanglaDigits(_b);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      child: Container(
        width: 390,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFFFB300), width: 4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 32),
                const Row(
                  children: [
                    Icon(Icons.lock_person_rounded, color: Color(0xFFE65100), size: 24),
                    SizedBox(width: 6),
                    Text(
                      'অভিভাবক যাচাইকরণ',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFE65100),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    AudioService.playClick();
                    Navigator.pop(context, false);
                  },
                  child: const Icon(
                    Icons.cancel_rounded,
                    color: Colors.grey,
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'সেটিংসে প্রবেশ করতে নিচের অঙ্কটির সঠিক উত্তর দিন:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF546E7A),
              ),
            ),
            const SizedBox(height: 12),

            // অঙ্কের প্রশ্ন বক্স
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFCA28), width: 2.5),
              ),
              child: Text(
                '$aBangla + $bBangla = কত?',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFD84315),
                ),
              ),
            ),

            if (_wrongAttempt) ...[
              const SizedBox(height: 6),
              const Text(
                'ভুল উত্তর! আবার চেষ্টা করুন।',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE53935),
                ),
              ),
            ],

            const SizedBox(height: 14),

            // ৪টি অপশন বাটন
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _options.map((opt) {
                return GestureDetector(
                  onTap: () => _checkOption(opt),
                  child: Container(
                    width: 64,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF42A5F5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF1565C0),
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        ProgressService.toBanglaDigits(opt),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
