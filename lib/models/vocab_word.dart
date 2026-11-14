
class VocabWord {
  final int level;
  final String hanzi;
  final String pinyin;

  // English meaning
  final String meaning;

  // Bengali meaning
  final String meaningBn;

  final String example;
  final String examplePinyin;
  final String translation;

  const VocabWord({
    this.level = 1,
    required this.hanzi,
    required this.pinyin,
    required this.meaning,
    required this.meaningBn,
    required this.example,
    required this.examplePinyin,
    required this.translation,
  });
}
