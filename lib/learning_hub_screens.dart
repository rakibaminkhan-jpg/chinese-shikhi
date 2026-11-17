import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/vocab_word.dart';
import 'services/learning_store.dart';
import 'services/speech_service.dart';
import 'services/vocab_service.dart';

const Color _hubGold = Color(0xFFD4AF37);

String _hubDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

String _wordId(VocabWord word) {
  return LearningStore.wordId(
    level: word.level,
    hanzi: word.hanzi,
    pinyin: word.pinyin,
  );
}

String _wordMeaning(VocabWord word) {
  final bn = word.meaningBn.trim();
  return bn.isNotEmpty ? bn : word.meaning.trim();
}

// ============================================================
// 1. DAILY CHALLENGE
// ============================================================

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  Set<String> _completed = {};
  bool _loading = true;
  int _streak = 0;

  late final String _today = _hubDate(DateTime.now());

  String get _storageKey => 'daily_challenge_done_$_today';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getStringList(_storageKey) ?? [];
    final streak = await LearningStore.getStreak();

    if (!mounted) return;

    setState(() {
      _completed = done.toSet();
      _streak = streak;
      _loading = false;
    });
  }

  Future<void> _complete(String id) async {
    if (_completed.contains(id)) return;

    final prefs = await SharedPreferences.getInstance();
    final updated = {..._completed, id};

    await prefs.setStringList(_storageKey, updated.toList());

    if (updated.length == 4) {
      await LearningStore.markActiveDay();
    }

    if (!mounted) return;

    setState(() => _completed = updated);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('দারুণ! আজকের Challenge অগ্রগতি সংরক্ষিত হয়েছে।'),
      ),
    );
  }

  Future<void> _open(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (mounted) _load();
  }

  Widget _challengeCard({
    required String id,
    required IconData icon,
    required String title,
    required String description,
    Widget? action,
  }) {
    final done = _completed.contains(id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _hubGold.withValues(alpha: 0.16),
                  child: Icon(icon, color: const Color(0xFF99720E)),
                ),
                const SizedBox(width: 12),
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
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  done ? Icons.check_circle : Icons.circle_outlined,
                  color: done ? Colors.green : Colors.grey,
                ),
              ],
            ),
            if (action != null) ...[
              const SizedBox(height: 12),
              action,
            ],
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: done ? null : () => _complete(id),
                icon: Icon(
                  done ? Icons.check_circle : Icons.task_alt,
                  size: 18,
                ),
                label: Text(
                  done ? 'সম্পন্ন হয়েছে' : 'আমি কাজটি শেষ করেছি',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _completed.length / 4;

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Challenge')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF191919),
                          Color(0xFF493719),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'আজকের লক্ষ্য',
                          style: TextStyle(
                            color: _hubGold,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 7),
                        const Text(
                          'প্রতিদিন অল্প অল্প অনুশীলন করলেই উন্নতি হবে।',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_completed.length} / 4 কাজ শেষ',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$_streak দিনের Streak',
                              style: const TextStyle(color: _hubGold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            color: _hubGold,
                            backgroundColor: Colors.white24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'আজকের ৪টি কাজ',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 19,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _challengeCard(
                    id: 'revision',
                    icon: Icons.style_rounded,
                    title: 'Vocabulary Revision',
                    description: 'আগে শেখা ৫টি শব্দ আবার পড়ো।',
                    action: Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: () => _open(
                          const VocabularyRevisionScreen(),
                        ),
                        icon: const Icon(Icons.menu_book_rounded),
                        label: const Text('শব্দ পুনরাবৃত্তি খোলো'),
                      ),
                    ),
                  ),
                  _challengeCard(
                    id: 'listening',
                    icon: Icons.headphones_rounded,
                    title: 'Listening Challenge',
                    description:
                        'Mandarin উচ্চারণ শুনে অর্থ মনে করার চেষ্টা করো।',
                    action: Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => SpeechService.speakChinese('你好，谢谢。'),
                          icon: const Icon(Icons.volume_up_rounded),
                          label: const Text('অডিও ১'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => SpeechService.speakChinese(
                            '我想学中文。',
                          ),
                          icon: const Icon(Icons.volume_up_rounded),
                          label: const Text('অডিও ২'),
                        ),
                      ],
                    ),
                  ),
                  _challengeCard(
                    id: 'exam',
                    icon: Icons.quiz_rounded,
                    title: 'HSK Mini Exam',
                    description: 'কমপক্ষে ৫টি HSK প্রশ্নের উত্তর দাও।',
                    action: Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: () => _open(
                          const HSKExamCenterScreen(),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('HSK পরীক্ষা খোলো'),
                      ),
                    ),
                  ),
                  _challengeCard(
                    id: 'speaking',
                    icon: Icons.record_voice_over_rounded,
                    title: 'Speaking Challenge',
                    description: 'একটি চীনা বাক্য শুনে নিজে বলার চেষ্টা করো।',
                    action: OutlinedButton.icon(
                      onPressed: () => SpeechService.speakChinese(
                        '你好，我想学中文。',
                      ),
                      icon: const Icon(Icons.volume_up_rounded),
                      label: const Text('বাক্য শুনো'),
                    ),
                  ),
                  if (_completed.length == 4)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Icon(
                              Icons.emoji_events_rounded,
                              color: _hubGold,
                              size: 35,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'অভিনন্দন! আজকের সব Challenge সম্পন্ন হয়েছে।',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 15),
                  const Text(
                    'নোট: কাজগুলো নিজে সম্পন্ন করে চিহ্নিত করবে।',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
    );
  }
}

