// ignore_for_file: unused_element

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:loadshad/gameplay_screen.dart';
import 'package:loadshad/services/audio_service.dart';
import 'package:loadshad/services/language_service.dart';
import 'package:loadshad/services/progress_service.dart';
import 'package:loadshad/settings_screen.dart';

class CategoryItem {
  final String id;
  final String titleBn;
  final String titleEn;
  final String subtitleBn;
  final String subtitleEn;
  final IconData icon;
  final Color iconColor;
  final List<Color> gradientColors;
  final int totalLevels;
  final int completedLevels;
  final bool isLocked;

  const CategoryItem({
    required this.id,
    required this.titleBn,
    required this.titleEn,
    required this.subtitleBn,
    required this.subtitleEn,
    required this.icon,
    required this.iconColor,
    required this.gradientColors,
    required this.totalLevels,
    required this.completedLevels,
    this.isLocked = false,
  });

  String get title => LanguageService.isBangla ? titleBn : titleEn;
  String get subtitle => LanguageService.isBangla ? subtitleBn : subtitleEn;
}

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ScrollController _scrollController = ScrollController();
  int _selectedNavIndex = 0;

  final List<CategoryItem> categories = const [
    CategoryItem(
      id: 'fruits',
      titleBn: 'ফলমূল',
      titleEn: 'Fruits',
      subtitleBn: 'তথ্য ও সংখ্যার জগৎ',
      subtitleEn: 'Sweet & healthy fruits',
      icon: Icons.calculate_rounded,
      iconColor: Color(0xFF1976D2),
      gradientColors: [Color(0xFFFFA726), Color(0xFFFB8C00)],
      totalLevels: 5,
      completedLevels: 0,
    ),
    CategoryItem(
      id: 'animals',
      titleBn: 'পশুপাখি',
      titleEn: 'Animals',
      subtitleBn: 'প্রকৃতির বন্ধুদের সম্পর্কে জানো',
      subtitleEn: 'Know nature\'s friends',
      icon: Icons.pets_rounded,
      iconColor: Color(0xFF388E3C),
      gradientColors: [Color(0xFF7CB342), Color(0xFF43A047)],
      totalLevels: 3,
      completedLevels: 0,
    ),
    CategoryItem(
      id: 'flowers',
      titleBn: 'ফুল',
      titleEn: 'Flowers',
      subtitleBn: 'ফুলের পৃথিবী চিনো',
      subtitleEn: 'Explore the world of flowers',
      icon: Icons.local_florist_rounded,
      iconColor: Color(0xFFD81B60),
      gradientColors: [Color(0xFFEC407A), Color(0xFFAB47BC)],
      totalLevels: 2,
      completedLevels: 0,
    ),
    CategoryItem(
      id: 'vegetables',
      titleBn: 'শাকসবজি',
      titleEn: 'Vegetables',
      subtitleBn: 'সুস্থ জীবনের জন্য জানো',
      subtitleEn: 'Learn for a healthy life',
      icon: Icons.eco_rounded,
      iconColor: Color(0xFF00897B),
      gradientColors: [Color(0xFF26C6DA), Color(0xFF00897B)],
      totalLevels: 3,
      completedLevels: 0,
      isLocked: false,
    ),
    CategoryItem(
      id: 'fishes',
      titleBn: 'মাছ',
      titleEn: 'Fishes',
      subtitleBn: 'নদী ও সাগরের মাছ চিনো',
      subtitleEn: 'Discover river & sea fishes',
      icon: Icons.set_meal_rounded,
      iconColor: Color(0xFF1E88E5),
      gradientColors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
      totalLevels: 2,
      completedLevels: 0,
      isLocked: false,
    ),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int get _totalChapters =>
      categories.fold(0, (sum, item) => sum + item.totalLevels);

  int get _completedChapters => categories.fold(
    0,
    (sum, item) =>
        sum +
        ProgressService.getCompletedLevels(
          item.id,
          defaultVal: item.completedLevels,
        ),
  );

  void _startQuickPlay() {
    AudioService.playClick();
    // যে ক্যাটাগরিতে এখনো লেভেল বাকি আছে সেখানে নিয়ে যাবে, সব শেষ হলে প্রথমটাতে যাবে
    CategoryItem target = categories.first;
    for (final cat in categories) {
      final done = ProgressService.getCompletedLevels(cat.id);
      if (done < cat.totalLevels) {
        target = cat;
        break;
      }
    }
    _openCategory(target, false);
  }

  void _openCategory(CategoryItem item, bool isLocked) {
    if (isLocked) {
      AudioService.playWrong();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LanguageService.tr(
              'আগের ক্যাটাগরির লেভেল শেষ করে এটি আনলক করো!',
              'Complete previous category levels to unlock!',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFD84315),
          duration: const Duration(milliseconds: 1500),
        ),
      );
      return;
    }

    AudioService.playClick();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            GameplayScreen(categoryId: item.id, categoryTitle: item.title),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _scrollRight() {
    AudioService.playClick();
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;
    final next = (current + 200).clamp(0.0, maxScroll);
    _scrollController.animateTo(
      next >= maxScroll && current >= maxScroll - 10 ? 0.0 : next,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: LanguageService.notifier,
      builder: (context, lang, _) {
        final isBn = lang == AppLanguage.bn;

        return Scaffold(
          backgroundColor: const Color(0xFFF3F8FF),
          body: Stack(
            children: [
              // ১. সফট প্যাস্টেল ব্যাকগ্রাউন্ড ওয়েভ এবং কর্নারের পাতা ডেকোরেশন
              _buildBackgroundDecorations(),

              // ২. মেইন ড্যাশবোর্ড কনটেন্ট
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    children: [
                      // টপ হেডার বার
                      _buildTopHeader(isBn),
                      const SizedBox(height: 6),

                      // মাঝের মেইন ভিউ (নেভিগেশন ট্যাব অনুযায়ী অথবা ড্যাশবোর্ড)
                      Expanded(child: _buildActiveTabBody(isBn)),

                      const SizedBox(height: 6),

                      // নিচের সাদা পিল বটম নেভিগেশন বার
                      _buildBottomNavBar(isBn),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveTabBody(bool isBn) {
    if (_selectedNavIndex == 1) {
      return _buildProgressTabView(isBn);
    } else if (_selectedNavIndex == 2) {
      return _buildRewardsTabView(isBn);
    } else if (_selectedNavIndex == 4) {
      return _buildAboutTabView(isBn);
    }

    // ডিফল্ট হোম ড্যাশবোর্ড (হিরো ব্যানার + ৪টি রঙিন ক্যাটাগরি কার্ড)
    return Column(
      children: [
        // হিরো ব্যানার (শিখি, এগিয়ে যাই! + আমার অগ্রগতি কার্ড)
        Expanded(flex: 42, child: _buildHeroBanner(isBn)),
        const SizedBox(height: 8),
        // ৪টি রঙিন ক্যাটাগরি কার্ড + ডানদিকের স্ক্রল অ্যারো বাটন
        Expanded(flex: 58, child: _buildCategoryCardsSection(isBn)),
      ],
    );
  }

  // ==================== ১. টপ হেডার বার ====================
  Widget _buildTopHeader(bool isBn) {
    return Row(
      children: [
        // বাম দিকে নীল গ্র্যাজুয়েশন ক্যাপ ও বই আইকন (ট্যাপ করলে মেইন মেনুতে ফিরে যাবে)
        GestureDetector(
          onTap: () {
            AudioService.playClick();
            Navigator.maybePop(context);
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2979FF), Color(0xFF1565C0)],
              ),
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1565C0).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 6,
                  child: Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                Positioned(
                  bottom: 5,
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // টাইটেল ও সাবটাইটেল
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LanguageService.tr('ক্যাটাগরি বাছাই করো', 'Choose Category'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0D1B4C),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                LanguageService.tr(
                  'তোমার পছন্দের ক্যাটাগরি নির্বাচন করো',
                  'Select your favorite learning category',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5C6BC0),
                ),
              ),
            ],
          ),
        ),

        // ডান দিকের পিল বাটনসমূহ: ভাষা সুইচ, কয়েন, স্টার, প্রোফাইল
        // ১. ভাষা সুইচ পিল (🌐 বাংলা ⇄ EN ⌄)
        GestureDetector(
          onTap: LanguageService.toggleLanguage,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.language_rounded,
                  size: 17,
                  color: Color(0xFF1A237E),
                ),
                const SizedBox(width: 6),
                Text(
                  isBn ? 'বাংলা ⇄ EN' : 'EN ⇄ বাংলা',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 17,
                  color: Color(0xFF1A237E),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // ২. কয়েন পিল ($ ১৮০)
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFB300),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '\$',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                LanguageService.formatNumber(ProgressService.totalCoins),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0D1B4C),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // ৩. স্টার পিল (⭐ ৭)
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFB300),
                size: 21,
              ),
              const SizedBox(width: 4),
              Text(
                LanguageService.formatNumber(ProgressService.totalStars),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0D1B4C),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // ৪. প্রোফাইল অবতার বাটন
        GestureDetector(
          onTap: () {
            AudioService.playClick();
            setState(() => _selectedNavIndex = 1);
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFF5C6BC0),
              size: 21,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== ২. হিরো ব্যানার (bannar.png + আমার অগ্রগতি) ====================
  Widget _buildHeroBanner(bool isBn) {
    final total = _totalChapters;
    final done = _completedChapters;
    final double percent = total > 0 ? (done / total).clamp(0.0, 1.0) : 0.68;
    final int displayPercent = done == 0 ? 68 : (percent * 100).round();
    final int displayTotal = done == 0 ? 24 : total;
    final int displayDone = done == 0 ? 16 : done;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF29B6F6).withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ১. আপনার দেওয়া আসল ব্যানার ইমেজ (assets/images/apps_image/bannar.png)
            // এতে ক্লিক করলেও "চলুন শুরু করি" গেমপ্লে ওপেন হবে
            GestureDetector(
              onTap: _startQuickPlay,
              child: Image.asset(
                'assets/images/apps_image/bannar.png',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.fill,
              ),
            ),

            // ২. ডান পাশে সাদা "আমার অগ্রগতি" কার্ড
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                child: Container(
                  width: 215,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // বাম কলাম: "আমার অগ্রগতি" + সার্কুলার রিং
                      Expanded(
                        flex: 5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              LanguageService.tr('আমার অগ্রগতি', 'My Progress'),
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A237E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 54,
                              height: 54,
                              child: CustomPaint(
                                painter: _ProgressRingPainter(
                                  progress: displayPercent / 100.0,
                                ),
                                child: Center(
                                  child: Text(
                                    '$displayPercent%',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0D1B4C),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ডিভাইডার লাইন
                      Container(
                        width: 1,
                        height: 55,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        color: Colors.blueGrey.shade100,
                      ),

                      // ডান কলাম: মোট অধ্যায় ও সম্পন্ন সংখ্যা
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              LanguageService.tr(
                                'মোট অধ্যায়',
                                'Total Chapters',
                              ),
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF546E7A),
                              ),
                            ),
                            Text(
                              isBn
                                  ? '${LanguageService.formatNumber(displayTotal)} টি'
                                  : '$displayTotal',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0D1B4C),
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              LanguageService.tr('সম্পন্ন', 'Completed'),
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF546E7A),
                              ),
                            ),
                            Text(
                              isBn
                                  ? '${LanguageService.formatNumber(displayDone)} টি'
                                  : '$displayDone',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0D1B4C),
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ৩. ৪টি রঙিন ক্যাটাগরি কার্ড সেকশন ====================
  Widget _buildCategoryCardsSection(bool isBn) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // স্ক্রিনে একসাথে ৪টি কার্ড সমানভাবে দেখাবে এবং ডানপাশে স্ক্রল অ্যারো থাকবে
        final cardWidth = ((constraints.maxWidth - (3 * 12)) / 4).clamp(
          145.0,
          220.0,
        );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = categories[index];
                final prevId = index > 0 ? categories[index - 1].id : null;
                final unlocked = ProgressService.isCategoryUnlocked(
                  categoryIndex: index,
                  previousCategoryId: prevId,
                  defaultLocked: item.isLocked,
                );
                return SizedBox(
                  width: cardWidth,
                  child: _buildDashboardCategoryCard(item, !unlocked),
                );
              },
            ),

            // ডান পাশের সাদা গোল অ্যারো বাটন (>)
            Positioned(
              right: -6,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _scrollRight,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF1A237E),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDashboardCategoryCard(CategoryItem item, bool isLocked) {
    return GestureDetector(
      onTap: () => _openCategory(item, isLocked),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLocked
                ? [Colors.grey.shade400, Colors.grey.shade600]
                : item.gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: item.gradientColors.last.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // হালকা ওয়াটারমার্ক প্যাটার্ন ও নিচের ওয়েভ
              Positioned(
                bottom: -25,
                left: -20,
                right: -20,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              ..._buildCardWatermarks(item.id),

              // নিচের ডান কোণায় সুন্দর কার্টুন ইলাস্ট্রেশন (কুকুরছানা, জবা ফুল, সবজি ইত্যাদি)
              Positioned(
                right: 4,
                bottom: 2,
                child: _buildCornerIllustration(item.id),
              ),

              // মূল কার্ড কনটেন্ট
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // সাদা বৃত্তাকার আইকন
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _buildCategoryTopIcon(item, isLocked),
                      ),
                    ),

                    // ক্যাটাগরি নাম ও সাবটাইটেল
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                        ),
                      ],
                    ),

                    // সাদা পিল বাটন "শুরু করো ->"
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLocked
                                ? LanguageService.tr('লক করা', 'Locked')
                                : LanguageService.tr('শুরু করো', 'Start'),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1A237E),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            isLocked
                                ? Icons.lock_rounded
                                : Icons.arrow_forward_rounded,
                            size: 13,
                            color: const Color(0xFF1A237E),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== ৪. নিচের সাদা পিল বটম নেভিগেশন বার ====================
  Widget _buildBottomNavBar(bool isBn) {
    return Container(
      height: 46,
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            index: 0,
            icon: Icons.home_rounded,
            label: LanguageService.tr('হোম', 'Home'),
          ),
          _buildNavItem(
            index: 1,
            icon: Icons.bar_chart_rounded,
            label: LanguageService.tr('আমার অগ্রগতি', 'My Progress'),
          ),
          // _buildNavItem(
          //   index: 2,
          //   icon: Icons.emoji_events_rounded,
          //   label: LanguageService.tr('পুরস্কার', 'Rewards'),
          // ),
          _buildNavItem(
            index: 2,
            icon: Icons.settings_rounded,
            label: LanguageService.tr('সেটিংস', 'Settings'),
          ),
          _buildNavItem(
            index: 3,
            icon: Icons.info_rounded,
            label: LanguageService.tr('সম্পর্কে', 'About'),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedNavIndex == index;

    return GestureDetector(
      onTap: () {
        AudioService.playClick();
        if (index == 3) {
          // সেটিংস ট্যাবে চাপলে প্যারেন্টাল গেটসহ সেটিংস স্ক্রিন ওপেন হবে
          SettingsScreen.openWithParentalGate(
            context,
            onClosed: () {
              if (mounted) setState(() => _selectedNavIndex = 0);
            },
          );
          return;
        }
        setState(() => _selectedNavIndex = index);
      },
      child: isSelected
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF42A5F5), Color(0xFF2979FF)],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2979FF).withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: const Color(0xFF78909C), size: 18),
                  const SizedBox(height: 1),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF607D8B),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ==================== ট্যাব ভিউসমূহ (আমার অগ্রগতি, পুরস্কার, সম্পর্কে) ====================
  Widget _buildProgressTabView(bool isBn) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LanguageService.tr(
                  '📊 ক্যাটাগরি অনুযায়ী তোমার অগ্রগতি',
                  '📊 Your Progress by Category',
                ),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0D1B4C),
                ),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _selectedNavIndex = 0),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: Text(LanguageService.tr('ড্যাশবোর্ডে ফিরুন', 'Back')),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final cat = categories[i];
                final done = ProgressService.getCompletedLevels(cat.id);
                final progress = (done / cat.totalLevels).clamp(0.0, 1.0);
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F9FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(cat.icon, color: cat.iconColor, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: Text(
                          cat.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0D1B4C),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation(
                              cat.gradientColors.first,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${LanguageService.formatNumber(done)}/${LanguageService.formatNumber(cat.totalLevels)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0D1B4C),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsTabView(bool isBn) {
    final stars = ProgressService.totalStars;
    final coins = ProgressService.totalCoins;
    final badges = [
      ('🌟', LanguageService.tr('নতুন শিক্ষার্থী', 'Beginner Learner'), true),
      (
        '🍎',
        LanguageService.tr('ফলমূল চ্যাম্পিয়ন', 'Fruits Champion'),
        ProgressService.getCompletedLevels('fruits') >= 3,
      ),
      (
        '🐯',
        LanguageService.tr('পশুপাখি বন্ধু', 'Animal Friend'),
        ProgressService.getCompletedLevels('animals') >= 2,
      ),
      ('🏆', LanguageService.tr('শব্দ মাস্টার', 'Word Master'), stars >= 5),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            LanguageService.tr(
              '🏆 তোমার অর্জিত পুরস্কার ও ব্যাজ',
              '🏆 Your Earned Rewards & Badges',
            ),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0D1B4C),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            LanguageService.tr(
              'মোট কয়েন: ${LanguageService.formatNumber(coins)}  •  মোট স্টার: ${LanguageService.formatNumber(stars)}',
              'Total Coins: $coins  •  Total Stars: $stars',
            ),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE65100),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: badges.map((b) {
                final unlocked = b.$3;
                return Container(
                  width: 130,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: unlocked
                        ? const Color(0xFFFFF8E1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: unlocked
                          ? const Color(0xFFFFB300)
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        unlocked ? b.$1 : '🔒',
                        style: const TextStyle(fontSize: 34),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        b.$2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: unlocked
                              ? const Color(0xFF0D1B4C)
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTabView(bool isBn) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.school_rounded, size: 48, color: Color(0xFF2979FF)),
          const SizedBox(height: 8),
          Text(
            LanguageService.tr(
              'শব্দ মেলাই - দ্বিভাষিক শিক্ষামূলক গেম',
              'Word Match - Bilingual Kids Learning Game',
            ),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0D1B4C),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            LanguageService.tr(
              'ছোট সোনামণিদের খেলার ছলে বাংলা ও ইংরেজি বানান, উচ্চারণ এবং ছবি চেনার একটি আনন্দময় মাধ্যম।',
              'A fun interactive way for children to learn Bangla & English spelling, pronunciation, and objects.',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF546E7A),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== গ্রাফিক্স ও ইলাস্ট্রেশন হেল্পার ====================
  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        // উপরের বাম পাশের হালকা আকাশী ওয়েভ শেপ
        Positioned(
          top: -80,
          left: -60,
          child: Container(
            width: 380,
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFFDFF0FF).withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(200),
            ),
          ),
        ),
        // নিচের বাম কোণার টিল পাতা
        Positioned(
          bottom: -10,
          left: -10,
          child: Transform.rotate(
            angle: 0.4,
            child: Icon(
              Icons.spa_rounded,
              size: 70,
              color: const Color(0xFF4DB6AC).withValues(alpha: 0.35),
            ),
          ),
        ),
        // নিচের ডান কোণার টিল পাতা
        Positioned(
          bottom: -10,
          right: -10,
          child: Transform.rotate(
            angle: -0.4,
            child: Icon(
              Icons.spa_rounded,
              size: 70,
              color: const Color(0xFF4DB6AC).withValues(alpha: 0.35),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBooksAndCapIllustration() {
    return SizedBox(
      width: 105,
      height: 82,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // নিচের নীল বই
          Positioned(
            bottom: 0,
            child: Container(
              width: 92,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: const Color(0xFF0D47A1), width: 1.5),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 4),
              child: Container(
                width: 72,
                height: 11,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          // মাঝের কমলা বই
          Positioned(
            bottom: 18,
            child: Container(
              width: 82,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFFFF7043),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: const Color(0xFFE65100), width: 1.5),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 4),
              child: Container(
                width: 64,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          // উপরের গ্র্যাজুয়েশন ক্যাপ
          Positioned(
            top: 0,
            child: Icon(
              Icons.school_rounded,
              size: 52,
              color: const Color(0xFF1A237E),
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowingBulb() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFEE58).withValues(alpha: 0.65),
            blurRadius: 16,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Icon(
        Icons.lightbulb_rounded,
        color: Color(0xFFFFD600),
        size: 34,
      ),
    );
  }

  Widget _buildCategoryTopIcon(CategoryItem item, bool isLocked) {
    if (isLocked) {
      return const Icon(Icons.lock_rounded, color: Colors.grey, size: 28);
    }
    if (item.id == 'fruits') {
      // কমলা ও নীল ক্যালকুলেটর/কাউন্টিং আইকন (ছবির মতো হুবহু)
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF1976D2),
          borderRadius: BorderRadius.circular(7),
        ),
        child: const Icon(
          Icons.calculate_rounded,
          color: Colors.white,
          size: 24,
        ),
      );
    }
    return Icon(item.icon, color: item.iconColor, size: 30);
  }

  List<Widget> _buildCardWatermarks(String id) {
    if (id == 'fruits') {
      return [
        Positioned(
          top: 8,
          left: 10,
          child: Text(
            '+',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
        ),
        Positioned(
          top: 26,
          right: 12,
          child: Text(
            '÷',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
        ),
      ];
    } else if (id == 'animals') {
      return [
        Positioned(
          top: 10,
          right: 10,
          child: Icon(
            Icons.pets_rounded,
            size: 26,
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
      ];
    } else if (id == 'flowers') {
      return [
        Positioned(
          top: 32,
          left: 8,
          child: Icon(
            Icons.local_florist_rounded,
            size: 22,
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        Positioned(
          top: 12,
          right: 14,
          child: Icon(
            Icons.filter_vintage_rounded,
            size: 22,
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
      ];
    }
    return [
      Positioned(
        top: 14,
        right: 10,
        child: Icon(
          Icons.spa_rounded,
          size: 24,
          color: Colors.white.withValues(alpha: 0.16),
        ),
      ),
    ];
  }

  Widget _buildCornerIllustration(String id) {
    final emoji = switch (id) {
      'animals' => '🐶',
      'flowers' => '🌺',
      'vegetables' => '🍅🥬',
      'fishes' => '🐟',
      _ => '',
    };
    if (emoji.isEmpty) return const SizedBox.shrink();
    return Text(emoji, style: const TextStyle(fontSize: 28));
  }
}

/// "আমার অগ্রগতি" কার্ডের নীল-সবুজ সার্কুলার প্রগ্রেস রিং পেইন্টার
class _ProgressRingPainter extends CustomPainter {
  final double progress;

  const _ProgressRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 7) / 2;

    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5
      ..color = const Color(0xFFD6E4F8);

    canvas.drawCircle(center, radius, bgPaint);

    final rect = Rect.fromCircle(center: center, radius: radius);
    final fgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF26A69A), Color(0xFF00897B), Color(0xFF2E7D32)],
      ).createShader(rect);

    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
