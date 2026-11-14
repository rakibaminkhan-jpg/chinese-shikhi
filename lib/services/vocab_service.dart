
import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/vocab_word.dart';

class VocabService {
  static Future<List<VocabWord>> loadWords() async {
    // মূল HSK JSON ফাইল লোড
    final mainJson = await rootBundle.loadString(
      'assets/data/hsk_2025_vocab.json',
    );

    // উদাহরণ JSON ফাইল লোড
    final examplesJson = await rootBundle.loadString(
      'assets/data/hsk_examples.json',
    );

    final List<dynamic> mainData = jsonDecode(mainJson);
    final List<dynamic> examplesData = jsonDecode(examplesJson);

    // উদাহরণগুলো Hanzi অনুযায়ী সাজানো
    final Map<String, Map<String, dynamic>> examples = {
      for (final item in examplesData)
        item['hanzi'].toString(): Map<String, dynamic>.from(item),
    };

    // সব HSK শব্দ তৈরি
    return mainData.map((item) {
      final word = Map<String, dynamic>.from(item);

      final hanzi = word['hanzi']?.toString() ?? '';
      final pinyin = word['pinyin']?.toString() ?? '';

      // ইংরেজি অর্থ
      final meaningEn = word['meaning']?.toString() ?? '';

      // সরাসরি মূল JSON থেকে বাংলা অর্থ
      final meaningBn = word['meaning_bn']?.toString() ?? '';

      final exampleData = examples[hanzi];

      return VocabWord(
        level: int.tryParse(word['level'].toString()) ?? 1,
        hanzi: hanzi,
        pinyin: pinyin,
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