// ============================================================
// 2. PROGRESS DASHBOARD
// ============================================================

class ProgressDashboardScreen extends StatefulWidget {
  const ProgressDashboardScreen({super.key});

  @override
  State<ProgressDashboardScreen> createState() =>
      _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState extends State<ProgressDashboardScreen> {
  bool _loading = true;

  int _xp = 0;
  int _level = 1;
  int _streak = 0;
  int _learned = 0;
  int _todayLearned = 0;
  int _favorites = 0;
  int _totalSeconds = 0;
  int _todaySeconds = 0;
  int _activeDays = 0;
  int _dailyGoal = 5;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait<dynamic>([
      LearningStore.getTotalXp(),
      LearningStore.getLearningLevel(),
      LearningStore.getStreak(),
      LearningStore.getTotalLearnedCount(),
      LearningStore.getTodayLearnedCount(),
      LearningStore.getFavorites(),
      LearningStore.getTotalStudySeconds(),
      LearningStore.getTodayStudySeconds(),
      LearningStore.getDailyGoal(),
    ]);

    final prefs = await SharedPreferences.getInstance();
    final activeDays = prefs.getStringList('learning_active_days') ?? [];

    if (!mounted) return;

    setState(() {
      _xp = results[0] as int;
      _level = results[1] as int;
      _streak = results[2] as int;
      _learned = results[3] as int;
      _todayLearned = results[4] as int;
      _favorites = (results[5] as Set<String>).length;
      _totalSeconds = results[6] as int;
      _todaySeconds = results[7] as int;
      _dailyGoal = results[8] as int;
      _activeDays = activeDays.length;
      _loading = false;
    });
  }

  Widget _tile(
    IconData icon,
    String title,
    String value,
    String subtitle,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: _hubGold, size: 27),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final levelProgress = (_xp % 100) / 100;
    final todayProgress = (_todayLearned / _dailyGoal).clamp(0.0, 1.0);

    final totalHours = _totalSeconds ~/ 3600;
    final totalMinutes = (_totalSeconds % 3600) ~/ 60;
    final todayMinutes = _todaySeconds ~/ 60;

