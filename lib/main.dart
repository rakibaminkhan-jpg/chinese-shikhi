
import 'package:flutter/material.dart';
import 'hsk_vocabulary.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ChineseShikhiApp());
}

class ChineseShikhiApp extends StatelessWidget {
  const ChineseShikhiApp({super.key});

  static const Color primaryRed = Color(0xFFC62828);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'চীনা শিখি',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryRed,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFBF8),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

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
            icon: const Icon(Icons.insights),
            tooltip: 'আমার অগ্রগতি',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProgressScreen(),
                ),
              );
            },
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
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Nǐ hǎo! Welcome',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'বাংলায় সহজভাবে Mandarin Chinese শিখুন।',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 18),
                Text(
                  'প্রতিদিন শিখুন, নিজের দক্ষতা বাড়ান।',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'আপনার শেখার যাত্রা',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _statCard(
                  Icons.menu_book,
                  'HSK 1–4',
                  'শব্দভান্ডার',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCard(
                  Icons.quiz,
                  '১০টি',
                  'কুইজ প্রশ্ন',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _menuCard(
            context,
            Icons.translate,
            'HSK 1–4 শব্দভান্ডার',
            'চীনা শব্দ, Pinyin ও বাংলা অর্থ শিখুন',
            const HskVocabularyScreen(),
          ),

          _menuCard(
            context,
            Icons.quiz_outlined,
            'দৈনিক কুইজ',
            'নিজের চীনা ভাষার দক্ষতা যাচাই করুন',
            const QuizScreen(),
          ),

          _menuCard(
            context,
            Icons.trending_up,
            'আমার অগ্রগতি',
            'আপনার সর্বশেষ পরীক্ষার ফলাফল দেখুন',
            const ProgressScreen(),
          ),

          const SizedBox(height: 18),

          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📚 আজকের শেখার পরামর্শ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'প্রতিদিন ১০–১৫ মিনিট চীনা ভাষা অনুশীলন করুন। '
                    'নতুন শব্দ পড়ুন, Pinyin শিখুন এবং কুইজ দিন।',
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

  static Widget _statCard(
    IconData icon,
    String value,
    String label,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          children: [
            Icon(
              icon,
              color: ChineseShikhiApp.primaryRed,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }

  static Widget _menuCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget screen,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFFFE0E0),
          child: Icon(
            icon,
            color: ChineseShikhiApp.primaryRed,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 17),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => screen,
            ),
          );
        },
      ),
    );
  }
}

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

// ================= PROGRESS DATA =================

int lastScore = 0;
bool hasCompletedQuiz = false;

// ================= QUIZ SCREEN =================

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

                    ...List.generate(q.options.length, (j) {
                      return RadioListTile<int>(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(q.options[j]),
                        value: j,
                        groupValue: answers[i],
                        onChanged: submitted
                            ? null
                            : (value) {
                                if (value == null) return;

                                setState(() {
                                  answers[i] = value;
                                });
                              },
                      );
                    }),

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
              onPressed: answers.length == questions.length
                  ? submitQuiz
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: ChineseShikhiApp.primaryRed,
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
                      color: ChineseShikhiApp.primaryRed,
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

// ================= PROGRESS SCREEN =================

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
                color: ChineseShikhiApp.primaryRed,
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
                hasCompletedQuiz
                    ? '$lastScore / 10'
                    : 'এখনো পরীক্ষা দেননি',
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
