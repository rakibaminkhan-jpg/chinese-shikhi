import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/speech_service.dart';
import 'services/learning_store.dart';
import 'models/vocab_word.dart';
import 'services/vocab_service.dart';
import 'learning_hub_screens.dart';
import 'chinese_live_radio_screen.dart';

const Color _gold = Color(0xFFD4AF37);
const Color _dark = Color(0xFF171717);

class _Phrase {
  final String chinese;
  final String pinyin;
  final String bengali;

  const _Phrase(this.chinese, this.pinyin, this.bengali);
}

const List<_Phrase> _phrases = [
  _Phrase('你好', 'Nǐ hǎo', 'হ্যালো / নমস্কার'),
  _Phrase('谢谢', 'Xièxie', 'ধন্যবাদ'),
  _Phrase('你好吗？', 'Nǐ hǎo ma?', 'তুমি কেমন আছ?'),
  _Phrase('我叫小明。', 'Wǒ jiào Xiǎomíng.', 'আমার নাম শিয়াওমিং।'),
  _Phrase('我想学中文。', 'Wǒ xiǎng xué Zhōngwén.', 'আমি চীনা ভাষা শিখতে চাই।'),
  _Phrase('明天见。', 'Míngtiān jiàn.', 'আগামীকাল দেখা হবে。'),
];

/// Speaking Practice-এর XP ও Streak কেন্দ্রীয়ভাবে সংরক্ষণ।
Future<void> _recordLearningProgress() async {
  await LearningStore.awardSpeakingXp();
}

class SpeakingListeningScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const SpeakingListeningScreen({super.key, this.scrollController});

  @override
  State<SpeakingListeningScreen> createState() =>
      _SpeakingListeningScreenState();
}

class _SpeakingListeningScreenState extends State<SpeakingListeningScreen> {
  int _xp = 0;
  int _streak = 0;
  int _bestQuiz = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    await LearningStore.migrateLegacySpeakingProgress();

