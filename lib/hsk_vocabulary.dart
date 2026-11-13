
import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/vocab_word.dart';

class VocabService {
  static Future<List<VocabWord>> loadWords() async {
    // HSK 1-4 এর মূল শব্দভান্ডার
    final mainJson = await rootBundle.loadString(
      'assets/data/hsk_2025_vocab.json',
    );

    // HSK 1 এর বাংলা অর্থ
    final bengaliJson = await rootBundle.loadString(
      'assets/data/hsk_1_vocab_bengali.json',
    );

    final List<dynamic> mainData = jsonDecode(mainJson);
    final List<dynamic> bengaliData = jsonDecode(bengaliJson);

    // চীনা শব্দের সঙ্গে বাংলা অর্থ মিলানো
    final Map<String, String> bengaliMeanings = {
      for (final item in bengaliData)
        item['word'].toString(): item['translation'].toString(),
    };

    return mainData.map((item) {
      final String hanzi = item['hanzi'].toString();

      return VocabWord(
        hanzi: hanzi,
        pinyin: item['pinyin'].toString(),
        meaning: bengaliMeanings[hanzi] ??
            item['meaning'].toString(),
        example: '',
        examplePinyin: '',
        translation: bengaliMeanings[hanzi] ??
            item['meaning'].toString(),
      );
    }).toList();
  }
}
