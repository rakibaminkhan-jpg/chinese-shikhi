
import 'dart:math';

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

  static const Color red = Color(0xFFD32F2F);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'চীনা শিখি',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: red,
          primary: red,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
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

// ================= PROGRESS DATA =================

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
          'চীনা শিখি 🇨🇳',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFD32F2F),
                    Color(0xFF8E0000),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '欢迎来到中国语学习！',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'চীনা ভাষা শেখা শুরু করুন আজ থেকেই।',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'প্রতিদিন একটু একটু করে শিখুন।',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'আপনার শেখার পরিসংখ্যান',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.menu_book,
                    title: 'শব্দ',
                    value: '১,৯৯৭',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.emoji_events,
                    title: 'শেষ স্কোর',
                    value: hasCompletedQuiz
                        ? '$lastScore/10'
                        : '০/১০',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'শেখা শুরু করুন',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _MenuCard(
              icon: Icons.translate,
              title: 'শব্দভান্ডার',
              subtitle: 'HSK 1–4 এর চীনা শব্দ শিখুন',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VocabularyScreen(),
                  ),
                );
              },
            ),

            _MenuCard(
              icon: Icons.quiz,
              title: 'কুইজ',
              subtitle: 'নিজের শেখা যাচাই করুন',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const QuizScreen(),
                  ),
                );
              },
            ),

            _MenuCard(
              icon: Icons.bar_chart,
              title: 'আমার প্রগ্রেস',
              subtitle: 'আপনার শেখার অগ্রগতি দেখুন',
              onTap: () {
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
      ),
    );
  }
}

// ================= STAT CARD =================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 12,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: ChineseShikhiApp.red,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= MENU CARD =================

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: ChineseShikhiApp.red.withAlpha(25),
          child: Icon(
            icon,
            color: ChineseShikhiApp.red,
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
        onTap: onTap,
      ),
    );
  }
}