    final results = await Future.wait<dynamic>([
      LearningStore.getTotalXp(),
      LearningStore.getStreak(),
    ]);

    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _xp = results[0] as int;
      _streak = results[1] as int;
      _bestQuiz = prefs.getInt('sl_best_quiz') ?? 0;
    });
  }

  void _open(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    ).then((_) => _loadProgress());
  }

  @override
  Widget build(BuildContext context) {
    final level = (_xp ~/ 100) + 1;
    final progress = (_xp % 100) / 100.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('শোনা ও বলা'),
        actions: [
          IconButton(
            tooltip: 'শব্দ বন্ধ করুন',
            onPressed: SpeechService.stop,
            icon: const Icon(Icons.volume_off_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProgress,
        child: ListView(
          controller: widget.scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _dark,
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [_dark, Color(0xFF493719)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '每天进步一点点',
                    style: TextStyle(
                      color: _gold,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'প্রতিদিন একটু একটু করে এগিয়ে যাও!',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _StatItem(
                        icon: Icons.local_fire_department_rounded,
                        value: '$_streak দিন',
                        label: 'Streak',
                      ),
                      const SizedBox(width: 28),
                      _StatItem(
                        icon: Icons.stars_rounded,
                        value: '$_xp XP',
                        label: 'মোট পয়েন্ট',
                      ),
                      const SizedBox(width: 28),
                      _StatItem(
                        icon: Icons.emoji_events_rounded,
                        value: 'Lv $level',
                        label: 'তোমার Level',
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 9,
                      backgroundColor: Colors.white24,
                      color: _gold,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${_xp % 100}/100 XP — পরবর্তী Level',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'আজ কী শিখবে?',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'অল্প সময় অনুশীলন করো, নিয়মিত উন্নতি করো।',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 14),
            _FeatureCard(
              icon: Icons.headphones_rounded,
              title: 'Listening Practice',
              subtitle: 'চীনা শব্দ শুনে অর্থ বোঝার অনুশীলন',
              tag: 'শোনো',
              onTap: () => _open(const ListeningPracticeScreen()),
            ),
            _FeatureCard(
              icon: Icons.radio_rounded,
              title: 'Chinese Live Radio',
              subtitle: 'চীনা রেডিও সরাসরি শুনে ভাষা ও উচ্চারণ শেখো',
              tag: 'লাইভ রেডিও',
              onTap: () => _open(const ChineseLiveRadioScreen()),
            ),
            _FeatureCard(
              icon: Icons.mic_rounded,
              title: 'Speaking Practice',
              subtitle: 'সঠিক উচ্চারণ শুনে নিজে বলার অনুশীলন',
              tag: 'বলো',
              onTap: () => _open(const SpeakingPracticeScreen()),
            ),
            _FeatureCard(
              icon: Icons.forum_rounded,
              title: 'Daily Conversation',
              subtitle: 'বাজার, রেস্টুরেন্ট ও পরিচিতির কথোপকথন',
              tag: 'কথা বলো',
              onTap: () => _open(const DailyConversationScreen()),
            ),
            _FeatureCard(
              icon: Icons.quiz_rounded,
              title: 'Listening Quiz',
              subtitle: 'শুনে সঠিক বাংলা অর্থ নির্বাচন করো',
              tag: 'কুইজ',
              onTap: () => _open(const ListeningQuizScreen()),
            ),
            _FeatureCard(
              icon: Icons.today_rounded,
              title: 'Daily Challenge',
              subtitle: 'প্রতিদিনের শেখার লক্ষ্য ও কাজ',
              tag: 'আজকের কাজ',
              onTap: () => _open(const DailyChallengeScreen()),
            ),
            _FeatureCard(
              icon: Icons.insights_rounded,
              title: 'Progress Dashboard',
              subtitle: 'XP, Level, Streak ও শেখার হিসাব',
              tag: 'অগ্রগতি',
              onTap: () => _open(const ProgressDashboardScreen()),
            ),
            _FeatureCard(
              icon: Icons.emoji_events_rounded,
              title: 'Achievement Center',
              subtitle: 'ব্যাজ আনলক করো ও Bonus XP অর্জন করো',
              tag: 'অর্জন',
              onTap: () => _open(const AchievementCenterScreen()),
            ),
            _FeatureCard(
              icon: Icons.style_rounded,
              title: 'Vocabulary Revision',
              subtitle: 'আগে শেখা ও Favorite শব্দ পুনরাবৃত্তি',
              tag: 'পুনরাবৃত্তি',
              onTap: () => _open(const VocabularyRevisionScreen()),
            ),
            _FeatureCard(
              icon: Icons.school_rounded,
              title: 'HSK Exam Center',
              subtitle: 'HSK 1–4 শব্দ দিয়ে মডেল পরীক্ষা',
              tag: 'মডেল পরীক্ষা',
              onTap: () => _open(const HSKExamCenterScreen()),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.emoji_events_rounded,
                  color: _gold,
                  size: 32,
                ),
                title: const Text(
                  'তোমার সেরা Quiz স্কোর',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('$_bestQuiz / 6'),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'নিজের গতিতে শেখো। প্রতিদিন একটু উন্নতি করাই জয়।',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: _gold, size: 25),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String tag;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 11),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: const Color(0xFF9B7410), size: 28),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 15),
            ],
          ),
        ),
      ),
    );
  }
}

class ListeningPracticeScreen extends StatefulWidget {
  const ListeningPracticeScreen({super.key});

  @override
  State<ListeningPracticeScreen> createState() =>
      _ListeningPracticeScreenState();
}

class _ListeningPracticeScreenState extends State<ListeningPracticeScreen> {
  List<VocabWord> _words = [];
  int _index = 0;
  int _earnedXp = 0;
  bool _loading = true;
  bool _busy = false;
  bool _autoPlay = true;
  bool _goalLocked = false;
  int _dailyGoal = 5;
  int _todayLearned = 0;
  int _totalLearned = 0;
  int _totalXp = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _refreshListeningStats() async {
    final results = await Future.wait([
      LearningStore.getDailyGoal(),
      LearningStore.isDailyGoalLocked(),
      LearningStore.getTodayLearnedCount(),
      LearningStore.getTotalLearnedCount(),
      LearningStore.getTotalXp(),
    ]);

    if (!mounted) return;

    setState(() {
      _dailyGoal = results[0] as int;
      _goalLocked = results[1] as bool;
      _todayLearned = results[2] as int;
      _totalLearned = results[3] as int;
      _totalXp = results[4] as int;
    });
  }

