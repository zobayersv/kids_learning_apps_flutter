import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/word_puzzle_model.dart';

class PuzzleService {
  // ১. লোকাল JSON ফাইল থেকে লোড করা
  static Future<List<CategoryData>> loadLocalPuzzles() async {
    final String response = await rootBundle.loadString(
      'assets/data/levels_data.json',
    );
    final Map<String, dynamic> data = json.decode(response);

    final List<dynamic> categoryList = data['data'] ?? [];
    return categoryList.map((item) => CategoryData.fromJson(item)).toList();
  }

  // ২. নির্দিষ্ট ক্যাটাগরি অনুযায়ী লেভেল খুঁজে নেওয়া
  static Future<List<WordPuzzle>> getPuzzlesByCategory(
    String categoryId,
  ) async {
    final categories = await loadLocalPuzzles();
    final selectedCategory = categories.firstWhere(
      (cat) => cat.categoryId == categoryId,
      orElse: () => CategoryData(categoryId: '', categoryName: '', levels: []),
    );
    return selectedCategory.levels;
  }
}
