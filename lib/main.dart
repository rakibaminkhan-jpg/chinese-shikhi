import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'data/lesson_one.dart';
import 'models/vocab_word.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ChineseShikhiApp());
}

class ChineseShikhiApp extends StatelessWidget {
  const ChineseShikhiApp({super.key});

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFC62828);
    return MaterialApp(
      title: 'চীনা শিখি',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: red),
        scaffoldBackgroundColor: const Color(0xFFFFFBF8),
        appBarTheme: const AppBarTheme(
          backgroundColor: red,
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _completed = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _completed = prefs.getInt('lesson1_completed') ?? 0);
  }

  Future<void> _openQuiz() async {
    final result = await Navigator.push<int>(
      context, MaterialPageRoute(builder: (_) => const QuizScreen()));
    if (result != null && mounted) {
      setState(() => _completed = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('চীনা শিখি', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'শেখার অগ্রগতি',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressScreen())),
            icon: const Icon(Icons.insights),
          ),
        ],
      ),
      bottomNavigationBar: const BannerAdBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFC62828), Color(0xFF8E1717)]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('你好！ Nǐ hǎo!', style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('বাংলায় সহজভাবে Mandarin Chinese শিখুন।', style: TextStyle(color: Colors.white, fontSize: 15)),
                SizedBox(height: 14),
                Text('প্রথম ধাপ: HSK 1', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('আজকের শেখা', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _StatCard(value: '${lessonOne.length}', label: 'শব্দ', icon: Icons.menu_book)),
            const SizedBox(width: 10),
            Expanded(child: _StatCard(value: '10', label: 'কুইজ', icon: Icons.quiz)),
            const SizedBox(width: 10),
            Expanded(child: _StatCard(value: '$_completed/10', label: 'সঠিক', icon: Icons.star)),
          ]),
          const SizedBox(height: 18),
          _MenuCard(
            icon: Icons.translate,
            title: 'HSK 1 শব্দভান্ডার',
            subtitle: '২০টি শব্দ, Pinyin, বাংলা অর্থ ও উদাহরণ',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VocabularyScreen())),
          ),
          _MenuCard(
            icon: Icons.quiz_outlined,
            title: 'দৈনিক কুইজ',
            subtitle: '১০টি বহুনির্বাচনী প্রশ্ন দিয়ে পরীক্ষা দিন',
            onTap: _openQuiz,
          ),
          _MenuCard(
            icon: Icons.trending_up,
            title: 'আমার অগ্রগতি',
            subtitle: 'কুইজের ফলাফল দেখুন',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressScreen())),
          ),
          const SizedBox(height: 12),
          const Text('শেখার টিপস', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Card(child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('প্রতিদিন ১০–১৫ মিনিট অনুশীলন করুন। Pinyin-এর tone mark লক্ষ্য করুন এবং প্রতিটি শব্দ জোরে পড়ে অনুশীলন করুন।'),
          )),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  const _StatCard({required this.value, required this.label, required this.icon});
  @override
  Widget build(BuildContext context) => Card(child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
    child: Column(children: [
      Icon(icon, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
    ]),
  ));
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const _MenuCard({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}

class VocabularyScreen extends StatelessWidget {
  const VocabularyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HSK 1 শব্দভান্ডার')),
      bottomNavigationBar: const BannerAdBar(),
      body: ListView.separated(
        padding: const EdgeInsets.all(14),
        itemCount: lessonOne.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) => WordCard(word: lessonOne[index], number: index + 1),
      ),
    );
  }
}

class WordCard extends StatelessWidget {
  final VocabWord word;
  final int number;
  const WordCard({super.key, required this.word, required this.number});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          CircleAvatar(radius: 15, child: Text('$number', style: const TextStyle(fontSize: 12))),
          const SizedBox(width: 12),
          Text(word.hanzi, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(word.pinyin, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
            Text(word.meaning, style: const TextStyle(fontSize: 16)),
          ])),
        ]),
        const Divider(height: 20),
        Text(word.example, style: const TextStyle(fontSize: 19)),
        Text(word.examplePinyin, style: const TextStyle(color: Colors.black54)),
        Text(word.translation, style: const TextStyle(fontWeight: FontWeight.w500)),
      ]),
    ),
  );
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final Map<int, int> _answers = {};
  bool _submitted = false;

  int get _score => List.generate(lessonOneQuiz.length, (i) => i)
      .where((i) => _answers[i] == lessonOneQuiz[i].answer).length;

  Future<void> _submit() async {
    if (_answers.length != lessonOneQuiz.length) return;
    setState(() => _submitted = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lesson1_completed', _score);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HSK 1 কুইজ')),
      bottomNavigationBar: const BannerAdBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('উত্তর দিয়েছেন: ${_answers.length}/${lessonOneQuiz.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...List.generate(lessonOneQuiz.length, (i) {
            final q = lessonOneQuiz[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${i + 1}. ${q.question}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  ...List.generate(q.options.length, (j) => RadioListTile<int>(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text('${String.fromCharCode(65 + j)}. ${q.options[j]}'),
                    value: j,
                    groupValue: _answers[i],
                    onChanged: _submitted ? null : (v) => setState(() => _answers[i] = v!),
                  )),
                  if (_submitted) ...[
                    const Divider(),
                    Text(
                      _answers[i] == q.answer ? 'সঠিক উত্তর!' : 'সঠিক উত্তর: ${q.options[q.answer]}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: _answers[i] == q.answer ? Colors.green : Colors.red),
                    ),
                    Text(q.explanation),
                  ],
                ]),
              ),
            );
          }),
          if (_submitted)
            Card(child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(children: [
                Text('আপনার স্কোর: $_score/10', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text(_score >= 8 ? 'চমৎকার! চালিয়ে যান।' : 'আরও অনুশীলন করুন।'),
                const SizedBox(height: 8),
                OutlinedButton(onPressed: () => setState(() { _answers.clear(); _submitted = false; }), child: const Text('আবার চেষ্টা করুন')),
              ]),
            ))
          else
            FilledButton(
              onPressed: _answers.length == lessonOneQuiz.length ? _submit : null,
              child: const Text('উত্তর জমা দিন'),
            ),
        ],
      ),
    );
  }
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});
  Future<int> _score() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('lesson1_completed') ?? 0;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('আমার অগ্রগতি')),
    body: Center(
      child: FutureBuilder<int>(
        future: _score(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          final score = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.emoji_events, size: 64, color: Color(0xFFC62828)),
              const SizedBox(height: 12),
              const Text('শেষ কুইজের ফলাফল', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('$score / 10', style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold)),
              Text(score >= 8 ? 'দারুণ অগ্রগতি!' : 'আবার অনুশীলন করুন।'),
            ]),
          );
        },
      ),
    ),
  );
}

class BannerAdBar extends StatelessWidget {
  const BannerAdBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _BannerAdBarState extends State<BannerAdBar> {
  BannerAd? _banner;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _banner = BannerAd(
      adUnitId: AdService.bannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) { if (mounted) setState(() => _loaded = true); },
        onAdFailedToLoad: (ad, error) { ad.dispose(); },
      ),
    )..load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _banner == null) return const SizedBox.shrink();
    return SafeArea(
      child: SizedBox(
        height: _banner!.size.height.toDouble(),
        width: _banner!.size.width.toDouble(),
        child: Center(child: AdWidget(ad: _banner!)),
      ),
    );
  }
}