  Future<void> _playCurrentWord() async {
    if (!_autoPlay || !mounted || _index >= _words.length) return;
    await SpeechService.speakChinese(_words[_index].hanzi);
  }

  Future<void> _changeDailyGoal(int? goal) async {
    if (goal == null || _goalLocked) return;

    try {
      await LearningStore.setDailyGoal(goal);
      await _refreshListeningStats();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('দৈনিক লক্ষ্য $goal শব্দ নির্ধারণ হয়েছে।')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('লক্ষ্য পরিবর্তন করা যায়নি: $e')),
      );
    }
  }

  Future<void> _toggleAutoPlay(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('listening_auto_play', value);

    if (!mounted) return;
    setState(() => _autoPlay = value);

    if (value) {
      await _playCurrentWord();
    } else {
      await SpeechService.stop();
    }
  }

  Future<void> _loadWords() async {
    setState(() {
      _loading = true;
      _error = null;
      _busy = false;
    });

    try {
      final allWords = await VocabService.loadWords();
      final learned = await LearningStore.getLearnedWords();
      final deferred = await LearningStore.getDeferredListeningWords();
      final prefs = await SharedPreferences.getInstance();

      final autoPlay = prefs.getBool('listening_auto_play') ?? true;
      final dailyGoal = await LearningStore.getDailyGoal();
      final goalLocked = await LearningStore.isDailyGoalLocked();
      final todayLearned = await LearningStore.getTodayLearnedCount();
      final totalLearned = await LearningStore.getTotalLearnedCount();
      final totalXp = await LearningStore.getTotalXp();

      // মূল HSK তালিকার ক্রম বজায় রেখে Review শব্দ আগে দেখানো।
      final available = allWords.asMap().entries.where((entry) {
        final word = entry.value;
        final id = LearningStore.wordId(
          level: word.level,
          hanzi: word.hanzi,
          pinyin: word.pinyin,
        );
        return !learned.contains(id);
      }).toList();

      available.sort((a, b) {
        final aId = LearningStore.wordId(
          level: a.value.level,
          hanzi: a.value.hanzi,
          pinyin: a.value.pinyin,
        );
        final bId = LearningStore.wordId(
          level: b.value.level,
          hanzi: b.value.hanzi,
          pinyin: b.value.pinyin,
        );

        final aDeferred = deferred.contains(aId);
        final bDeferred = deferred.contains(bId);

        if (aDeferred != bDeferred) {
          return aDeferred ? -1 : 1;
        }

        return a.key.compareTo(b.key);
      });

      if (!mounted) return;

      setState(() {
        _words = available.map((entry) => entry.value).toList();
        _index = 0;
        _earnedXp = 0;
        _autoPlay = autoPlay;
        _dailyGoal = dailyGoal;
        _goalLocked = goalLocked;
        _todayLearned = todayLearned;
        _totalLearned = totalLearned;
        _totalXp = totalXp;
        _loading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _playCurrentWord();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'শব্দ লোড করা যায়নি: $e';
        _loading = false;
      });
    }
  }

  String _idOf(VocabWord word) {
    return LearningStore.wordId(
      level: word.level,
      hanzi: word.hanzi,
      pinyin: word.pinyin,
    );
  }

  Future<void> _moveNext({int earned = 0}) async {
    setState(() {
      _earnedXp += earned;
      _busy = false;

      if (_index < _words.length - 1) {
        _index++;
      } else {
        _index = _words.length;
      }
    });

    await _refreshListeningStats();

    if (_index < _words.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _playCurrentWord();
      });
    } else {
      await SpeechService.stop();
    }
  }

  Future<void> _understood() async {
    if (_busy || _index >= _words.length) return;

    setState(() => _busy = true);

    try {
      final earned = await LearningStore.markListeningWordLearned(
        _idOf(_words[_index]),
      );

      if (!mounted) return;

      _moveNext(earned: earned ? 1 : 0);

      if (earned) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('+1 XP! শব্দটি শেখা হয়েছে 🎉'),
            duration: Duration(milliseconds: 900),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('সংরক্ষণ করা যায়নি: $e')),
      );
    }
  }

  Future<void> _defer() async {
    if (_busy || _index >= _words.length) return;

    setState(() => _busy = true);

    try {
      await LearningStore.deferListeningWord(
        _idOf(_words[_index]),
      );

      if (!mounted) return;
      _moveNext();
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Review-তে রাখা যায়নি: $e')),
      );
    }
  }

  Widget _buildFinished() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              size: 76,
              color: _gold,
            ),
            const SizedBox(height: 18),
            const Text(
              'আজকের Listening শেষ!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'এই সেশনে অর্জিত XP: +$_earnedXp',
              style: const TextStyle(fontSize: 18, color: _gold),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loadWords,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('আবার অনুশীলন করুন'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: 76,
              color: Colors.green,
            ),
            const SizedBox(height: 18),
            const Text(
              'সব HSK শব্দ শেখা শেষ!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'তোমার শেখা শব্দগুলো Learning Progress-এ সংরক্ষিত আছে।',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            OutlinedButton.icon(
              onPressed: _loadWords,
              icon: const Icon(Icons.refresh),
              label: const Text('আবার দেখুন'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListeningDashboard() {
    final progress =
        _dailyGoal <= 0 ? 0.0 : (_todayLearned / _dailyGoal).clamp(0.0, 1.0);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: _gold.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag_rounded, color: _gold),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'দৈনিক Listening Goal',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DropdownButton<int>(
                  value: _dailyGoal,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: 5, child: Text('৫ শব্দ')),
                    DropdownMenuItem(value: 10, child: Text('১০ শব্দ')),
                    DropdownMenuItem(value: 20, child: Text('২০ শব্দ')),
                  ],
                  onChanged: _goalLocked ? null : _changeDailyGoal,
                ),
              ],
            ),
            if (_goalLocked)
              const Text(
                'আজকের লক্ষ্য নির্ধারিত — আগামীকাল পরিবর্তন করতে পারবে।',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('আজ শেখা: $_todayLearned / $_dailyGoal'),
                Text('${(progress * 100).round()}%'),
              ],
            ),
            const SizedBox(height: 7),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 9,
                color: const Color(0xFF27834A),
                backgroundColor: _gold.withValues(alpha: 0.15),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _statItem(
                    Icons.menu_book_rounded,
                    'মোট শেখা',
                    '$_totalLearned',
                  ),
                ),
                Expanded(
                  child: _statItem(
                    Icons.bolt_rounded,
                    'মোট XP',
                    '$_totalXp',
                  ),
                ),
              ],
            ),
            const Divider(height: 22),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text(
                'স্বয়ংক্রিয় চীনা অডিও',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'প্রতিটি নতুন শব্দ এলে নিজে থেকে বাজবে',
                style: TextStyle(fontSize: 11),
              ),
              secondary: const Icon(Icons.volume_up_rounded, color: _gold),
              value: _autoPlay,
              onChanged: _busy ? null : _toggleAutoPlay,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: _gold, size: 22),
        const SizedBox(width: 7),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(
                value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPractice(VocabWord word) {
    final meaning =
        word.meaningBn.trim().isNotEmpty ? word.meaningBn : word.meaning;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      child: Column(
        children: [
          _buildListeningDashboard(),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HSK ${word.level}',
                style: const TextStyle(
                  color: _gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'শব্দ ${_index + 1} / ${_words.length}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: (_index + 1) / _words.length,
            minHeight: 6,
            borderRadius: BorderRadius.circular(20),
            color: _gold,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (_busy) return;

              final velocity = details.primaryVelocity ?? 0;
              if (velocity > 250) {
                _understood();
              } else if (velocity < -250) {
                _defer();
              }
            },
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: _gold.withValues(alpha: 0.45),
                  width: 1.3,
                ),
              ),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 30,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.headphones_rounded,
                      color: _gold,
                      size: 34,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      word.hanzi,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 54,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      word.pinyin,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 23,
                        color: Color(0xFFB8860B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      meaning,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20),
                    ),
                    if (word.example.trim().isNotEmpty) ...[
                      const SizedBox(height: 22),
                      const Divider(),
                      const SizedBox(height: 12),
                      Text(
                        word.example,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 19),
                      ),
                      if (word.examplePinyin.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          word.examplePinyin,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      if (word.translation.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          word.translation,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ],
                    const SizedBox(height: 18),
                    Text(
                      'ডানদিকে Swipe = বুঝেছি  •  বামদিকে Swipe = পরে',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed:
                _busy ? null : () => SpeechService.speakChinese(word.hanzi),
            icon: const Icon(Icons.volume_up_rounded),
            label: const Text('শব্দটি শুনুন'),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: _busy ? null : _defer,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('← পরে শিখবো'),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: FilledButton(
                    onPressed: _busy ? null : _understood,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF27834A),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('বুঝেছি →'),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_busy) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(color: _gold),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    SpeechService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finished = _index >= _words.length && _words.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Listening Practice')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _loadWords,
                          child: const Text('আবার চেষ্টা করুন'),
                        ),
                      ],
                    ),
                  ),
                )
              : _words.isEmpty
                  ? _buildEmpty()
                  : finished
                      ? _buildFinished()
                      : _buildPractice(_words[_index]),
    );
  }
}

