import '../services/language_service.dart';

class WordPuzzle {
  final String id;
  final int levelNumber;
  final String imageUrl;
  final String correctWordBn;
  final List<String> correctTilesBn;
  final List<String> jumbledTilesBn;
  final String correctWordEn;
  final List<String> correctTilesEn;
  final List<String> jumbledTilesEn;

  WordPuzzle({
    required this.id,
    required this.levelNumber,
    required this.imageUrl,
    required this.correctWordBn,
    required this.correctTilesBn,
    required this.jumbledTilesBn,
    required this.correctWordEn,
    required this.correctTilesEn,
    required this.jumbledTilesEn,
  });

  /// বর্তমান ভাষা অনুযায়ী সঠিক শব্দ (যেমন: "আম" অথবা "MANGO")
  String get correctWord =>
      LanguageService.isBangla ? correctWordBn : correctWordEn;

  /// বর্তমান ভাষা অনুযায়ী সঠিক টাইলস
  List<String> get correctTiles =>
      LanguageService.isBangla ? correctTilesBn : correctTilesEn;

  /// বর্তমান ভাষা অনুযায়ী এলোমেলো অক্ষর টাইলস
  List<String> get jumbledTiles =>
      LanguageService.isBangla ? jumbledTilesBn : jumbledTilesEn;

  // Map/JSON থেকে অবজেক্ট তৈরি
  factory WordPuzzle.fromJson(Map<String, dynamic> json) {
    final wordBn = (json['correct_word'] ?? '') as String;
    final wordEn = (json['correct_word_en'] ?? wordBn) as String;
    return WordPuzzle(
      id: json['id'] ?? '',
      levelNumber: json['level_number'] ?? 1,
      imageUrl: json['image_url'] ?? '',
      correctWordBn: wordBn,
      correctTilesBn: List<String>.from(json['correct_tiles'] ?? []),
      jumbledTilesBn: List<String>.from(json['jumbled_tiles'] ?? []),
      correctWordEn: wordEn,
      correctTilesEn: List<String>.from(
        json['correct_tiles_en'] ?? json['correct_tiles'] ?? [],
      ),
      jumbledTilesEn: List<String>.from(
        json['jumbled_tiles_en'] ?? json['jumbled_tiles'] ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level_number': levelNumber,
      'image_url': imageUrl,
      'correct_word': correctWordBn,
      'correct_tiles': correctTilesBn,
      'jumbled_tiles': jumbledTilesBn,
      'correct_word_en': correctWordEn,
      'correct_tiles_en': correctTilesEn,
      'jumbled_tiles_en': jumbledTilesEn,
    };
  }
}

class CategoryData {
  final String categoryId;
  final String categoryName;
  final String categoryNameEn;
  final List<WordPuzzle> levels;

  CategoryData({
    required this.categoryId,
    required this.categoryName,
    this.categoryNameEn = '',
    required this.levels,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      categoryId: json['category_id'] ?? '',
      categoryName: json['category_name'] ?? '',
      categoryNameEn: json['category_name_en'] ?? '',
      levels: (json['levels'] as List<dynamic>? ?? [])
          .map((item) => WordPuzzle.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
