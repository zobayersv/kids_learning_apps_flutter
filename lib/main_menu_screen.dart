import 'package:flutter/material.dart';
import 'package:loadshad/category_screen.dart';
import 'package:loadshad/services/audio_service.dart';
import 'package:loadshad/services/language_service.dart';
import 'package:loadshad/services/progress_service.dart';
import 'package:loadshad/settings_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // ব্যাকগ্রাউন্ড মিউজিক ও স্বাগতম ভয়েসওভার শুরু
    AudioService.startBgm();
    AudioService.playVoice('welcome');

    // প্লে বাটনের মৃদু পালস/বাউন্স অ্যানিমেশন
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ValueListenableBuilder<AppLanguage>(
      valueListenable: LanguageService.notifier,
      builder: (context, lang, _) {
        final isBn = lang == AppLanguage.bn;

        return Scaffold(
          body: Stack(
            children: [
              // ১. কার্টুন ব্যাকগ্রাউন্ড (নীল আকাশ + সবুজ পাহাড়)
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF81D4FA), Color(0xFFB3E5FC)],
                  ),
                ),
              ),

              // ব্যাকগ্রাউন্ডের বড় সবুজ কার্টুন পাহাড়
              Positioned(
                bottom: -size.height * 0.25,
                left: -80,
                right: -80,
                child: Container(
                  height: size.height * 0.6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF81C784),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(600),
                    ),
                    border: Border.all(
                      color: const Color(0xFF66BB6A),
                      width: 6,
                    ),
                  ),
                ),
              ),

              // ফ্লোটিং ক্লাউড
              Positioned(top: 20, left: 60, child: _buildCloud(80)),
              Positioned(top: 40, right: 100, child: _buildCloud(65)),

              // ২. টপ হেডার বার (কয়েন, স্টার, ভাষা সুইচ, সাউন্ড এবং সেটিংস বাটন)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // কয়েন ও স্টার ব্যানার
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // কয়েন ব্যাজ
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: const Color(0xFFFFB300),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.monetization_on_rounded,
                                  color: Color(0xFFFFB300),
                                  size: 24,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  LanguageService.formatNumber(
                                    ProgressService.totalCoins,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFE65100),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // স্টার ব্যাজ
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: const Color(0xFFFF7043),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.stars_rounded,
                                  color: Color(0xFFFF7043),
                                  size: 24,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  LanguageService.formatNumber(
                                    ProgressService.totalStars,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFD84315),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // ডান দিক: দ্বিভাষিক সুইচ (বাংলা <-> EN) + সাউন্ড + সেটিংস
                      Row(
                        children: [
                          _buildLanguageSwitchPill(isBn),
                          const SizedBox(width: 10),
                          _buildCircularButton(
                            icon: AudioService.isSoundOn
                                ? Icons.volume_up_rounded
                                : Icons.volume_off_rounded,
                            color: const Color(0xFF29B6F6),
                            shadowColor: const Color(0xFF0288D1),
                            onTap: () async {
                              await AudioService.toggleSound();
                              setState(() {});
                            },
                          ),
                          const SizedBox(width: 10),
                          _buildCircularButton(
                            icon: Icons.settings_rounded,
                            color: const Color(0xFFFF7043),
                            shadowColor: const Color(0xFFD84315),
                            onTap: () {
                              AudioService.playClick();
                              SettingsScreen.openWithParentalGate(
                                context,
                                onClosed: () {
                                  if (mounted) setState(() {});
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ৩. মূল কনটেন্ট (টাইটেল + বাউন্সি প্লে বাটন)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 15),
                    // কার্টুন লোগো টেক্সট
                    Text(
                      LanguageService.tr('শব্দ মেলাই', 'WORD MATCH'),
                      style: TextStyle(
                        fontSize: isBn ? 48 : 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: const Color(0xFFFF6F00),
                        shadows: [
                          Shadow(
                            offset: const Offset(3, 4),
                            blurRadius: 0,
                            color: Colors.brown.shade900.withValues(
                              alpha: 0.35,
                            ),
                          ),
                          const Shadow(
                            offset: Offset(-2, -2),
                            blurRadius: 0,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        LanguageService.tr(
                          'বাংলা ও ইংরেজি শব্দ শেখার মজার খেলা',
                          'Fun Bilingual Word Learning Game (বাংলা & English)',
                        ),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // অ্যানিমেটেড কার্টুনিশ প্লে বাটন (3D বাবল স্টাইল)
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: GestureDetector(
                        onTap: () async {
                          AudioService.playClick();
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CategoryScreen(),
                            ),
                          );
                          if (mounted) setState(() {});
                        },
                        child: Container(
                          width: 195,
                          height: 68,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
                            ),
                            borderRadius: BorderRadius.circular(35),
                            border: Border.all(color: Colors.white, width: 3.5),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFF2E7D32),
                                offset: Offset(0, 7),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.play_arrow_rounded,
                                  size: 42,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  LanguageService.tr('খেলো', 'PLAY'),
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(1, 2),
                                        blurRadius: 2,
                                        color: Colors.black26,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // এক ক্লিকে বাংলা <-> ইংরেজি টগল পিল বাটন
  Widget _buildLanguageSwitchPill(bool isBn) {
    return GestureDetector(
      onTap: () {
        LanguageService.toggleLanguage();
        AudioService.playVoice('welcome');
      },
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFFAB47BC), width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF7B1FA2),
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isBn ? const Color(0xFFAB47BC) : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                'বাংলা',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: isBn ? Colors.white : const Color(0xFF7B1FA2),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: !isBn ? const Color(0xFFAB47BC) : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                'EN',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: !isBn ? Colors.white : const Color(0xFF7B1FA2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // রাউন্ড কার্টুন বাটন উইজেট
  Widget _buildCircularButton({
    required IconData icon,
    required Color color,
    required Color shadowColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildCloud(double size) {
    return Icon(
      Icons.cloud_rounded,
      size: size,
      color: Colors.white.withValues(alpha: 0.85),
    );
  }
}