class SpeakingPracticeScreen extends StatefulWidget {
  const SpeakingPracticeScreen({super.key});

  @override
  State<SpeakingPracticeScreen> createState() => _SpeakingPracticeScreenState();
}

class _SpeakingPracticeScreenState extends State<SpeakingPracticeScreen> {
  int _index = 0;
  int _done = 0;

  Future<void> _practiceDone() async {
    await _recordLearningProgress();
    if (!mounted) return;

    setState(() {
      _done++;
      if (_index < _phrases.length - 1) _index++;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('অনুশীলন সংরক্ষণ হয়েছে! +XP'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final phrase = _phrases[_index];

    return Scaffold(
      appBar: AppBar(title: const Text('Speaking Practice')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          LinearProgressIndicator(
            value: _done / _phrases.length,
            minHeight: 8,
            color: _gold,
          ),
          const SizedBox(height: 20),
          Text(
            'অনুশীলন ${_index + 1} / ${_phrases.length}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          Text(
            phrase.chinese,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            phrase.pinyin,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFB8860B),
              fontSize: 21,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            phrase.bengali,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17),
          ),
          const SizedBox(height: 30),
          FilledButton.icon(
            onPressed: () => SpeechService.speakChinese(phrase.chinese),
            icon: const Icon(Icons.volume_up_rounded),
            label: const Text('উচ্চারণ শুনুন'),
          ),
          const SizedBox(height: 10),
          FilledButton.tonalIcon(
            onPressed: _practiceDone,
            icon: const Icon(Icons.record_voice_over_rounded),
            label: const Text('আমি নিজে বলেছি'),
          ),
          const SizedBox(height: 18),
          const Text(
            'টিপস: প্রথমে অডিও শুনো, তারপর ধীরে ধীরে একইভাবে বলার চেষ্টা করো।',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.6),
          ),
          const SizedBox(height: 12),
          const Text(
            'নোট: এই সংস্করণে মাইক্রোফোন দিয়ে উচ্চারণ যাচাই করা হয় না।',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _DialogueLine {
  final String chinese;
  final String pinyin;
  final String bengali;

  const _DialogueLine(this.chinese, this.pinyin, this.bengali);
}

class _Scenario {
  final String title;
  final String icon;
  final List<_DialogueLine> lines;

  const _Scenario(this.title, this.icon, this.lines);
}

const List<_Scenario> _scenarios = [
  _Scenario('পরিচিত হওয়া', '👋', [
    _DialogueLine('你好！', 'Nǐ hǎo!', 'হ্যালো!'),
    _DialogueLine('你叫什么名字？', 'Nǐ jiào shénme míngzi?', 'তোমার নাম কী?'),
    _DialogueLine('我叫小明。', 'Wǒ jiào Xiǎomíng.', 'আমার নাম শিয়াওমিং।'),
    _DialogueLine('很高兴认识你。', 'Hěn gāoxìng rènshi nǐ.',
        'তোমার সঙ্গে পরিচিত হয়ে ভালো লাগল।'),
  ]),
  _Scenario('রেস্টুরেন্টে', '🍜', [
    _DialogueLine('你想吃什么？', 'Nǐ xiǎng chī shénme?', 'তুমি কী খেতে চাও?'),
    _DialogueLine('我想吃米饭。', 'Wǒ xiǎng chī mǐfàn.', 'আমি ভাত খেতে চাই।'),
    _DialogueLine('你想喝什么？', 'Nǐ xiǎng hē shénme?', 'তুমি কী পান করতে চাও?'),
    _DialogueLine('我想喝水。', 'Wǒ xiǎng hē shuǐ.', 'আমি পানি পান করতে চাই।'),
  ]),
  _Scenario('বাজারে', '🛍️', [
    _DialogueLine('这个多少钱？', 'Zhège duōshao qián?', 'এটার দাম কত?'),
    _DialogueLine('二十块钱。', 'Èrshí kuài qián.', '২০ ইউয়ান।'),
    _DialogueLine('太贵了。', 'Tài guì le.', 'অনেক দাম!'),
    _DialogueLine('可以便宜一点吗？', 'Kěyǐ piányi yìdiǎn ma?', 'একটু কম হবে?'),
  ]),
];

class DailyConversationScreen extends StatefulWidget {
  const DailyConversationScreen({super.key});

  @override
  State<DailyConversationScreen> createState() =>
      _DailyConversationScreenState();
}

class _DailyConversationScreenState extends State<DailyConversationScreen> {
  final Set<int> _completed = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Conversation')),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          const Text(
            'বাস্তব জীবনের Mandarin কথোপকথন অনুশীলন করো।',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < _scenarios.length; i++)
            Card(
              child: ExpansionTile(
                leading: Text(
                  _scenarios[i].icon,
                  style: const TextStyle(fontSize: 27),
                ),
                title: Text(
                  _scenarios[i].title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  _completed.contains(i) ? 'সম্পন্ন ✓' : 'কথোপকথন খুলুন',
                ),
                children: [
                  for (final line in _scenarios[i].lines)
                    ListTile(
                      title: Text(
                        line.chinese,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${line.pinyin}\n${line.bengali}',
                      ),
                      trailing: IconButton(
                        tooltip: 'চীনা উচ্চারণ শুনুন',
                        icon: const Icon(
                          Icons.volume_up_rounded,
                          color: Color(0xFFB8860B),
                        ),
                        onPressed: () =>
                            SpeechService.speakChinese(line.chinese),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 14),
                    child: FilledButton.icon(
                      onPressed: _completed.contains(i)
                          ? null
                          : () async {
                              await _recordLearningProgress();
                              if (!mounted) return;
                              setState(() => _completed.add(i));
                            },
                      icon: const Icon(Icons.check_circle_rounded),
                      label: Text(
                        _completed.contains(i)
                            ? 'সম্পন্ন হয়েছে'
                            : 'এই Conversation শেষ করেছি',
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _QuizQuestion {
  final String chinese;
  final String pinyin;
  final List<String> options;
  final int answer;

  const _QuizQuestion(
    this.chinese,
    this.pinyin,
    this.options,
    this.answer,
  );
}

const List<_QuizQuestion> _quizQuestions = [
  _QuizQuestion(
    '你好',
    'Nǐ hǎo',
    ['ধন্যবাদ', 'হ্যালো', 'বিদায়', 'শুভ সকাল'],
    1,
  ),
  _QuizQuestion(
    '谢谢',
    'Xièxie',
    ['দুঃখিত', 'হ্যালো', 'ধন্যবাদ', 'শুভ রাত্রি'],
    2,
  ),
  _QuizQuestion(
    '再见',
    'Zàijiàn',
    ['বিদায়', 'স্বাগতম', 'দুঃখিত', 'সুপ্রভাত'],
    0,
  ),
  _QuizQuestion(
    '早上好',
    'Zǎoshang hǎo',
    ['শুভ রাত্রি', 'শুভ সকাল', 'ধন্যবাদ', 'কেমন আছ'],
    1,
  ),
  _QuizQuestion(
    '我想喝水',
    'Wǒ xiǎng hē shuǐ',
    ['আমি পানি পান করতে চাই', 'আমি পড়তে চাই', 'আমার নাম', 'তুমি কোথায়'],
    0,
  ),
  _QuizQuestion(
    '多少钱',
    'Duōshao qián',
    ['কোথায় যাবেন?', 'কি খেতে চান?', 'দাম কত?', 'সময় কত?'],
    2,
  ),
];

class ListeningQuizScreen extends StatefulWidget {
  const ListeningQuizScreen({super.key});

  @override
  State<ListeningQuizScreen> createState() => _ListeningQuizScreenState();
}

class _ListeningQuizScreenState extends State<ListeningQuizScreen> {
  int _index = 0;
  int _score = 0;
  int? _selected;
  bool _finished = false;

  Future<void> _finishQuiz() async {
    final prefs = await SharedPreferences.getInstance();
    final best = prefs.getInt('sl_best_quiz') ?? 0;

    if (_score > best) {
      await prefs.setInt('sl_best_quiz', _score);
    }

    await _recordLearningProgress();
    if (!mounted) return;

    setState(() => _finished = true);
  }

  void _answer(int choice) {
    if (_selected != null) return;

    final correct = choice == _quizQuestions[_index].answer;

    setState(() {
      _selected = choice;
      if (correct) _score++;
    });
  }

  Future<void> _next() async {
    if (_index == _quizQuestions.length - 1) {
      await _finishQuiz();
    } else {
      setState(() {
        _index++;
        _selected = null;
      });
    }
  }

  void _restart() {
    setState(() {
      _index = 0;
      _score = 0;
      _selected = null;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Result')),
        body: _FinishedCard(
          title: 'তোমার স্কোর: $_score / ${_quizQuestions.length}',
          message: _score >= 5
              ? 'অসাধারণ! Mandarin শোনার দক্ষতা ভালো হচ্ছে।'
              : 'চেষ্টা চালিয়ে যাও। আবার অনুশীলন করলে আরও ভালো হবে।',
          onRestart: _restart,
        ),
      );
    }

    final question = _quizQuestions[_index];

    return Scaffold(
      appBar: AppBar(title: const Text('Listening Quiz')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('প্রশ্ন ${_index + 1} / ${_quizQuestions.length}'),
              Text(
                'স্কোর: $_score',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: (_index + 1) / _quizQuestions.length,
            color: _gold,
            minHeight: 8,
          ),
          const SizedBox(height: 35),
          const Text(
            'অডিও শুনে সঠিক অর্থ নির্বাচন করো',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Center(
            child: IconButton.filled(
              onPressed: () => SpeechService.speakChinese(question.chinese),
              iconSize: 42,
              icon: const Icon(Icons.volume_up_rounded),
              tooltip: 'অডিও শুনুন',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            question.chinese,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            question.pinyin,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          for (var i = 0; i < question.options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 15,
                  ),
                  alignment: Alignment.centerLeft,
                  backgroundColor: _selected == null
                      ? null
                      : i == question.answer
                          ? Colors.green.withValues(alpha: 0.12)
                          : _selected == i
                              ? Colors.red.withValues(alpha: 0.10)
                              : null,
                  side: BorderSide(
                    color: _selected != null && i == question.answer
                        ? Colors.green
                        : _selected == i
                            ? Colors.red
                            : Theme.of(context).colorScheme.outline,
                  ),
                ),
                onPressed: () => _answer(i),
                child: Row(
                  children: [
                    Expanded(child: Text(question.options[i])),
                    if (_selected != null && i == question.answer)
                      const Icon(Icons.check_circle, color: Colors.green),
                    if (_selected == i && i != question.answer)
                      const Icon(Icons.cancel, color: Colors.red),
                  ],
                ),
              ),
            ),
          if (_selected != null) ...[
            const SizedBox(height: 8),
            Text(
              _selected == question.answer
                  ? 'সঠিক উত্তর! দারুণ করেছ।'
                  : 'সঠিক উত্তর: ${question.options[question.answer]}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _selected == question.answer ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _next,
              child: Text(
                _index == _quizQuestions.length - 1
                    ? 'ফলাফল দেখুন'
                    : 'পরের প্রশ্ন',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FinishedCard extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRestart;

  const _FinishedCard({
    required this.title,
    required this.message,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              size: 78,
              color: _gold,
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(height: 1.6),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRestart,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('আবার অনুশীলন করো'),
            ),
          ],
        ),
      ),
    );
  }
}
