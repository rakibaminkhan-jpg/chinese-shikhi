import 'services/vocab_service.dart';
import 'package:flutter/material.dart';
import 'models/vocab_word.dart';
import 'services/vocab_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ChineseShikhiApp());
}

// ================= APP =================

class ChineseShikhiApp extends StatelessWidget {
  const ChineseShikhiApp({super.key});

  static const Color red = Color(0xFFC62828);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'চীনা শিখি',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: red,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFBF8),
        appBarTheme: const AppBarTheme(
          backgroundColor: red,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ================= VOCABULARY DATA =================

// ================= QUIZ DATA =================

class QuizQuestion {
  final String question;
  final List<String> options;
  final int answer;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
    required this.explanation,
  });
}

const List<QuizQuestion> questions = [
  QuizQuestion(
    question: '你好 এর বাংলা অর্থ কী?',
    options: ['ধন্যবাদ', 'হ্যালো', 'বিদায়', 'পানি'],
    answer: 1,
    explanation: '你好 (Nǐ hǎo) অর্থ হ্যালো।',
  ),
  QuizQuestion(
    question: '谢谢 অর্থ কী?',
    options: ['ধন্যবাদ', 'বন্ধু', 'মানুষ', 'চা'],
    answer: 0,
    explanation: '谢谢 (Xièxie) অর্থ ধন্যবাদ।',
  ),
  QuizQuestion(
    question: '水 অর্থ কী?',
    options: ['ভাত', 'চা', 'পানি', 'স্কুল'],
    answer: 2,
    explanation: '水 (Shuǐ) অর্থ পানি।',
  ),
  QuizQuestion(
    question: '我 অর্থ কী?',
    options: ['তুমি', 'আমি', 'সে', 'আমরা'],
    answer: 1,
    explanation: '我 (Wǒ) অর্থ আমি।',
  ),
  QuizQuestion(
    question: '中国 কোন দেশ?',
    options: ['বাংলাদেশ', 'ভারত', 'চীন', 'জাপান'],
    answer: 2,
    explanation: '中国 (Zhōngguó) অর্থ চীন।',
  ),
  QuizQuestion(
    question: '朋友 অর্থ কী?',
    options: ['শিক্ষক', 'বন্ধু', 'মানুষ', 'ছাত্র'],
    answer: 1,
    explanation: '朋友 (Péngyou) অর্থ বন্ধু।',
  ),
  QuizQuestion(
    question: '老师 অর্থ কী?',
    options: ['শিক্ষক', 'বন্ধু', 'পানি', 'বাড়ি'],
    answer: 0,
    explanation: '老师 (Lǎoshī) অর্থ শিক্ষক।',
  ),
  QuizQuestion(
    question: '再见 অর্থ কী?',
    options: ['হ্যালো', 'ধন্যবাদ', 'বিদায়', 'ভালো'],
    answer: 2,
    explanation: '再见 (Zàijiàn) অর্থ বিদায়।',
  ),
  QuizQuestion(
    question: '吃 অর্থ কী?',
    options: ['পান করা', 'খাওয়া', 'যাওয়া', 'আসা'],
    answer: 1,
    explanation: '吃 (Chī) অর্থ খাওয়া।',
  ),
  QuizQuestion(
    question: '好 অর্থ কী?',
    options: ['খারাপ', 'না', 'ভালো', 'বিদায়'],
    answer: 2,
    explanation: '好 (Hǎo) অর্থ ভালো।',
  ),
];

// অ্যাপ চালু থাকা পর্যন্ত ফলাফল সংরক্ষণ
int lastScore = 0;
bool hasCompletedQuiz = false;

