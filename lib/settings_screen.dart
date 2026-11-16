import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/theme_service.dart';
import 'services/learning_store.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _dailyGoal = 5;
  bool _goalLocked = false;
  bool _loading = true;

  static const Color _red = Color(0xFF9E1728);
  static const Color _deepRed = Color(0xFF650D1B);
  static const Color _gold = Color(0xFFD9A441);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final goal = await LearningStore.getDailyGoal();
      final locked = await LearningStore.isDailyGoalLocked();

      if (!mounted) return;

      setState(() {
        _dailyGoal = goal;
        _goalLocked = locked;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _message('সেটিংস লোড করা যায়নি।');
    }
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _changeTheme(ThemeMode mode) async {
    appThemeModeNotifier.value = mode;

    final prefs = await SharedPreferences.getInstance();

    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };

    await prefs.setString('app_theme_mode', value);

    if (mounted) _message('থিম পরিবর্তন করা হয়েছে।');
  }

  Future<void> _changeGoal(int goal) async {
    if (_goalLocked) {
      _message(
        'আজকের লক্ষ্য ইতিমধ্যে নির্ধারণ করা হয়েছে। আগামীকাল পরিবর্তন করতে পারবেন।',
      );
      return;
    }

    try {
      await LearningStore.setDailyGoal(goal);
      if (!mounted) return;

      setState(() {
        _dailyGoal = goal;
        _goalLocked = true;
      });

      _message('দৈনিক লক্ষ্য $goal শব্দ নির্ধারণ করা হয়েছে।');
    } catch (e) {
      _message('লক্ষ্য পরিবর্তন করা যায়নি: $e');
    }
  }

  Widget _premiumHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_deepRed, _red, Color(0xFFB52B38)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _gold.withValues(alpha: 0.65),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _red.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: _gold.withValues(alpha: 0.65),
                  ),
                ),
                child: const Icon(
                  Icons.settings_rounded,
                  color: _gold,
                  size: 29,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.auto_awesome,
                color: _gold,
                size: 25,
              ),
              const SizedBox(width: 5),
              const Text(
                '设置',
                style: TextStyle(
                  color: _gold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'আপনার শেখার অভিজ্ঞতা',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'নিজের পছন্দ অনুযায়ী চীনা শেখার অ্যাপ সাজিয়ে নিন।',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: _gold.withValues(alpha: 0.5),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.school_rounded, color: _gold, size: 17),
                SizedBox(width: 7),
                Text(
                  'চীনা শিখি • HSK 1–4',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 11),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _themeCard() {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeModeNotifier,
      builder: (context, mode, child) {
        return _panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'আপনার পছন্দের থিম নির্বাচন করুন',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                'অ্যাপের রঙ ও উজ্জ্বলতা নিয়ন্ত্রণ করুন।',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              SegmentedButton<ThemeMode>(
                expandedInsets: EdgeInsets.zero,
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode_outlined),
                    label: Text('Light'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode_outlined),
                    label: Text('Dark'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: Icon(Icons.settings_suggest_outlined),
                    label: Text('System'),
                  ),
                ],
                selected: {mode},
                onSelectionChanged: (selection) {
                  _changeTheme(selection.first);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _goalCard() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'প্রতিদিন কতটি নতুন শব্দ শিখবেন?',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              if (_goalLocked)
                const Icon(
                  Icons.lock_rounded,
                  color: _gold,
                  size: 19,
                )
              else
                const Icon(
                  Icons.lock_open_rounded,
                  color: Colors.green,
                  size: 19,
                ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            'নিয়মিত অনুশীলন করুন এবং নিজের লক্ষ্য পূরণ করুন।',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 17),
          Row(
            children: [5, 10, 20].map((goal) {
              final selected = _dailyGoal == goal;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(13),
                    onTap: _goalLocked ? null : () => _changeGoal(goal),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: selected
                            ? _red.withValues(alpha: 0.10)
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: selected
                              ? _gold
                              : Theme.of(context).dividerColor,
                          width: selected ? 1.7 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$goal',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'শব্দ',
                            style: TextStyle(fontSize: 12),
                          ),
                          if (selected)
                            const Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Icon(
                                Icons.check_circle,
                                color: _gold,
                                size: 17,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 13),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: _goalLocked
                  ? Colors.orange.withValues(alpha: 0.09)
                  : Colors.green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              children: [
                Icon(
                  _goalLocked
                      ? Icons.lock_clock_rounded
                      : Icons.tips_and_updates_outlined,
                  size: 18,
                  color: _goalLocked ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    _goalLocked
                        ? 'আজকের লক্ষ্য নির্ধারিত। আগামীকাল পরিবর্তন করতে পারবেন।'
                        : 'একটি দৈনিক লক্ষ্য নির্বাচন করুন।',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _aboutCard() {
    return _panel(
      child: Column(
        children: [
          _aboutItem(
            Icons.school_rounded,
            'চীনা শিখি',
            'বাংলায় চীনা ভাষা শেখার অ্যাপ',
          ),
          const Divider(height: 22),
          _aboutItem(
            Icons.auto_stories_rounded,
            'Learning Levels',
            'New HSK 1 – HSK 4',
          ),
          const Divider(height: 22),
          _aboutItem(
            Icons.info_outline_rounded,
            'App Version',
            '1.0.0',
          ),
          const Divider(height: 22),
          _aboutItem(
            Icons.favorite_outline_rounded,
            'Our Mission',
            'সবার জন্য সহজ চীনা ভাষা শিক্ষা',
          ),
        ],
      ),
    );
  }

  Widget _aboutItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _gold.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _red, size: 21),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _premiumInfoCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: () => _message('Premium সুবিধা শিগগিরই আসছে।'),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _gold.withValues(alpha: 0.20),
              _gold.withValues(alpha: 0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: _gold.withValues(alpha: 0.65),
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.workspace_premium_rounded, color: _gold, size: 31),
            SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'চীনা শিখি Premium',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Premium সুবিধা সম্পর্কে জানতে ট্যাপ করুন।',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'সেটিংস',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
              children: [
                _premiumHeader(),

                _sectionTitle(
                  'Appearance & Theme',
                  Icons.palette_outlined,
                ),
                _themeCard(),

                _sectionTitle(
                  'Learning Preferences',
                  Icons.flag_outlined,
                ),
                _goalCard(),

                _sectionTitle(
                  'Premium Membership',
                  Icons.workspace_premium_outlined,
                ),
                _premiumInfoCard(),

                _sectionTitle(
                  'About Application',
                  Icons.info_outline_rounded,
                ),
                _aboutCard(),

                const SizedBox(height: 25),
                Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: _red,
                        size: 19,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'Made with ❤️ for Chinese learners',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'CHINESE SHIKHI • VERSION 1.0.0',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.2,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
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