    return Scaffold(
      appBar: AppBar(title: const Text('Learning Progress')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF191919),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'তোমার শেখার অগ্রগতি',
                          style: TextStyle(
                            color: _hubGold,
                            fontWeight: FontWeight.w900,
                            fontSize: 21,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Level $_level',
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              '$_xp XP',
                              style: const TextStyle(
                                color: _hubGold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: levelProgress,
                            minHeight: 10,
                            color: _hubGold,
                            backgroundColor: Colors.white24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_xp % 100} / 100 XP — পরবর্তী Level',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.45,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _tile(
                        Icons.menu_book_rounded,
                        'শেখা শব্দ',
                        '$_learned',
                        'মোট শেখা Vocabulary',
                      ),
                      _tile(
                        Icons.local_fire_department_rounded,
                        'Streak',
                        '$_streak দিন',
                        'ধারাবাহিক শেখার দিন',
                      ),
                      _tile(
                        Icons.favorite_rounded,
                        'Favorite',
                        '$_favorites',
                        'প্রিয় শব্দ',
                      ),
                      _tile(
                        Icons.calendar_today_rounded,
                        'Active Days',
                        '$_activeDays',
                        'মোট শেখার দিন',
                      ),
                      _tile(
                        Icons.today_rounded,
                        'আজ শেখা',
                        '$_todayLearned',
                        'আজকের নতুন শব্দ',
                      ),
                      _tile(
                        Icons.timer_rounded,
                        'আজকের সময়',
                        '$todayMinutes মিনিট',
                        'আজকের Study Time',
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(17),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Daily Learning Goal',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '$_todayLearned / $_dailyGoal শব্দ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 9),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: todayProgress,
                              minHeight: 10,
                              color: _hubGold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            todayProgress >= 1
                                ? 'আজকের লক্ষ্য পূরণ হয়েছে!'
                                : 'আর ${(_dailyGoal - _todayLearned).clamp(0, _dailyGoal)}টি শব্দ শিখলেই লক্ষ্য পূরণ হবে।',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.hourglass_bottom_rounded,
                        color: _hubGold,
                      ),
                      title: const Text('মোট পড়াশোনার সময়'),
                      subtitle: Text(
                        '$totalHours ঘণ্টা $totalMinutes মিনিট',
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ============================================================
// 3. ACHIEVEMENT CENTER
// ============================================================

class _Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int progress;
  final int target;

  const _Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.progress,
    required this.target,
  });
}

class AchievementCenterScreen extends StatefulWidget {
  const AchievementCenterScreen({super.key});

  @override
  State<AchievementCenterScreen> createState() =>
      _AchievementCenterScreenState();
}

class _AchievementCenterScreenState extends State<AchievementCenterScreen> {
  bool _loading = true;
  List<_Achievement> _items = [];
  Set<String> _unlocked = {};
  int _xp = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final learned = await LearningStore.getTotalLearnedCount();
    final streak = await LearningStore.getStreak();
    final xp = await LearningStore.getTotalXp();
    final seconds = await LearningStore.getTotalStudySeconds();

    final prefs = await SharedPreferences.getInstance();
    final activeDays = prefs.getStringList('learning_active_days') ?? [];

    final items = [
      _Achievement(
        id: 'first_word',
        title: 'প্রথম শব্দ',
        description: 'প্রথম Chinese Vocabulary শেখো।',
        icon: Icons.looks_one_rounded,
        progress: learned,
        target: 1,
      ),
      _Achievement(
        id: 'words_10',
        title: 'শব্দ সংগ্রাহক',
        description: '১০টি Chinese শব্দ শেখো।',
        icon: Icons.menu_book_rounded,
        progress: learned,
        target: 10,
      ),
      _Achievement(
        id: 'words_50',
        title: 'Vocabulary Master',
        description: '৫০টি শব্দ শেখো।',
        icon: Icons.auto_stories_rounded,
        progress: learned,
        target: 50,
      ),
      _Achievement(
        id: 'streak_3',
        title: '৩ দিনের ধারাবাহিকতা',
        description: 'টানা ৩ দিন অনুশীলন করো।',
        icon: Icons.local_fire_department_rounded,
        progress: streak,
        target: 3,
      ),
      _Achievement(
        id: 'streak_7',
        title: 'সাপ্তাহিক যোদ্ধা',
        description: 'টানা ৭ দিন শেখার চেষ্টা করো।',
        icon: Icons.military_tech_rounded,
        progress: streak,
        target: 7,
      ),
      _Achievement(
        id: 'xp_100',
        title: 'প্রথম শত XP',
        description: '১০০ XP অর্জন করো।',
        icon: Icons.stars_rounded,
        progress: xp,
        target: 100,
      ),
      _Achievement(
        id: 'study_60',
        title: 'এক ঘণ্টার শিক্ষার্থী',
        description: 'মোট ৬০ মিনিট পড়াশোনা করো।',
        icon: Icons.timer_rounded,
        progress: seconds,
        target: 3600,
      ),
      _Achievement(
        id: 'active_5',
        title: 'নিয়মিত শিক্ষার্থী',
        description: 'মোট ৫ দিন শেখার কাজে সক্রিয় থাকো।',
        icon: Icons.calendar_month_rounded,
        progress: activeDays.length,
        target: 5,
      ),
    ];