// ================= VOCABULARY SCREEN =================

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  late Future<List<VocabWord>> wordsFuture;

  @override
  void initState() {
    super.initState();
    wordsFuture = VocabService.loadWords();
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
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'শব্দ লোড করতে সমস্যা হয়েছে:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final words = snapshot.data ?? [];

          if (words.isEmpty) {
            return const Center(
              child: Text('কোনো শব্দ পাওয়া যায়নি।'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: words.length,
            itemBuilder: (context, index) {
              final word = words[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            child: Text('${index + 1}'),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            word.hanzi,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        word.pinyin,
                        style: const TextStyle(
                          color: ChineseShikhiApp.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        word.meaning,
                        style: const TextStyle(fontSize: 17),
                      ),
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

// ================= QUIZ SCREEN =================

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<List<VocabWord>> wordsFuture;

  List<VocabWord> quizWords = [];
  List<String> options = [];

  int currentQuestion = 0;
  int score = 0;
  String? selectedAnswer;
  bool finished = false;

  final Random random = Random();

  @override
  void initState() {
    super.initState();
    wordsFuture = VocabService.loadWords();
  }

  void prepareQuiz(List<VocabWord> words) {
    if (quizWords.isNotEmpty || words.length < 4) return;

    quizWords = List<VocabWord>.from(words)..shuffle(random);
    quizWords = quizWords.take(10).toList();

    prepareOptions(words);
  }

  void prepareOptions(List<VocabWord> allWords) {
    final correctAnswer = quizWords[currentQuestion].meaning;

    final otherAnswers = allWords
        .map((word) => word.meaning)
        .where((meaning) => meaning.isNotEmpty && meaning != correctAnswer)
        .toSet()
        .toList();

    otherAnswers.shuffle(random);

    options = [
      correctAnswer,
      ...otherAnswers.take(3),
    ];

    options.shuffle(random);
  }

  void selectAnswer(String answer) {
    if (selectedAnswer != null) return;

    setState(() {
      selectedAnswer = answer;

      if (answer == quizWords[currentQuestion].meaning) {
        score++;
      }
    });
  }

  void nextQuestion(List<VocabWord> allWords) {
    if (currentQuestion < quizWords.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
        prepareOptions(allWords);
      });
    } else {
      setState(() {
        finished = true;
        lastScore = score;
        hasCompletedQuiz = true;
      });
    }
  }

  void restartQuiz(List<VocabWord> words) {
    setState(() {
      quizWords = [];
      options = [];
      currentQuestion = 0;
      score = 0;
      selectedAnswer = null;
      finished = false;

      prepareQuiz(words);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('চীনা ভাষা কুইজ'),
      ),
      body: FutureBuilder<List<VocabWord>>(
        future: wordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('কুইজ লোড করা যায়নি: ${snapshot.error}'),
            );
          }

          final words = snapshot.data ?? [];

          if (words.length < 4) {
            return const Center(
              child: Text('কুইজের জন্য পর্যাপ্ত শব্দ পাওয়া যায়নি।'),
            );
          }

          prepareQuiz(words);

          if (finished) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Colors.orange,
                      size: 80,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'কুইজ সম্পন্ন!',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'আপনার স্কোর: $score/${quizWords.length}',
                      style: const TextStyle(
                        fontSize: 23,
                        color: ChineseShikhiApp.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton.icon(
                      onPressed: () => restartQuiz(words),
                      icon: const Icon(Icons.refresh),
                      label: const Text('আবার কুইজ দিন'),
                    ),
                  ],
                ),
              ),
            );
          }

          final word = quizWords[currentQuestion];

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'প্রশ্ন ${currentQuestion + 1}/${quizWords.length}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                LinearProgressIndicator(
                  value: (currentQuestion + 1) / quizWords.length,
                  color: ChineseShikhiApp.red,
                  minHeight: 8,
                ),

                const SizedBox(height: 35),

                const Text(
                  'এই শব্দটির অর্থ কী?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 20),

                Text(
                  word.hanzi,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 55,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  word.pinyin,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    color: ChineseShikhiApp.red,
                  ),
                ),

                const SizedBox(height: 30),

                ...options.map((option) {
                  final isSelected = selectedAnswer == option;
                  final isCorrect = option == word.meaning;

                  Color? backgroundColor;

                  if (selectedAnswer != null) {
                    if (isCorrect) {
                      backgroundColor = Colors.green.withAlpha(35);
                    } else if (isSelected) {
                      backgroundColor = Colors.red.withAlpha(35);
                    }
                  }

                  return Card(
                    color: backgroundColor,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(
                        option,
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: selectedAnswer == null
                          ? null
                          : Icon(
                              isCorrect
                                  ? Icons.check_circle
                                  : isSelected
                                      ? Icons.cancel
                                      : Icons.circle_outlined,
                              color: isCorrect
                                  ? Colors.green
                                  : Colors.red,
                            ),
                      onTap: () => selectAnswer(option),
                    ),
                  );
                }),

                const Spacer(),

                if (selectedAnswer != null)
                  ElevatedButton(
                    onPressed: () => nextQuestion(words),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ChineseShikhiApp.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(15),
                    ),
                    child: Text(
                      currentQuestion == quizWords.length - 1
                          ? 'ফলাফল দেখুন'
                          : 'পরবর্তী প্রশ্ন',
                    ),
                  ),
              ],
            ),
          );
        },
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
        title: const Text('আমার প্রগ্রেস'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 25),

            const Icon(
              Icons.school,
              size: 80,
              color: ChineseShikhiApp.red,
            ),

            const SizedBox(height: 20),

            const Text(
              'আপনার শেখার অগ্রগতি',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.menu_book,
                  color: ChineseShikhiApp.red,
                ),
                title: const Text('মোট শব্দ'),
                trailing: const Text(
                  '১,৯৯৭',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.quiz,
                  color: ChineseShikhiApp.red,
                ),
                title: const Text('কুইজ সম্পন্ন'),
                trailing: Text(
                  hasCompletedQuiz ? 'হ্যাঁ' : 'না',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.emoji_events,
                  color: ChineseShikhiApp.red,
                ),
                title: const Text('শেষ কুইজের স্কোর'),
                trailing: Text(
                  hasCompletedQuiz ? '$lastScore/10' : '—',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'প্রতিদিন অনুশীলন করুন।\nধীরে ধীরে আপনি চীনা ভাষায় দক্ষ হয়ে উঠবেন!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