// ================= HOME SCREEN =================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'চীনা শিখি',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProgressScreen(),
                ),
              );
            },
            icon: const Icon(Icons.insights),
            tooltip: 'অগ্রগতি',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFC62828),
                  Color(0xFF8E1717),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '你好！',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Nǐ hǎo! Welcome',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'বাংলায় সহজভাবে Mandarin Chinese শিখুন।',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'প্রথম ধাপ: HSK 1',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'আজকের শেখা',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: statCard(
                  '১,৯৯৭',
                  'শব্দ',
                  Icons.menu_book,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: statCard(
                  '${questions.length}',
                  'কুইজ',
                  Icons.quiz,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: statCard(
                  hasCompletedQuiz ? '$lastScore/10' : '0/10',
                  'সঠিক',
                  Icons.star,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          menuCard(
            context,
            Icons.translate,
            'HSK 1 শব্দভান্ডার',
            '২০টি চীনা শব্দ, Pinyin ও বাংলা অর্থ',
            const VocabularyScreen(),
          ),
          menuCard(
            context,
            Icons.quiz_outlined,
            'দৈনিক কুইজ',
            '১০টি প্রশ্নের মাধ্যমে পরীক্ষা দিন',
            const QuizScreen(),
          ),
          menuCard(
            context,
            Icons.trending_up,
            'আমার অগ্রগতি',
            'আপনার পরীক্ষার ফলাফল দেখুন',
            const ProgressScreen(),
          ),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📚 শেখার টিপস',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'প্রতিদিন ১০-১৫ মিনিট চীনা ভাষা অনুশীলন করুন। '
                    'Pinyin-এর Tone Mark লক্ষ্য করুন এবং প্রতিটি শব্দ '
                    'বারবার পড়ুন।',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget statCard(String value, String label, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Icon(icon, color: ChineseShikhiApp.red),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget menuCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget screen,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFFFE0E0),
          child: Icon(icon, color: ChineseShikhiApp.red),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 17),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        },
      ),
    );
  }
}

// ================= VOCABULARY =================


