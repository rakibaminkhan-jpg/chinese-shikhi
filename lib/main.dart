import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as gma;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await gma.MobileAds.instance.initialize();
  } catch (_) {
    // বিজ্ঞাপন চালু না হলেও মূল অ্যাপ চলবে।
  }

  runApp(const ChineseShikhiApp());
}

class ChineseShikhiApp extends StatelessWidget {
  const ChineseShikhiApp({super.key});

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFB3261E);

    return MaterialApp(
      title: 'চীনা শিখি',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: red),
        scaffoldBackgroundColor: const Color(0xFFFFF9F6),
        appBarTheme: const AppBarTheme(
          backgroundColor: red,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ==================== HSK 1 শব্দভান্ডার ====================

class Word {
  final String hanzi;
  final String pinyin;
  final String meaning;
  final String example;
  final String examplePinyin;
  final String translation;

  const Word(
    this.hanzi,
    this.pinyin,
    this.meaning,
    this.example,
    this.examplePinyin,
    this.translation,
  );
}

const words = <Word>[
  Word('你', 'nǐ', 'তুমি / আপনি', '你好！', 'Nǐ hǎo!', 'হ্যালো!'),
  Word('好', 'hǎo', 'ভালো', '我很好。', 'Wǒ hěn hǎo.', 'আমি ভালো আছি।'),
  Word('我', 'wǒ', 'আমি', '我是学生。', 'Wǒ shì xuésheng.', 'আমি একজন শিক্ষার্থী।'),
  Word('他', 'tā', 'সে (পুরুষ)', '他是老师。', 'Tā shì lǎoshī.', 'তিনি শিক্ষক।'),
  Word('她', 'tā', 'সে (নারী)', '她很好。', 'Tā hěn hǎo.', 'তিনি ভালো আছেন।'),
  Word('是', 'shì', 'হওয়া / হয়', '我是孟加拉人。', 'Wǒ shì Mèngjiālā rén.', 'আমি বাংলাদেশি।'),
  Word('不', 'bù', 'না', '我不是老师。', 'Wǒ bú shì lǎoshī.', 'আমি শিক্ষক নই।'),
  Word('吗', 'ma', 'প্রশ্নবোধক অব্যয়', '你好吗？', 'Nǐ hǎo ma?', 'তুমি কি ভালো আছ?'),
  Word('名字', 'míngzi', 'নাম', '你叫什么名字？', 'Nǐ jiào shénme míngzi?', 'তোমার নাম কী?'),
  Word('叫', 'jiào', 'নাম হওয়া / ডাকা', '我叫小明。', 'Wǒ jiào Xiǎomíng.', 'আমার নাম শিয়াওমিং।'),
  Word('人', 'rén', 'মানুষ', '我是中国人。', 'Wǒ shì Zhōngguó rén.', 'আমি চীনা।'),
  Word('中国', 'Zhōngguó', 'চীন', '中国很大。', 'Zhōngguó hěn dà.', 'চীন অনেক বড়।'),
  Word('中国人', 'Zhōngguó rén', 'চীনা ব্যক্তি', '他是中国人。', 'Tā shì Zhōngguó rén.', 'তিনি চীনা।'),
  Word('学生', 'xuésheng', 'শিক্ষার্থী', '我是学生。', 'Wǒ shì xuésheng.', 'আমি শিক্ষার্থী।'),
  Word('老师', 'lǎoshī', 'শিক্ষক', '她是老师。', 'Tā shì lǎoshī.', 'তিনি শিক্ষক।'),
  Word('谢谢', 'xièxie', 'ধন্যবাদ', '谢谢你！', 'Xièxie nǐ!', 'তোমাকে ধন্যবাদ!'),
  Word('再见', 'zàijiàn', 'বিদায়', '老师，再见！', 'Lǎoshī, zàijiàn!', 'বিদায়, শিক্ষক!'),
  Word('请', 'qǐng', 'অনুগ্রহ করে', '请坐。', 'Qǐng zuò.', 'অনুগ্রহ করে বসুন।'),
  Word('对不起', 'duìbuqǐ', 'দুঃখিত', '对不起！', 'Duìbuqǐ!', 'আমি দুঃখিত!'),
  Word('没关系', 'méi guānxi', 'কোনো সমস্যা নেই', '没关系。', 'Méi guānxi.', 'কোনো সমস্যা নেই।'),
];

// ==================== কুইজ প্রশ্ন ====================

class Question {
  final String question;
  final List<String> options;
  final int answer;
  final String explanation;

  const Question(
    this.question,
    this.options,
    this.answer,
    this.explanation,
  );
}

const quiz = <Question>[
  Question('“我” শব্দের অর্থ কী?', ['তুমি', 'আমি', 'সে', 'নাম'], 1, '我 (wǒ) অর্থ আমি।'),
  Question('“你好” এর অর্থ কী?', ['বিদায়', 'ধন্যবাদ', 'হ্যালো', 'দুঃখিত'], 2, '你好 (nǐ hǎo) অর্থ হ্যালো।'),
  Question('“谢谢” এর অর্থ কী?', ['ধন্যবাদ', 'শিক্ষক', 'মানুষ', 'চীন'], 0, '谢谢 (xièxie) অর্থ ধন্যবাদ।'),
  Question('“老师” কাকে বলে?', ['শিক্ষার্থী', 'শিক্ষক', 'বন্ধু', 'মানুষ'], 1, '老师 (lǎoshī) অর্থ শিক্ষক।'),
  Question('“中国” কোন দেশের নাম?', ['বাংলাদেশ', 'জাপান', 'চীন', 'কোরিয়া'], 2, '中国 (Zhōngguó) অর্থ চীন।'),
  Question('“再见” কখন বলা হয়?', ['দেখা হলে', 'বিদায়ের সময়', 'ধন্যবাদ দিতে', 'প্রশ্ন করতে'], 1, '再见 (zàijiàn) অর্থ বিদায়।'),
  Question('“不” শব্দের অর্থ কী?', ['হ্যাঁ', 'ভালো', 'না', 'আমি'], 2, '不 (bù) অর্থ না।'),
  Question('“学生” এর অর্থ কী?', ['শিক্ষার্থী', 'শিক্ষক', 'চীনা', 'নাম'], 0, '学生 (xuésheng) অর্থ শিক্ষার্থী।'),
  Question('“对不起” এর অর্থ কী?', ['স্বাগতম', 'দুঃখিত', 'বিদায়', 'অনুগ্রহ করে'], 1, '对不起 (duìbuqǐ) অর্থ দুঃখিত।'),
  Question('“请” এর অর্থ কী?', ['অনুগ্রহ করে', 'সমস্যা নেই', 'মানুষ', 'তুমি'], 0, '请 (qǐng) অর্থ অনুগ্রহ করে।'),
];

// ==================== হোম স্ক্রিন ====================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? lastScore;

  @override
  void initState() {
    super.initState();
    _readScore();
  }

  Future<void> _readScore() async {
    final prefs = await SharedPreferences.getInstance();

    if (mounted) {
      setState(() {
        lastScore = prefs.getInt('lesson1_score');
      });
    }
  }

  Future<void> _startQuiz() async {
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => const QuizScreen()),
    );

    if (result != null && mounted) {
      setState(() => lastScore = result);
    }
  }

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
            tooltip: 'আমার অগ্রগতি',
            icon: const Icon(Icons.insights),
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
      bottomNavigationBar: const BannerAdBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFB3261E),
                  Color(0xFF781A16),
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
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Nǐ hǎo! — হ্যালো!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'বাংলায় সহজভাবে Mandarin Chinese শিখুন।',
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 8),
                Text(
                  'শুরু করুন: HSK 1 • পাঠ ১',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'আপনার শেখার ড্যাশবোর্ড',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  value: '${words.length}',
                  label: 'শব্দ',
                  icon: Icons.menu_book,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: StatCard(
                  value: '10',
                  label: 'কুইজ',
                  icon: Icons.quiz,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  value: lastScore == null ? '—' : '$lastScore/10',
                  label: 'শেষ স্কোর',
                  icon: Icons.star,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          MenuCard(
            icon: Icons.translate,
            title: 'HSK 1 শব্দভান্ডার',
            subtitle: '২০টি শব্দ, Pinyin, বাংলা অর্থ ও উদাহরণ',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VocabularyScreen(),
                ),
              );
            },
          ),
          MenuCard(
            icon: Icons.quiz_outlined,
            title: 'অনুশীলন কুইজ',
            subtitle: '১০টি প্রশ্ন দিয়ে নিজের দক্ষতা যাচাই করুন',
            onTap: _startQuiz,
          ),
          MenuCard(
            icon: Icons.trending_up,
            title: 'আমার অগ্রগতি',
            subtitle: 'সর্বশেষ কুইজের ফলাফল দেখুন',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProgressScreen(),
                ),
              );
            },
          ),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'আজকের টিপস\n'
                'প্রতিদিন ১০–১৫ মিনিট অনুশীলন করুন। '
                'Pinyin-এর tone mark খেয়াল করে প্রতিটি শব্দ জোরে পড়ুন।',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== স্ট্যাট কার্ড ====================

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 5,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== মেনু কার্ড ====================

class MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 7,
        ),
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

// ==================== শব্দ শেখার স্ক্রিন ====================

class VocabularyScreen extends StatelessWidget {
  const VocabularyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HSK 1 — শব্দভান্ডার'),
      ),
      bottomNavigationBar: const BannerAdBar(),
      body: ListView.separated(
        padding: const EdgeInsets.all(14),
        itemCount: words.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final word = words[i];

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        child: Text('${i + 1}'),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        word.hanzi,
                        style: const TextStyle(
                          fontSize: 29,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              word.pinyin,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(word.meaning),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                    style: const TextStyle(color: Colors.black54),
                  ),
                  Text('বাংলা: ${word.translation}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==================== কুইজ স্ক্রিন ====================

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final Map<int, int> answers = {};
  bool submitted = false;

  int get score {
    return List.generate(quiz.length, (i) => i)
        .where((i) => answers[i] == quiz[i].answer)
        .length;
  }

  Future<void> _submit() async {
    if (answers.length != quiz.length) return;

    setState(() => submitted = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lesson1_score', score);

    if (mounted) {
      // স্কোর সংরক্ষিত হয়েছে।
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HSK 1 — অনুশীলন কুইজ'),
      ),
      bottomNavigationBar: const BannerAdBar(),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Text(
            'উত্তর দিয়েছেন: ${answers.length}/${quiz.length}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...List.generate(
            quiz.length,
            (i) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${i + 1}. ${quiz[i].question}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    ...List.generate(
                      quiz[i].options.length,
                      (j) => RadioListTile<int>(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(quiz[i].options[j]),
                        value: j,
                        groupValue: answers[i],
                        onChanged: submitted
                            ? null
                            : (v) {
                                if (v != null) {
                                  setState(() => answers[i] = v);
                                }
                              },
                      ),
                    ),
                    if (submitted) ...[
                      const Divider(),
                      Text(
                        answers[i] == quiz[i].answer
                            ? 'সঠিক উত্তর!'
                            : 'সঠিক উত্তর: ${quiz[i].options[quiz[i].answer]}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: answers[i] == quiz[i].answer
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      Text(quiz[i].explanation),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (submitted)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Text(
                      'আপনার স্কোর: $score/10',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      score >= 8
                          ? 'চমৎকার! অনুশীলন চালিয়ে যান।'
                          : 'আরও অনুশীলন করুন। আপনি পারবেন!',
                    ),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          answers.clear();
                          submitted = false;
                        });
                      },
                      child: const Text('আবার কুইজ দিন'),
                    ),
                  ],
                ),
              ),
            )
          else
            FilledButton(
              onPressed: answers.length == quiz.length ? _submit : null,
              child: const Text('উত্তর জমা দিন'),
            ),
        ],
      ),
    );
  }
}

