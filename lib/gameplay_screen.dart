import 'dart:math';
import 'package:flutter/material.dart';
import '../models/word_puzzle_model.dart';
import '../services/audio_service.dart';
import '../services/language_service.dart';
import '../services/progress_service.dart';
import '../services/puzzle_service.dart';

class GameplayScreen extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;

  const GameplayScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen>
    with TickerProviderStateMixin {
  List<WordPuzzle> _puzzles = [];
  int _currentLevelIndex = 0;
  bool _isLoading = true;

  int _hearts = 3;
  int? _breakingHeartIndex;
  final List<String> _userSelectedTiles = [];
  List<bool> _tileUsedMask = [];

  // ১. ভুল উত্তরের জন্য Shake Animation Controller
  late AnimationController _shakeController;

  // ২. হার্ট ভেঙে যাওয়ার / ফেড হওয়ার অ্যানিমেশন কন্ট্রোলার
  late AnimationController _heartBreakController;

  // ৩. কনফেটি (Confetti / ঝালর) অ্যানিমেশন কন্ট্রোলার ও পার্টিকেল লিস্ট
  late AnimationController _confettiController;
  final List<_ConfettiParticle> _confettiParticles = [];
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    _heartBreakController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (mounted) {
            setState(() => _breakingHeartIndex = null);
          }
        }
      });

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _loadLevelData();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _heartBreakController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  // গেমপ্লের মাঝখানে ভাষা পরিবর্তন করলে (বাংলা <-> EN) বর্তমান লেভেলের টাইলস রিসেট ও নতুন ভাষায় উচ্চারণ হবে
  void _switchLanguageInGameplay() {
    LanguageService.toggleLanguage();
    setState(() {
      _resetLevelState();
    });
    if (_puzzles.isNotEmpty) {
      AudioService.playWordHint(_currentPuzzle.id);
    }
  }

  // কনফেটি বিস্ফোরণ শুরু করা
  void _triggerConfetti() {
    _confettiParticles.clear();
    const colors = [
      Color(0xFFFF1744),
      Color(0xFFFFB300),
      Color(0xFF00E676),
      Color(0xFF2979FF),
      Color(0xFFE040FB),
      Color(0xFFFF6D00),
      Color(0xFF00E5FF),
    ];
    for (int i = 0; i < 75; i++) {
      _confettiParticles.add(
        _ConfettiParticle(
          startX: 0.1 + _rnd.nextDouble() * 0.8,
          startY: -0.05 - _rnd.nextDouble() * 0.25,
          vx: (_rnd.nextDouble() - 0.5) * 0.45,
          vy: 0.55 + _rnd.nextDouble() * 0.75,
          size: 7.0 + _rnd.nextDouble() * 7.0,
          color: colors[_rnd.nextInt(colors.length)],
          rotationSpeed: (_rnd.nextDouble() - 0.5) * 10,
          isCircle: _rnd.nextBool(),
        ),
      );
    }
    _confettiController.forward(from: 0.0);
  }

  // ডেটা লোড ও ইনিশিয়ালাইজেশন
  Future<void> _loadLevelData() async {
    final data = await PuzzleService.getPuzzlesByCategory(widget.categoryId);
    setState(() {
      _puzzles = data;
      _isLoading = false;
      if (_puzzles.isNotEmpty) {
        _currentLevelIndex = ProgressService.getResumeLevelIndex(
          widget.categoryId,
          _puzzles.length,
        );
        _resetLevelState();
        AudioService.playWordHint(_currentPuzzle.id);
      }
    });
  }

  WordPuzzle get _currentPuzzle => _puzzles[_currentLevelIndex];

  void _resetLevelState() {
    _userSelectedTiles.clear();
    _tileUsedMask = List.filled(_currentPuzzle.jumbledTiles.length, false);
  }

  // নিচে থেকে অক্ষর সিলেক্ট করা
  void _selectTile(int index) {
    if (_shakeController.isAnimating) return;
    if (_tileUsedMask[index]) return;
    if (_userSelectedTiles.length >= _currentPuzzle.correctTiles.length) return;

    AudioService.playPop();

    setState(() {
      _tileUsedMask[index] = true;
      _userSelectedTiles.add(_currentPuzzle.jumbledTiles[index]);
    });

    if (_userSelectedTiles.length == _currentPuzzle.correctTiles.length) {
      _verifyAnswer();
    }
  }

  // উপরের ঘর থেকে ভুল অক্ষর ফেরত নেওয়া
  void _deselectTile(int selectedIndex) {
    if (_shakeController.isAnimating) return;
    if (selectedIndex >= _userSelectedTiles.length) return;

    AudioService.playPop();

    final tileToRemove = _userSelectedTiles[selectedIndex];
    setState(() {
      _userSelectedTiles.removeAt(selectedIndex);
      for (int i = 0; i < _currentPuzzle.jumbledTiles.length; i++) {
        if (_tileUsedMask[i] &&
            _currentPuzzle.jumbledTiles[i] == tileToRemove) {
          _tileUsedMask[i] = false;
          break;
        }
      }
    });
  }

  // উত্তর যাচাই
  void _verifyAnswer() {
    final answer = _userSelectedTiles.join('');
    if (answer == _currentPuzzle.correctWord) {
      ProgressService.completeLevel(
        categoryId: widget.categoryId,
        levelNumber: _currentLevelIndex + 1,
        starsEarned: 1,
        coinsEarned: 10,
      );
      setState(() {});
      _triggerConfetti();
      AudioService.playSuccessAndVoice(_currentPuzzle.id);
      _showSuccessDialog();
    } else {
      AudioService.playWrong();
      _shakeController.forward(from: 0.0);

      setState(() {
        _hearts--;
        _breakingHeartIndex = _hearts;
      });
      _heartBreakController.forward(from: 0.0);

      if (_hearts <= 0) {
        Future.delayed(const Duration(milliseconds: 550), () {
          if (mounted) _showGameOverDialog();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LanguageService.tr(
                'ভুল হয়েছে, আবার চেষ্টা করো!',
                'Oops! Wrong answer, try again!',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFFE53935),
            duration: const Duration(milliseconds: 1000),
          ),
        );
        Future.delayed(const Duration(milliseconds: 520), () {
          if (mounted) {
            setState(() {
              _resetLevelState();
            });
          }
        });
      }
    }
  }

  // পরবর্তী লেভেলে যাওয়া
  void _goToNextLevel() {
    AudioService.playClick();
    if (_currentLevelIndex < _puzzles.length - 1) {
      setState(() {
        _currentLevelIndex++;
        _resetLevelState();
      });
      AudioService.playWordHint(_currentPuzzle.id);
    } else {
      _triggerConfetti();
      AudioService.playVoice('category_complete');
      _showCategoryCompleteDialog();
    }
  }

  // সঠিক উত্তর ডায়ালগ
  void _showSuccessDialog() {
    final otherLangWord = LanguageService.isBangla
        ? _currentPuzzle.correctWordEn
        : _currentPuzzle.correctWordBn;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Stack(
        children: [
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: Colors.white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.stars_rounded,
                  color: Color(0xFFFFB300),
                  size: 72,
                ),
                const SizedBox(height: 6),
                Text(
                  LanguageService.isBangla
                      ? 'চমৎকার! এটা ${_currentPuzzle.correctWord}'
                      : 'Awesome! It is ${_currentPuzzle.correctWord}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 4),
                // দ্বিভাষিক শিক্ষা: অন্য ভাষায় কী বলে তাও দেখিয়ে দেওয়া
                Text(
                  LanguageService.isBangla
                      ? 'ইংরেজিতে: $otherLangWord'
                      : 'বাংলায়: $otherLangWord',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6A1B9A),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    LanguageService.tr(
                      '+১০ কয়েন  •  +১ স্টার ⭐',
                      '+10 Coins  •  +1 Star ⭐',
                    ),
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFE65100),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _goToNextLevel();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 10,
                    ),
                  ),
                  child: Text(
                    LanguageService.tr('পরবর্তী শব্দ', 'Next Word'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ডায়ালগের উপরেও রঙিন কনফেটি ঝালর পড়বে
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _confettiController,
              builder: (_, _) {
                if (!_confettiController.isAnimating) {
                  return const SizedBox.shrink();
                }
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: _ConfettiPainter(
                    particles: _confettiParticles,
                    progress: _confettiController.value,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // গেম ওভার ডায়ালগ
  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.sentiment_dissatisfied_rounded,
              color: Color(0xFFE53935),
              size: 70,
            ),
            const SizedBox(height: 8),
            Text(
              LanguageService.tr('সব হার্ট শেষ!', 'Out of Hearts!'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFFC62828),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text(LanguageService.tr('বের হও', 'Exit')),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _hearts = 3;
                      _resetLevelState();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(LanguageService.tr('আবার খেলো', 'Play Again')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // পুরো ক্যাটাগরি সম্পন্ন ডায়ালগ
  void _showCategoryCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              color: Color(0xFFFFB300),
              size: 80,
            ),
            const SizedBox(height: 8),
            Text(
              LanguageService.tr('অভিনন্দন!', 'Congratulations!'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFFE65100),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              LanguageService.isBangla
                  ? 'তুমি "${widget.categoryTitle}" ক্যাটাগরির সব লেভেল শেষ করেছ!'
                  : 'You completed all levels in "${widget.categoryTitle}"!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF455A64),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                LanguageService.tr('মেনুতে ফিরে যাও', 'Back to Menu'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFFB300)),
        ),
      );
    }

    if (_puzzles.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                LanguageService.tr(
                  'কোনো লেভেল পাওয়া যায়নি!',
                  'No levels found!',
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(LanguageService.tr('ফিরে যাও', 'Go Back')),
              ),
            ],
          ),
        ),
      );
    }

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
                _buildTopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        // বাম পাশে ছবি এবং উত্তরের ঘর
                        Expanded(flex: 5, child: _buildPictureAndAnswerArea()),
                        const SizedBox(width: 20),
                        // ডান পাশে অক্ষর টাইলস
                        Expanded(flex: 6, child: _buildTileGridArea()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // মেইন স্ক্রিনেও কনফেটি ওভারলে
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _confettiController,
              builder: (_, _) {
                if (!_confettiController.isAnimating) {
                  return const SizedBox.shrink();
                }
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: _ConfettiPainter(
                    particles: _confettiParticles,
                    progress: _confettiController.value,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    final isBn = LanguageService.isBangla;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ব্যাক বাটন
          GestureDetector(
            onTap: () {
              AudioService.playClick();
              Navigator.pop(context);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFFFB300),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Color(0xFFE65100), offset: Offset(0, 3)),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),

          // লেভেল নম্বর ব্যাজ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF42A5F5), width: 2),
            ),
            child: Text(
              isBn
                  ? 'লেভেল ${LanguageService.formatNumber(_currentLevelIndex + 1)}/${LanguageService.formatNumber(_puzzles.length)}'
                  : 'Level ${_currentLevelIndex + 1}/${_puzzles.length}',
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1565C0),
              ),
            ),
          ),

          // এক ক্লিকে বাংলা <-> ইংরেজি মোড সুইচ বাটন (একই ছবিতে "আম" <-> "MANGO")
          GestureDetector(
            onTap: _switchLanguageInGameplay,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFAB47BC), Color(0xFF8E24AA)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(color: Color(0xFF4A148C), offset: Offset(0, 3)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.translate_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isBn ? 'বাংলা ⇄ EN' : 'EN ⇄ বাংলা',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // হার্টস
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFF5252), width: 2),
            ),
            child: Row(
              children: List.generate(3, (index) {
                final isAlive = index < _hearts;
                final isBreaking = _breakingHeartIndex == index;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: AnimatedBuilder(
                    animation: _heartBreakController,
                    builder: (_, _) {
                      if (isBreaking && _heartBreakController.isAnimating) {
                        final t = _heartBreakController.value;
                        final scale = t < 0.35
                            ? 1.0 + (t / 0.35) * 0.48
                            : 1.48 - ((t - 0.35) / 0.65) * 0.48;
                        final color = Color.lerp(
                          const Color(0xFFFF1744),
                          Colors.grey.shade300,
                          t,
                        )!;
                        return Transform.scale(
                          scale: scale,
                          child: Icon(
                            t < 0.5
                                ? Icons.heart_broken_rounded
                                : Icons.favorite_rounded,
                            size: 21,
                            color: color,
                          ),
                        );
                      }

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          Icons.favorite_rounded,
                          key: ValueKey<bool>(isAlive),
                          size: 21,
                          color: isAlive
                              ? const Color(0xFFFF1744)
                              : Colors.grey.shade300,
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ),

          // কয়েন ও স্টার স্কোর
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFB300), width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.monetization_on_rounded,
                      color: Color(0xFFFFB300),
                      size: 18,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      LanguageService.formatNumber(ProgressService.totalCoins),
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFE65100),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFF7043), width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      color: Color(0xFFFF7043),
                      size: 18,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      LanguageService.formatNumber(ProgressService.totalStars),
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFD84315),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPictureAndAnswerArea() {
    final slotCount = _currentPuzzle.correctTiles.length;
    // যদি ইংরেজি শব্দে অক্ষর বেশি হয় (যেমন JACKFRUIT = 9টি অক্ষর), তখন স্লট সাইজ অটোমেটিক ছোট হবে যেন ওভারফ্লো না করে
    final double slotSize = slotCount > 6 ? 34.0 : (slotCount > 4 ? 40.0 : 46.0);
    final double slotFontSize = slotCount > 6 ? 17.0 : (slotCount > 4 ? 19.0 : 22.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ফ্রেমের ভেতর কার্টুন ছবি (ট্যাপ করলে আবার শব্দের উচ্চারণ শোনা যাবে)
        GestureDetector(
          onTap: () => AudioService.playWordHint(_currentPuzzle.id),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 140,
                height: 115,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFB300),
                    width: 3.5,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFFE65100), offset: Offset(0, 4)),
                  ],
                ),
                child: _buildImageWidget(_currentPuzzle.imageUrl),
              ),
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7043),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.volume_up_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // উত্তরের স্লট (ভুল হলে ডানে-বামে কেঁপে উঠবে - Shake Animation)
        AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            final t = _shakeController.value;
            final dx = sin(t * pi * 6) * (1.0 - t) * 14.0;
            final isShaking = _shakeController.isAnimating;

            return Transform.translate(
              offset: Offset(dx, 0),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 5,
                runSpacing: 5,
                children: List.generate(slotCount, (index) {
                  final hasLetter = index < _userSelectedTiles.length;
                  return GestureDetector(
                    onTap: hasLetter ? () => _deselectTile(index) : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: slotSize,
                      height: slotSize,
                      decoration: BoxDecoration(
                        color: isShaking
                            ? const Color(0xFFFFCDD2)
                            : (hasLetter
                                  ? const Color(0xFFFFF9C4)
                                  : Colors.white.withValues(alpha: 0.6)),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: isShaking
                              ? const Color(0xFFE53935)
                              : (hasLetter
                                    ? const Color(0xFFFBC02D)
                                    : Colors.white),
                          width: 2.5,
                        ),
                        boxShadow: hasLetter
                            ? [
                                BoxShadow(
                                  color: isShaking
                                      ? const Color(0xFFC62828)
                                      : const Color(0xFFF57F17),
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          hasLetter ? _userSelectedTiles[index] : '',
                          style: TextStyle(
                            fontSize: slotFontSize,
                            fontWeight: FontWeight.w900,
                            color: isShaking
                                ? const Color(0xFFC62828)
                                : const Color(0xFFE65100),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTileGridArea() {
    final tileCount = _currentPuzzle.jumbledTiles.length;
    final double tileSize = tileCount > 7 ? 48.0 : 54.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: List.generate(tileCount, (index) {
              final isUsed = _tileUsedMask[index];
              final letter = _currentPuzzle.jumbledTiles[index];

              return GestureDetector(
                onTap: isUsed ? null : () => _selectTile(index),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: isUsed ? 0.0 : 1.0,
                  child: Container(
                    width: tileSize,
                    height: tileSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFF42A5F5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF1565C0),
                          offset: Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        letter,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          IconButton(
            onPressed: () {
              AudioService.playClick();
              setState(_resetLevelState);
            },
            icon: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFFE65100),
              size: 26,
            ),
            tooltip: LanguageService.tr('সব মুছো', 'Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) =>
            const Icon(Icons.broken_image, size: 45, color: Colors.grey),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) =>
          const Icon(Icons.image, size: 45, color: Colors.grey),
    );
  }
}

/// কনফেটি পার্টিকেল ডেটা মডেল
class _ConfettiParticle {
  final double startX;
  final double startY;
  final double vx;
  final double vy;
  final double size;
  final Color color;
  final double rotationSpeed;
  final bool isCircle;

  const _ConfettiParticle({
    required this.startX,
    required this.startY,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotationSpeed,
    required this.isCircle,
  });
}

/// কাস্টম কনফেটি পেইন্টার (রঙিন কাগজের ঝালর পড়ার অ্যানিমেশন)
class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  const _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final opacity = (1.0 - (progress - 0.65).clamp(0.0, 0.35) / 0.35);

    for (final p in particles) {
      final x =
          (p.startX +
              p.vx * progress +
              sin(progress * 10 + p.startX * 15) * 0.025) *
          size.width;
      final y =
          (p.startY + p.vy * progress + 0.35 * progress * progress) *
          size.height;

      if (y < -20 || y > size.height + 20) continue;

      paint.color = p.color.withValues(alpha: opacity);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * p.rotationSpeed);

      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size * 0.5, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size,
              height: p.size * 0.6,
            ),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
