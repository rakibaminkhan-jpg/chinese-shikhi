
class VocabWord {
  final int level;
  final String hanzi;
  final String pinyin;
  final String meaning;
  final String example;
  final String examplePinyin;
  final String translation;

  const VocabWord({
    this.level = 1,
    required this.hanzi,
    required this.pinyin,
    required this.meaning,
    required this.example,
    required this.examplePinyin,
    required this.translation,
  });
}
