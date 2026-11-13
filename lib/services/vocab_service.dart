import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/vocab_word.dart';

class VocabService {
  static Future<List<VocabWord>> loadWords() async {
    final mainJson = await rootBundle.loadString(
      'assets/data/hsk_2025_vocab.json',
    );

    final bengaliJson = await rootBundle.loadString(
      'assets/data/hsk_1_vocab_bengali.json',
    );

    final examplesJson = await rootBundle.loadString(
      'assets/data/hsk_examples.json',
    );

    final List<dynamic> mainData = jsonDecode(mainJson);
    final List<dynamic> bengaliData = jsonDecode(bengaliJson);
    final List<dynamic> examplesData = jsonDecode(examplesJson);

    final Map<String, String> bengaliMeanings = {
      for (final item in bengaliData)
        item['word'].toString(): item['translation'].toString(),
    };

    final Map<String, Map<String, dynamic>> examples = {
      for (final item in examplesData) item['hanzi'].toString(): item,
    };

    return mainData.map((item) {
      final hanzi = item['hanzi'].toString();
      final meaning = bengaliMeanings[hanzi] ?? item['meaning'].toString();

      final exampleData = examples[hanzi];

      return VocabWord(
        level: int.parse(item['level'].toString()),
        hanzi: hanzi,
        pinyin: item['pinyin'].toString(),
        meaning: meaning,
        example: exampleData?['example']?.toString() ?? '',
        examplePinyin: exampleData?['example_pinyin']?.toString() ?? '',
        translation: exampleData?['translation']?.toString() ?? meaning,
      );
    }).toList();
  }
}