class VocabularyScreen extends StatelessWidget {
  const VocabularyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HSK 1–4 — শব্দভান্ডার'),
      ),
      bottomNavigationBar: const BannerAdBar(),
      body: FutureBuilder(
        future: VocabService.loadWords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'শব্দ লোড করা যায়নি।\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final loadedWords = snapshot.data ?? [];

          if (loadedWords.isEmpty) {
            return const Center(
              child: Text('কোনো শব্দ পাওয়া যায়নি।'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(14),
            itemCount: loadedWords.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final word = loadedWords[index];

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.deepRed,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              word.hanzi,
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: AppColors.red,
                              ),
                            ),
                          ),
                          Chip(
                            label: Text('HSK ${word.level}'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        word.pinyin,
                        style: const TextStyle(
                          color: AppColors.deepRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text('বাংলা অর্থ: ${word.meaningBn.isNotEmpty ? word.meaningBn : word.meaning}'),
                      if (word.meaning.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          'English: ${word.meaning}',
                          style: const TextStyle(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                      if (word.example.isNotEmpty) ...[
                        const Divider(height: 22),
                        Text(
                          'উদাহরণ: ${word.example}',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Pinyin: ${word.examplePinyin}',
                          style: const TextStyle(
                            color: AppColors.muted,
                          ),
                        ),
                        Text('বাংলা: ${word.translation}'),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


  Widget _levelChip(String label, int level) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedLevel == level,
      selectedColor: const Color(0xFFFFE0E0),
      onSelected: (selected) {
        setState(() {
          selectedLevel = level;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HSK 1–4 শব্দভান্ডার'),
      ),
      body: FutureBuilder<List<VocabWord>>(
        future: wordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('শব্দ লোড করা যায়নি: ${snapshot.error}'),
            );
          }

          final allWords = snapshot.data ?? [];

          final filteredWords = allWords.where((word) {
            final matchesLevel =
                selectedLevel == 0 || word.level == selectedLevel;

            final query = searchQuery.trim().toLowerCase();

            final matchesSearch = word.hanzi.toLowerCase().contains(query) ||
                word.pinyin.toLowerCase().contains(query) ||
                word.meaning.toLowerCase().contains(query);

            return matchesLevel && matchesSearch;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'চীনা শব্দ, Pinyin বা অর্থ খুঁজুন',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _levelChip('All Words', 0),
                    _levelChip('HSK 1', 1),
                    _levelChip('HSK 2', 2),
                    _levelChip('HSK 3', 3),
                    _levelChip('HSK 4', 4),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'HSK Vocabulary',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${filteredWords.length} / ${allWords.length} টি শব্দ',
                      style: const TextStyle(
                        color: ChineseShikhiApp.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filteredWords.isEmpty
                    ? const Center(
                        child: Text('কোনো শব্দ পাওয়া যায়নি।'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: filteredWords.length,
                        itemBuilder: (context, index) {
                          final word = filteredWords[index];

                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _showWordDetails(word),
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: const Color(0xFFFFE0E0),
                                      child: Text('${index + 1}'),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            word.hanzi,
                                            style: const TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            word.pinyin,
                                            style: const TextStyle(
                                              color: ChineseShikhiApp.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            word.meaning,
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'HSK ${word.level} • বিস্তারিত দেখতে চাপ দিন',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ================= QUIZ =================

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final Map<int, int> answers = {};

  bool submitted = false;

  int get score {
    int total = 0;

    for (int i = 0; i < questions.length; i++) {
      if (answers[i] == questions[i].answer) {
        total++;
      }
    }

    return total;
  }

  void submitQuiz() {
    if (answers.length != questions.length) return;

    setState(() {
      submitted = true;
      lastScore = score;
      hasCompletedQuiz = true;
    });
  }

  void resetQuiz() {
    setState(() {
      answers.clear();
      submitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HSK 1 কুইজ'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'উত্তর দিয়েছেন: ${answers.length}/${questions.length}',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: answers.length / questions.length,
            minHeight: 7,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 18),
          ...List.generate(questions.length, (i) {
            final q = questions[i];

            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${i + 1}. ${q.question}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RadioGroup<int>(
                      groupValue: answers[i],
                      onChanged: (value) {
                        if (submitted || value == null) return;

                        setState(() {
                          answers[i] = value;
                        });
                      },
                      child: Column(
                        children: List.generate(q.options.length, (j) {
                          return RadioListTile<int>(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(q.options[j]),
                            value: j,
                            enabled: !submitted,
                          );
                        }),
                      ),
                    ),
                    if (submitted) ...[
                      const Divider(),
                      Text(
                        answers[i] == q.answer
                            ? 'সঠিক উত্তর!'
                            : 'সঠিক উত্তর: ${q.options[q.answer]}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: answers[i] == q.answer
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(q.explanation),
                    ],
                  ],
                ),
              ),
            );
          }),
          if (!submitted)
            FilledButton(
              onPressed: answers.length == questions.length ? submitQuiz : null,
              style: FilledButton.styleFrom(
                backgroundColor: ChineseShikhiApp.red,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('উত্তর জমা দিন'),
            ),
          if (submitted)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: ChineseShikhiApp.red,
                      size: 55,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'আপনার ফলাফল',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$score / ${questions.length}',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      score >= 8
                          ? 'চমৎকার! আপনি ভালো করছেন।'
                          : 'আরও অনুশীলন করুন।',
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: resetQuiz,
                      icon: const Icon(Icons.refresh),
                      label: const Text('আবার চেষ্টা করুন'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ================= PROGRESS =================

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('আমার অগ্রগতি'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events,
                size: 75,
                color: ChineseShikhiApp.red,
              ),
              const SizedBox(height: 18),
              const Text(
                'শেষ কুইজের ফলাফল',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                hasCompletedQuiz ? '$lastScore / 10' : 'এখনো পরীক্ষা দেননি',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                !hasCompletedQuiz
                    ? 'কুইজ দিয়ে আপনার অগ্রগতি দেখুন।'
                    : lastScore >= 8
                        ? 'দারুণ অগ্রগতি! চালিয়ে যান।'
                        : 'আরও অনুশীলন করুন।',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
