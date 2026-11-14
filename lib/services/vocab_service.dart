
import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/vocab_word.dart';

class VocabService {
  static Future<List<VocabWord>> loadWords() async {
    final mainJson = await rootBundle.loadString(
      'assets/data/hsk_2025_vocab.json',
    );

    final examplesJson = await rootBundle.loadString(
      'assets/data/hsk_examples.json',
    );

    final List<dynamic> mainData = jsonDecode(mainJson);
    final List<dynamic> examplesData = jsonDecode(examplesJson);

    final Map<String, Map<String, dynamic>> examples = {
      for (final item in examplesData)
        item['hanzi'].toString(): Map<String, dynamic>.from(item),
    };

    return mainData.map((item) {
      final word = Map<String, dynamic>.from(item);

      final hanzi = word['hanzi']?.toString() ?? '';
      final exampleData = examples[hanzi];

      final meaningEn = word['meaning']?.toString() ?? '';
      final meaningBn = word['meaning_bn']?.toString() ?? '';

      return VocabWord(
        level: int.tryParse(word['level']?.toString() ?? '') ?? 1,
        hanzi: hanzi,
        pinyin: word['pinyin']?.toString() ?? '',
        meaning: meaningEn,
        meaningBn: meaningBn,
        example: exampleData?['example']?.toString() ?? '',
        examplePinyin:
            exampleData?['example_pinyin']?.toString() ?? '',
        translation:
            exampleData?['translation']?.toString() ?? meaningBn,
      );
    }).toList();
  }
}
