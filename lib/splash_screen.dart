import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loadshad/main_menu_screen.dart';
import 'package:loadshad/services/language_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;
  double _loadingProgress = 0.0;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();

    // লোগো বাউন্স অ্যানিমেশন
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.05).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOutBack),
    );

    // ফেক প্রগ্রেস বার লোডিং (লোকাল ডেটা ইনিশিয়ালাইজেশন টাইমিং)
    _progressTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        if (_loadingProgress < 1.0) {
          _loadingProgress += 0.02;
        } else {
          _progressTimer?.cancel();
          _navigateToHome();
        }
      });
    });
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainMenuScreen()),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ১. কার্টুন ব্যাকগ্রাউন্ড (আকাশ ও ঘাস)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF81D4FA), // হালকা আকাশী
                  Color(0xFFE1F5FE),
                ],
              ),
            ),
          ),

          // কার্টুন পাহাড়/ঘাস ডেকোরেশন (নিচে)
          Positioned(
            bottom: -size.height * 0.15,
            left: -50,
            right: -50,
            child: Container(
              height: size.height * 0.35,
              decoration: const BoxDecoration(
                color: Color(0xFF81C784), // কার্টুন ঘাস সবুজ
                borderRadius: BorderRadius.vertical(top: Radius.circular(500)),
              ),
            ),
          ),

          // ২. ব্যাকগ্রাউন্ড কার্টুন ক্লাউড
          Positioned(top: 25, left: 50, child: _buildCloud(size: 70)),
          Positioned(top: 40, right: 80, child: _buildCloud(size: 90)),

          // ৩. সেন্টার কনটেন্ট (লোগো ও কার্টুন ক্যারেক্টার/আইকন)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 25,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.pets_rounded, // এখানে কার্টুন ক্যারেক্টার/ইমেজ বসবে
                      size: 75,
                      color: Color(0xFFFF7043),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // কার্টুন টাইটেল (বর্ডার শ্যাডো সহ)
                Text(
                  LanguageService.tr('শব্দ মেলাই', 'Word Match'),
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: const Color(0xFFFF5722),
                    shadows: [
                      Shadow(
                        offset: const Offset(3, 3),
                        blurRadius: 0,
                        color: Colors.brown.shade800.withValues(alpha: 0.3),
                      ),
                      const Shadow(
                        offset: Offset(-2, -2),
                        blurRadius: 0,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  LanguageService.tr(
                    'ছবি দেখে বর্ণ সাজাও!',
                    'Look at the picture & spell the word!',
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF37474F),
                  ),
                ),

                const SizedBox(height: 25),

                // ৪. কার্টুনিশ প্রগ্রেস বার
                Container(
                  width: size.width * 0.45,
                  height: 20,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFFA000),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: LinearProgressIndicator(
                      value: _loadingProgress.clamp(0.0, 1.0),
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFFFB300), // উজ্জ্বল হলুদ-কমলা
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
  }

  // ক্লাউড উইজেট হেল্পার
  Widget _buildCloud({required double size}) {
    return Icon(
      Icons.cloud_rounded,
      size: size,
      color: Colors.white.withOpacity(0.85),
    );
  }
}
