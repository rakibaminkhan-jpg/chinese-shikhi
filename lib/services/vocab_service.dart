import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/vocab_word.dart';

class VocabService {
  static String _key({
    required int level,
    required String hanzi,
    required String pinyin,
    required String meaningBn,
  }) {
    return '$level|$hanzi|$pinyin|$meaningBn';
  }

  static Future<List<VocabWord>> loadWords() async {
    final mainJson = await rootBundle.loadString(
      'assets/data/hsk_2025_vocab.json',
    );

    final examplesJson = await rootBundle.loadString(
      'assets/data/hsk_examples.json',
    );

    final List<dynamic> mainData = jsonDecode(mainJson);
    final List<dynamic> examplesData = jsonDecode(examplesJson);

    final Map<String, Map<String, dynamic>> exampleMap = {};

    for (final item in examplesData) {
      final example = Map<String, dynamic>.from(item);
      final key = _key(
        level: int.tryParse(example['level'].toString()) ?? 1,
        hanzi: example['hanzi']?.toString() ?? '',
        pinyin: example['pinyin']?.toString() ?? '',
        meaningBn: example['meaning_bn']?.toString() ?? '',
      );
      exampleMap[key] = example;
    }

    return mainData.map((item) {
      final word = Map<String, dynamic>.from(item);

      final level = int.tryParse(word['level']?.toString() ?? '') ?? 1;
      final hanzi = word['hanzi']?.toString() ?? '';
      final pinyin = word['pinyin']?.toString() ?? '';
      final meaningEn = word['meaning']?.toString() ?? '';
      final meaningBn = word['meaning_bn']?.toString() ?? '';

      final key = _key(
        level: level,
        hanzi: hanzi,
        pinyin: pinyin,
        meaningBn: meaningBn,
      );

      final exampleData = exampleMap[key];

      return VocabWord(
        level: level,
        hanzi: hanzi,
        pinyin: pinyin,
        meaning: meaningEn,
        meaningBn: meaningBn,
        example: exampleData?['example']?.toString() ?? '',
        examplePinyin: exampleData?['example_pinyin']?.toString() ?? '',
        translation: exampleData?['translation']?.toString() ?? meaningBn,
      );
    }).toList();
  }
}