    final eligible = {
      for (final item in items) item.id: item.progress >= item.target,
    };

    // প্রতিটি Achievement একবারই ২৫ XP Bonus দিতে পারবে।
    await LearningStore.awardAchievementXp(eligible: eligible);

    final updatedPrefs = await SharedPreferences.getInstance();
    final unlocked =
        (updatedPrefs.getStringList('unlocked_achievement_ids') ?? []).toSet();

    final updatedXp = await LearningStore.getTotalXp();

    if (!mounted) return;

    setState(() {
      _items = items;
      _unlocked = unlocked;
      _xp = updatedXp;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final unlockedCount = _unlocked.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Achievement Center')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF191919),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.emoji_events_rounded,
                          size: 47,
                          color: _hubGold,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'তোমার অর্জন',
                                style: TextStyle(
                                  color: _hubGold,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '$unlockedCount / ${_items.length}টি Badge আনলক',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'মোট XP: $_xp',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  for (final item in _items) _buildAchievementCard(item),
                  const SizedBox(height: 12),
                  const Text(
                    'নতুন অর্জন হলে ২৫ XP Bonus যোগ হবে।',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAchievementCard(_Achievement item) {
    final isUnlocked = _unlocked.contains(item.id);
    final progress = (item.progress / item.target).clamp(0.0, 1.0);

    String valueLabel;
    if (item.id == 'study_60') {
      valueLabel = '${item.progress ~/ 60} / ${item.target ~/ 60} মিনিট';
    } else {
      valueLabel = '${item.progress} / ${item.target}';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 11),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: isUnlocked
                  ? _hubGold.withValues(alpha: 0.20)
                  : Colors.grey.withValues(alpha: 0.12),
              child: Icon(
                item.icon,
                size: 27,
                color: isUnlocked ? const Color(0xFF9B7410) : Colors.grey,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Icon(
                        isUnlocked
                            ? Icons.verified_rounded
                            : Icons.lock_outline_rounded,
                        color: isUnlocked ? Colors.green : Colors.grey,
                        size: 19,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 9),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 7,
                      color: isUnlocked ? Colors.green : _hubGold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isUnlocked ? 'আনলক হয়েছে ✓' : valueLabel,
                    style: TextStyle(
                      color: isUnlocked ? Colors.green : Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 4. VOCABULARY REVISION
// ============================================================

class VocabularyRevisionScreen extends StatefulWidget {
  const VocabularyRevisionScreen({super.key});

  @override
  State<VocabularyRevisionScreen> createState() =>
      _VocabularyRevisionScreenState();
}

class _VocabularyRevisionScreenState extends State<VocabularyRevisionScreen> {
  bool _loading = true;
  bool _showFavorites = false;
  bool _revealed = false;

  int _index = 0;
  List<VocabWord> _allWords = [];
  Set<String> _learned = {};
  Set<String> _favorites = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      VocabService.loadWords(),
      LearningStore.getLearnedWords(),
      LearningStore.getFavorites(),
    ]);

    if (!mounted) return;

    setState(() {
      _allWords = results[0] as List<VocabWord>;
      _learned = results[1] as Set<String>;
      _favorites = results[2] as Set<String>;
      _loading = false;
      _index = 0;
      _revealed = false;
    });
  }

  List<VocabWord> get _visibleWords {
    return _allWords.where((word) {
      final id = _wordId(word);
      return _showFavorites ? _favorites.contains(id) : _learned.contains(id);
    }).toList();
  }

  Future<void> _next() async {
    final words = _visibleWords;
    if (words.isEmpty) return;

    final word = words[_index];
    final prefs = await SharedPreferences.getInstance();
    final reviewed =
        (prefs.getStringList('vocab_revision_reviewed') ?? []).toSet();

    reviewed.add(_wordId(word));
    await prefs.setStringList(
      'vocab_revision_reviewed',
      reviewed.toList(),
    );

    if (!mounted) return;

    setState(() {
      _index = (_index + 1) % words.length;
      _revealed = false;
    });
  }

  Future<void> _toggleFavorite(VocabWord word) async {
    await LearningStore.toggleFavorite(_wordId(word));
    final favorites = await LearningStore.getFavorites();

    if (!mounted) return;

    setState(() {
      _favorites = favorites;
      if (_showFavorites && _visibleWords.isEmpty) {
        _index = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final words = _visibleWords;

    final safeIndex = words.isEmpty ? 0 : _index.clamp(0, words.length - 1);

    final word = words.isEmpty ? null : words[safeIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Vocabulary Revision')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'আগে শেখা শব্দগুলো আবার মনে করার অনুশীলন করো।',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text('শেখা শব্দ (${_learned.length})'),
                      selected: !_showFavorites,
                      onSelected: (_) => setState(() {
                        _showFavorites = false;
                        _index = 0;
                        _revealed = false;
                      }),
                    ),
                    ChoiceChip(
                      label: Text('Favorite (${_favorites.length})'),
                      selected: _showFavorites,
                      onSelected: (_) => setState(() {
                        _showFavorites = true;
                        _index = 0;
                        _revealed = false;
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (word == null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.menu_book_rounded,
                            size: 55,
                            color: _hubGold,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _showFavorites
                                ? 'এখনো Favorite শব্দ নেই।'
                                : 'এখনো শেখা শব্দ পাওয়া যায়নি।',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'শিখুন ট্যাব থেকে শব্দ শিখে Favorite করো। '
                            'তারপর এখানে ফিরে পুনরাবৃত্তি করতে পারবে।',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'শব্দ ${safeIndex + 1} / ${words.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'HSK ${word.level}',
                        style: const TextStyle(
                          color: Color(0xFFB8860B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        children: [
                          Text(
                            word.hanzi,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 47,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            word.pinyin,
                            style: const TextStyle(
                              color: Color(0xFFB8860B),
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 20),
                          FilledButton.tonalIcon(
                            onPressed: () =>
                                SpeechService.speakChinese(word.hanzi),
                            icon: const Icon(Icons.volume_up_rounded),
                            label: const Text('উচ্চারণ শুনুন'),
                          ),
                          const SizedBox(height: 14),
                          if (_revealed) ...[
                            const Divider(),
                            Text(
                              word.meaningBn.isNotEmpty
                                  ? word.meaningBn
                                  : word.meaning,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (word.meaningBn.isNotEmpty &&
                                word.meaning.isNotEmpty)
                              Text(
                                word.meaning,
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            if (word.example.isNotEmpty) ...[
                              const SizedBox(height: 18),
                              Text(
                                word.example,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                word.examplePinyin,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                word.translation,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ] else
                            const Text(
                              'অর্থ মনে করার চেষ্টা করো। তারপর উত্তর দেখো।',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () => setState(
                                () => _revealed = !_revealed,
                              ),
                              child: Text(
                                _revealed ? 'উত্তর লুকাও' : 'অর্থ দেখাও',
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () => _toggleFavorite(word),
                            icon: Icon(
                              _favorites.contains(_wordId(word))
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                            ),
                            label: Text(
                              _favorites.contains(_wordId(word))
                                  ? 'Favorite থেকে সরাও'
                                  : 'Favorite করো',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: words.length < 2
                              ? null
                              : () => setState(() {
                                    _index = (_index - 1 + words.length) %
                                        words.length;
                                    _revealed = false;
                                  }),
                          child: const Text('আগের শব্দ'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _next,
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('পরের শব্দ'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }
}

// ============================================================
// 5. HSK EXAM CENTER
// ============================================================

class _ExamQuestion {
  final VocabWord word;
  final List<String> options;
  final String answer;

  const _ExamQuestion({
    required this.word,
    required this.options,
    required this.answer,
  });
}

class HSKExamCenterScreen extends StatefulWidget {
  const HSKExamCenterScreen({super.key});

  @override
  State<HSKExamCenterScreen> createState() => _HSKExamCenterScreenState();
}

class _HSKExamCenterScreenState extends State<HSKExamCenterScreen> {
  final Random _random = Random();

  bool _loading = true;
  bool _running = false;
  bool _finished = false;

  int _level = 1;
  int _index = 0;
  int _score = 0;
  int? _selected;

  int _bestScore = 0;
  int _attempts = 0;

  List<VocabWord> _allWords = [];
  List<_ExamQuestion> _questions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final words = await VocabService.loadWords();
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _allWords = words;
      _loading = false;
      _bestScore = prefs.getInt('hsk_exam_best_$_level') ?? 0;
      _attempts = prefs.getInt('hsk_exam_attempts_$_level') ?? 0;
    });
  }

  int _countForLevel(int level) {
    return _allWords.where((word) => word.level == level).length;
  }

  Future<void> _selectLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _level = level;
      _bestScore = prefs.getInt('hsk_exam_best_$level') ?? 0;
      _attempts = prefs.getInt('hsk_exam_attempts_$level') ?? 0;
    });
  }

  Future<void> _startExam() async {
    final levelWords = _allWords.where((word) => word.level == _level).toList()
      ..shuffle(_random);

    final questions = <_ExamQuestion>[];

    for (final word in levelWords.take(10)) {
      final correct = _wordMeaning(word);
      if (correct.isEmpty) continue;

      final distractors = _allWords
          .map(_wordMeaning)
          .where((meaning) => meaning.isNotEmpty && meaning != correct)
          .toSet()
          .toList()
        ..shuffle(_random);

      if (distractors.length < 3) continue;

      final options = [
        correct,
        ...distractors.take(3),
      ]..shuffle(_random);

      questions.add(
        _ExamQuestion(
          word: word,
          options: options,
          answer: correct,
        ),
      );
    }

    if (questions.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('এই HSK Level-এর পর্যাপ্ত শব্দ পাওয়া যায়নি।'),
        ),
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      _questions = questions;
      _index = 0;
      _score = 0;
      _selected = null;
      _running = true;
      _finished = false;
    });
  }

  void _answer(String option) {
    if (_selected != null) return;

    final correct = option == _questions[_index].answer;

    setState(() {
      _selected = _questions[_index].options.indexOf(option);
      if (correct) _score++;
    });
  }

  Future<void> _finishExam() async {
    final prefs = await SharedPreferences.getInstance();

    final bestKey = 'hsk_exam_best_$_level';
    final attemptsKey = 'hsk_exam_attempts_$_level';

    final oldBest = prefs.getInt(bestKey) ?? 0;
    final attempts = prefs.getInt(attemptsKey) ?? 0;

    await prefs.setInt(bestKey, max(oldBest, _score));
    await prefs.setInt(attemptsKey, attempts + 1);
    await prefs.setString(
      'hsk_exam_last_date_$_level',
      _hubDate(DateTime.now()),
    );

    if (!mounted) return;

    setState(() {
      _bestScore = max(oldBest, _score);
      _attempts = attempts + 1;
      _running = false;
      _finished = true;
    });
  }

  Future<void> _next() async {
    if (_index == _questions.length - 1) {
      await _finishExam();
      return;
    }

    setState(() {
      _index++;
      _selected = null;
    });
  }

  void _returnToCenter() {
    setState(() {
      _running = false;
      _finished = false;
      _questions = [];
      _index = 0;
      _score = 0;
      _selected = null;
    });
  }

  Widget _levelCard(int level) {
    final count = _countForLevel(level);
    final selected = _level == level;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: count == 0 ? null : () => _selectLevel(level),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
          decoration: BoxDecoration(
            color: selected
                ? _hubGold.withValues(alpha: 0.18)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected ? _hubGold : Colors.grey.withValues(alpha: 0.2),
              width: selected ? 1.7 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                'HSK $level',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: count == 0 ? Colors.grey : null,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '$count শব্দ',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('HSK Exam Center')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_finished) {
      final percent = (_score / _questions.length * 100).round();

      return Scaffold(
        appBar: AppBar(title: const Text('Exam Result')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  size: 78,
                  color: _hubGold,
                ),
                const SizedBox(height: 15),
                Text(
                  'HSK $_level পরীক্ষার ফলাফল',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$_score / ${_questions.length}',
                  style: const TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFB8860B),
                  ),
                ),
                Text('$percent% সঠিক উত্তর'),
                const SizedBox(height: 10),
                Text(
                  percent >= 80
                      ? 'অসাধারণ! তোমার প্রস্তুতি ভালো।'
                      : percent >= 50
                          ? 'ভালো চেষ্টা! আরও অনুশীলন করো।'
                          : 'আবার অনুশীলন করো, ধীরে ধীরে উন্নতি হবে।',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'সেরা স্কোর: $_bestScore | পরীক্ষা: $_attempts বার',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: _returnToCenter,
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Exam Center-এ ফিরে যাও'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _startExam,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('আবার পরীক্ষা দাও'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_running) {
      final question = _questions[_index];

      return Scaffold(
        appBar: AppBar(
          title: Text('HSK $_level Exam'),
          actions: [
            TextButton(
              onPressed: _returnToCenter,
              child: const Text('বের হও'),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'প্রশ্ন ${_index + 1} / ${_questions.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'স্কোর: $_score',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: (_index + 1) / _questions.length,
              color: _hubGold,
              minHeight: 8,
            ),
            const SizedBox(height: 28),
            const Text(
              'শব্দটির সঠিক বাংলা অর্থ নির্বাচন করো।',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 18),
            Text(
              question.word.hanzi,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              question.word.pinyin,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFB8860B),
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: IconButton.filled(
                onPressed: () => SpeechService.speakChinese(
                  question.word.hanzi,
                ),
                icon: const Icon(Icons.volume_up_rounded),
                iconSize: 28,
              ),
            ),
            const SizedBox(height: 22),
            for (var i = 0; i < question.options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(16),
                    backgroundColor: _selected == null
                        ? null
                        : question.options[i] == question.answer
                            ? Colors.green.withValues(alpha: 0.12)
                            : _selected == i
                                ? Colors.red.withValues(alpha: 0.10)
                                : null,
                    side: BorderSide(
                      color: _selected != null &&
                              question.options[i] == question.answer
                          ? Colors.green
                          : _selected == i
                              ? Colors.red
                              : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  onPressed: () => _answer(question.options[i]),
                  child: Row(
                    children: [
                      Expanded(child: Text(question.options[i])),
                      if (_selected != null &&
                          question.options[i] == question.answer)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                      if (_selected == i &&
                          question.options[i] != question.answer)
                        const Icon(Icons.cancel, color: Colors.red),
                    ],
                  ),
                ),
              ),
            if (_selected != null) ...[
              const SizedBox(height: 8),
              Text(
                question.options[_selected!] == question.answer
                    ? 'সঠিক উত্তর!'
                    : 'সঠিক উত্তর: ${question.answer}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: question.options[_selected!] == question.answer
                      ? Colors.green
                      : Colors.red,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(
                    _index == _questions.length - 1
                        ? 'ফলাফল দেখো'
                        : 'পরের প্রশ্ন',
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('HSK Exam Center')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF191919),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'নিজেকে যাচাই করো!',
                  style: TextStyle(
                    color: _hubGold,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'প্রতিটি পরীক্ষায় সর্বোচ্চ ১০টি Vocabulary প্রশ্ন থাকবে।',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'HSK Level নির্বাচন করো',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _levelCard(1),
              const SizedBox(width: 8),
              _levelCard(2),
              const SizedBox(width: 8),
              _levelCard(3),
              const SizedBox(width: 8),
              _levelCard(4),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HSK $_level প্রস্তুতি',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _infoLine(
                    Icons.menu_book_rounded,
                    'এই Level-এর শব্দ',
                    '${_countForLevel(_level)}টি',
                  ),
                  _infoLine(
                    Icons.quiz_rounded,
                    'প্রতি পরীক্ষায় প্রশ্ন',
                    'সর্বোচ্চ ১০টি',
                  ),
                  _infoLine(
                    Icons.emoji_events_rounded,
                    'সেরা স্কোর',
                    '$_bestScore',
                  ),
                  _infoLine(
                    Icons.history_rounded,
                    'পরীক্ষা দেওয়া হয়েছে',
                    '$_attempts বার',
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed:
                          _countForLevel(_level) == 0 ? null : _startExam,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('পরীক্ষা শুরু করো'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoLine(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, color: _hubGold, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(title)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
