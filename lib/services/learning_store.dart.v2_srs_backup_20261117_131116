import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LearningStore {
  static const String _favoriteKey = 'favorite_words';
  static const String _learnedKey = 'learned_words';
  static const String _dailyGoalKey = 'daily_goal';
  static const String _dailyGoalDateKey = 'daily_goal_selected_date';
  static const String _activeDaysKey = 'learning_active_days';

  static String wordId({
    required int level,
    required String hanzi,
    required String pinyin,
  }) {
    return '$level|$hanzi|$pinyin';
  }

  static String _today() {
    final now = DateTime.now();
    return _dateKey(now);
  }

  static String _dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static Future<Set<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_favoriteKey) ?? []).toSet();
  }

  static Future<bool> isFavorite(String id) async {
    final favorites = await getFavorites();
    return favorites.contains(id);
  }

  static Future<void> toggleFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = (prefs.getStringList(_favoriteKey) ?? []).toSet();

    if (favorites.contains(id)) {
      favorites.remove(id);
    } else {
      favorites.add(id);
    }

    await prefs.setStringList(_favoriteKey, favorites.toList());
  }

  static Future<Set<String>> getLearnedWords() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_learnedKey) ?? []).toSet();
  }

  static Future<bool> isLearned(String id) async {
    final learned = await getLearnedWords();
    return learned.contains(id);
  }

  static Future<void> markLearned(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final learned = (prefs.getStringList(_learnedKey) ?? []).toSet();

    if (!learned.add(id)) return;

    await prefs.setStringList(_learnedKey, learned.toList());

    final today = _today();
    final todayKey = 'learned_on_$today';
    final todayWords = (prefs.getStringList(todayKey) ?? []).toSet();
    todayWords.add(id);
    await prefs.setStringList(todayKey, todayWords.toList());

    final activeDays = (prefs.getStringList(_activeDaysKey) ?? []).toSet();
    activeDays.add(today);
    await prefs.setStringList(_activeDaysKey, activeDays.toList());
  }

  // Listening Practice-এর জন্য আলাদা Review ও একবারের XP tracking।
  static const String _listeningXpWordsKey = 'listening_xp_awarded_words';
  static const String _listeningDeferredKey = 'listening_deferred_words';

  static Future<Set<String>> getDeferredListeningWords() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_listeningDeferredKey) ?? []).toSet();
  }

  static Future<void> deferListeningWord(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final deferred = (prefs.getStringList(_listeningDeferredKey) ?? []).toSet();

    deferred.add(id);
    await prefs.setStringList(_listeningDeferredKey, deferred.toList());
  }

  // প্রতিটি শব্দ থেকে Listening-এ সর্বোচ্চ একবার ১ XP।
  static Future<bool> markListeningWordLearned(String id) async {
    final prefs = await SharedPreferences.getInstance();

    final learned = (prefs.getStringList(_learnedKey) ?? []).toSet();
    final newlyLearned = learned.add(id);

    if (newlyLearned) {
      await prefs.setStringList(_learnedKey, learned.toList());

      final today = _today();
      final todayKey = 'learned_on_$today';
      final todayWords = (prefs.getStringList(todayKey) ?? []).toSet();
      todayWords.add(id);
      await prefs.setStringList(todayKey, todayWords.toList());

      final activeDays = (prefs.getStringList(_activeDaysKey) ?? []).toSet();
      activeDays.add(today);
      await prefs.setStringList(_activeDaysKey, activeDays.toList());
    }

    final deferred = (prefs.getStringList(_listeningDeferredKey) ?? []).toSet();
    if (deferred.remove(id)) {
      await prefs.setStringList(
        _listeningDeferredKey,
        deferred.toList(),
      );
    }

    final awarded = (prefs.getStringList(_listeningXpWordsKey) ?? []).toSet();

    if (!awarded.add(id)) return false;

    final currentXp = prefs.getInt('learning_total_xp') ?? 0;
    await prefs.setStringList(_listeningXpWordsKey, awarded.toList());
    await prefs.setInt('learning_total_xp', currentXp + 1);

    return true;
  }

  static Future<int> getTodayLearnedCount() async {
    final prefs = await SharedPreferences.getInstance();
    final todayWords = prefs.getStringList('learned_on_${_today()}') ?? [];
    return todayWords.length;
  }

  static Future<int> getTotalLearnedCount() async {
    final learned = await getLearnedWords();
    return learned.length;
  }

  static Future<int> getDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dailyGoalKey) ?? 5;
  }

  static Future<bool> isDailyGoalLocked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_dailyGoalDateKey) == _today();
  }

  static Future<void> setDailyGoal(int goal) async {
    if (![5, 10, 20].contains(goal)) {
      throw ArgumentError('Daily goal must be 5, 10, or 20.');
    }

    final prefs = await SharedPreferences.getInstance();

    if (prefs.getString(_dailyGoalDateKey) == _today()) {
      return;
    }

    await prefs.setInt(_dailyGoalKey, goal);
    await prefs.setString(_dailyGoalDateKey, _today());
  }

  // XP Reward System: প্রতিটি প্রশ্নের প্রথম সঠিক উত্তরে ১০ XP।
  static Future<int> awardQuizXp(List<int> correctQuestionIds) async {
    final prefs = await SharedPreferences.getInstance();

    final mastered =
        (prefs.getStringList('quiz_mastered_question_ids') ?? []).toSet();

    var newlyMastered = 0;

    for (final id in correctQuestionIds) {
      if (mastered.add(id.toString())) {
        newlyMastered++;
      }
    }

    final earnedXp = newlyMastered * 10;
    final currentXp = prefs.getInt('learning_total_xp') ?? 0;

    await prefs.setStringList(
      'quiz_mastered_question_ids',
      mastered.toList(),
    );
    await prefs.setInt('learning_total_xp', currentXp + earnedXp);
    await prefs.setInt('quiz_last_earned_xp', earnedXp);

    return earnedXp;
  }

  // পুরোনো Speaking XP একবার কেন্দ্রীয় XP-তে স্থানান্তর।
  static Future<void> migrateLegacySpeakingProgress() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('sl_progress_migrated_to_learning_store') ?? false) {
      return;
    }

    final legacyXp = prefs.getInt('sl_xp') ?? 0;
    final currentXp = prefs.getInt('learning_total_xp') ?? 0;

    if (legacyXp > 0) {
      await prefs.setInt('learning_total_xp', currentXp + legacyXp);
    }

    // পুরোনো Speaking Streak-এর তারিখগুলোও সংরক্ষণ।
    final lastDay = prefs.getString('sl_last_learning_day');
    final oldStreak = prefs.getInt('sl_streak') ?? 0;

    if (lastDay != null && oldStreak > 0) {
      final lastDate = DateTime.tryParse(lastDay);

      if (lastDate != null) {
        final activeDays = (prefs.getStringList(_activeDaysKey) ?? []).toSet();

        for (var i = 0; i < oldStreak; i++) {
          activeDays.add(_dateKey(lastDate.subtract(Duration(days: i))));
        }

        await prefs.setStringList(_activeDaysKey, activeDays.toList());
      }
    }

    await prefs.setBool('sl_progress_migrated_to_learning_store', true);
  }

  // Speaking Practice: দৈনিক সর্বোচ্চ ৩০ XP।
  static Future<int> awardSpeakingXp() async {
    await migrateLegacySpeakingProgress();

    final prefs = await SharedPreferences.getInstance();
    final today = _today();

    final xpDay = prefs.getString('sl_xp_day');
    var todayXp = prefs.getInt('sl_today_xp') ?? 0;

    if (xpDay != today) {
      todayXp = 0;
      await prefs.setString('sl_xp_day', today);
    }

    var earnedXp = 0;

    if (todayXp < 30) {
      earnedXp = (30 - todayXp).clamp(0, 10);

      final totalXp = prefs.getInt('learning_total_xp') ?? 0;
      await prefs.setInt('learning_total_xp', totalXp + earnedXp);
      await prefs.setInt('sl_today_xp', todayXp + earnedXp);
    }

    final activeDays = (prefs.getStringList(_activeDaysKey) ?? []).toSet();
    activeDays.add(today);
    await prefs.setStringList(_activeDaysKey, activeDays.toList());

    return earnedXp;
  }

  // Duolingo-style Learning Path progress and one-time lesson XP.
  static Future<Set<String>> getCompletedPathLessons() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList('learning_path_completed_lessons') ?? [])
        .toSet();
  }

  static Future<bool> completePathLesson(String lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    final completed =
        (prefs.getStringList('learning_path_completed_lessons') ?? []).toSet();

    if (!completed.add(lessonId)) return false;

    await prefs.setStringList(
      'learning_path_completed_lessons',
      completed.toList(),
    );

    final xp = prefs.getInt('learning_total_xp') ?? 0;
    await prefs.setInt('learning_total_xp', xp + 20);

    final activeDays = (prefs.getStringList(_activeDaysKey) ?? []).toSet();
    activeDays.add(_today());
    await prefs.setStringList(_activeDaysKey, activeDays.toList());

    return true;
  }

  static Future<int> getTotalXp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('learning_total_xp') ?? 0;
  }

  static Future<int> getLearningLevel() async {
    final xp = await getTotalXp();
    return (xp ~/ 100) + 1;
  }

  // Study Timer: প্রতি ১ মিনিটে ১ XP।
  static Future<Map<String, int>> addStudySecond() async {
    final prefs = await SharedPreferences.getInstance();

    final today = _today();
    final todayKey = 'study_seconds_$today';

    final totalSeconds = (prefs.getInt('study_total_seconds') ?? 0) + 1;
    final todaySeconds = (prefs.getInt(todayKey) ?? 0) + 1;

    await prefs.setInt('study_total_seconds', totalSeconds);
    await prefs.setInt(todayKey, todaySeconds);

    // প্রতি পূর্ণ ৬০ সেকেন্ডে ১ XP।
    var totalXp = prefs.getInt('learning_total_xp') ?? 0;

    if (totalSeconds % 60 == 0) {
      totalXp++;
      await prefs.setInt('learning_total_xp', totalXp);
    }

    // পড়াশোনার দিন ক্যালেন্ডারে সংরক্ষণ।
    final activeDays = (prefs.getStringList(_activeDaysKey) ?? []).toSet();
    activeDays.add(today);
    await prefs.setStringList(_activeDaysKey, activeDays.toList());

    return {
      'totalSeconds': totalSeconds,
      'todaySeconds': todaySeconds,
      'totalXp': totalXp,
    };
  }

  static Future<int> getTotalStudySeconds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('study_total_seconds') ?? 0;
  }

  static Future<int> getTodayStudySeconds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('study_seconds_${_today()}') ?? 0;
  }

  static Future<Map<int, int>> getMonthStudySeconds(
    DateTime month,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final prefix = 'study_seconds_${month.year.toString().padLeft(4, '0')}-'
        '${month.month.toString().padLeft(2, '0')}-';

    final result = <int, int>{};

    for (final key in prefs.getKeys()) {
      if (!key.startsWith(prefix)) continue;

      final day = int.tryParse(key.substring(prefix.length));
      final seconds = prefs.getInt(key);

      if (day != null && seconds != null) {
        result[day] = seconds;
      }
    }

    return result;
  }

  // Local ও Cloud data একত্র করে সংরক্ষণ।
  static Future<void> syncWithCloud() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Cloud Sync করতে আগে Login করুন।');
    }

    final prefs = await SharedPreferences.getInstance();
    final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);

    final snapshot = await ref.get();
    final cloud = snapshot.data() ?? {};

    Set<String> mergeSet(dynamic cloudValue, List<String> localValue) {
      final result = <String>{...localValue};

      if (cloudValue is List) {
        result.addAll(cloudValue.whereType<String>());
      }

      return result;
    }

    final favorites = mergeSet(
      cloud['favorites'],
      prefs.getStringList(_favoriteKey) ?? [],
    );

    final learned = mergeSet(
      cloud['learnedWords'],
      prefs.getStringList(_learnedKey) ?? [],
    );

    final activeDays = mergeSet(
      cloud['activeDays'],
      prefs.getStringList(_activeDaysKey) ?? [],
    );

    final dailyLearned = <String, dynamic>{};

    final cloudDaily = cloud['dailyLearned'];
    if (cloudDaily is Map) {
      for (final entry in cloudDaily.entries) {
        if (entry.value is List) {
          dailyLearned[entry.key.toString()] =
              entry.value.whereType<String>().toSet().toList();
        }
      }
    }

    // Local daily learning data সংগ্রহ।
    for (final key in prefs.getKeys()) {
      if (key.startsWith('learned_on_')) {
        final date = key.substring('learned_on_'.length);
        final localWords = prefs.getStringList(key) ?? [];
        final cloudWords = dailyLearned[date];

        final merged = <String>{
          ...localWords,
          if (cloudWords is List) ...cloudWords.whereType<String>(),
        };

        dailyLearned[date] = merged.toList();
      }
    }

    // Local এবং Cloud data একত্র করে Firestore-এ সংরক্ষণ।
    final remoteGoal = cloud['dailyGoal'];
    final localGoal = prefs.getInt(_dailyGoalKey) ?? 5;
    final goal = remoteGoal is int ? remoteGoal : localGoal;

    final remoteGoalDate = cloud['dailyGoalSelectedDate'];
    final localGoalDate = prefs.getString(_dailyGoalDateKey);

    final goalDate = remoteGoalDate is String ? remoteGoalDate : localGoalDate;

    await ref.set({
      'uid': user.uid,
      'email': user.email,
      'favorites': favorites.toList(),
      'learnedWords': learned.toList(),
      'activeDays': activeDays.toList(),
      'dailyGoal': goal,
      'dailyGoalSelectedDate': goalDate,
      'dailyLearned': dailyLearned,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Merged data আবার এই ডিভাইসে সংরক্ষণ।
    await prefs.setStringList(_favoriteKey, favorites.toList());
    await prefs.setStringList(_learnedKey, learned.toList());
    await prefs.setStringList(_activeDaysKey, activeDays.toList());
    await prefs.setInt(_dailyGoalKey, goal);

    if (goalDate != null) {
      await prefs.setString(_dailyGoalDateKey, goalDate);
    }

    for (final entry in dailyLearned.entries) {
      if (entry.value is List) {
        await prefs.setStringList(
          'learned_on_${entry.key}',
          List<String>.from(entry.value),
        );
      }
    }
  }

  static Future<List<String>> awardAchievementXp({
    required Map<String, bool> eligible,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final unlocked =
        (prefs.getStringList('unlocked_achievement_ids') ?? []).toSet();

    final newlyUnlocked = <String>[];

    for (final entry in eligible.entries) {
      if (entry.value && unlocked.add(entry.key)) {
        newlyUnlocked.add(entry.key);
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      final currentXp = prefs.getInt('learning_total_xp') ?? 0;
      final bonusXp = newlyUnlocked.length * 25;

      await prefs.setStringList(
        'unlocked_achievement_ids',
        unlocked.toList(),
      );
      await prefs.setInt('learning_total_xp', currentXp + bonusXp);
      await prefs.setInt('achievement_last_bonus_xp', bonusXp);
    }

    return newlyUnlocked;
  }

  static Future<void> markActiveDay() async {
    final prefs = await SharedPreferences.getInstance();
    final days = (prefs.getStringList(_activeDaysKey) ?? []).toSet();
    days.add(_today());
    await prefs.setStringList(_activeDaysKey, days.toList());
  }

  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final activeDays = (prefs.getStringList(_activeDaysKey) ?? []).toSet();

    if (activeDays.isEmpty) return 0;

    var date = DateTime.now();
    final today = _dateKey(date);

    if (!activeDays.contains(today)) {
      date = date.subtract(const Duration(days: 1));
      if (!activeDays.contains(_dateKey(date))) return 0;
    }

    var streak = 0;

    while (activeDays.contains(_dateKey(date))) {
      streak++;
      date = date.subtract(const Duration(days: 1));
    }

    return streak;
  }
}