// ==================== অগ্রগতি স্ক্রিন ====================

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  Future<int?> _getScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('lesson1_score');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('আমার অগ্রগতি'),
      ),
      body: Center(
        child: FutureBuilder<int?>(
          future: _getScore(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const CircularProgressIndicator();
            }

            final score = snapshot.data;

            if (score == null) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'এখনো কোনো কুইজ দেওয়া হয়নি। প্রথম কুইজটি দিয়ে শুরু করুন।',
                  textAlign: TextAlign.center,
                ),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.emoji_events,
                  size: 68,
                  color: Color(0xFFB3261E),
                ),
                const SizedBox(height: 12),
                const Text(
                  'সর্বশেষ কুইজের ফলাফল',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$score / 10',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  score >= 8
                      ? 'দারুণ অগ্রগতি!'
                      : 'আরও অনুশীলন করুন।',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ==================== Google AdMob Banner ====================

class BannerAdBar extends StatefulWidget {
  const BannerAdBar({super.key});

  @override
  State<BannerAdBar> createState() => _BannerAdBarState();
}

class _BannerAdBarState extends State<BannerAdBar> {
  gma.BannerAd? banner;
  bool loaded = false;

  // Google-এর sample test Banner ID।
  // প্রকাশের আগে নিজের AdMob ID ব্যবহার করবেন।
  static const testBannerId =
      'ca-app-pub-3940256099942544/6300978111';

  @override
  void initState() {
    super.initState();

    final ad = gma.BannerAd(
      adUnitId: testBannerId,
      size: gma.AdSize.banner,
      request: const gma.AdRequest(),
      listener: gma.BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }

          setState(() => loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();

          if (mounted) {
            setState(() => loaded = false);
          }
        },
      ),
    );

    banner = ad;
    ad.load();
  }

  @override
  void dispose() {
    banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded || banner == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: SizedBox(
        height: banner!.size.height.toDouble(),
        width: double.infinity,
        child: Center(
          child: SizedBox(
            width: banner!.size.width.toDouble(),
            height: banner!.size.height.toDouble(),
            child: gma.AdWidget(ad: banner!),
          ),
        ),
      ),
    );
  }
}
