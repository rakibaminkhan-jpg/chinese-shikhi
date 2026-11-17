import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as gma;
import 'package:shared_preferences/shared_preferences.dart';
import 'services/speech_service.dart';
import 'services/learning_store.dart';
import 'services/theme_service.dart';
import 'services/vocab_service.dart';
import 'models/vocab_word.dart';
import 'profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('app_theme_mode') ?? 'system';
    appThemeModeNotifier.value = switch (savedTheme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  } catch (_) {}
  try {
    await gma.MobileAds.instance.initialize();
  } catch (_) {
    // বিজ্ঞাপন চালু না হলেও মূল অ্যাপ চলবে।
  }
  runApp(const ChineseShikhiApp());
}

// Chinese Traditional Red & Gold color palette.
class AppColors {
  // Modern Black & Gold palette
  static const red = Color(0xFFB8860B);
  static const deepRed = Color(0xFF101010);
  static const gold = Color(0xFFD4AF37);
  static const lightGold = Color(0xFFFFE7A3);
  static const ivory = Color(0xFFF7F5EF);
  static const card = Color(0xFFFFFFFF);
  static const ink = Color(0xFF191919);
  static const muted = Color(0xFF716B5E);
  static const border = Color(0xFFE2C56B);
  static const success = Color(0xFF28744A);
}

class ChineseShikhiApp extends StatelessWidget {
  const ChineseShikhiApp({super.key});

  ThemeData _buildTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.red,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.red,
      onPrimary: Colors.white,
      secondary: AppColors.gold,
      onSecondary: AppColors.deepRed,
      tertiary: AppColors.lightGold,
      onTertiary: AppColors.deepRed,
      surface: AppColors.ivory,
      onSurface: AppColors.ink,
      error: const Color(0xFFB3261E),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      primaryColor: AppColors.red,
      scaffoldBackgroundColor: AppColors.ivory,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.deepRed,
        foregroundColor: AppColors.lightGold,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.lightGold,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: IconThemeData(color: AppColors.lightGold),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 1.5,
        shadowColor: AppColors.deepRed.withValues(alpha: 0.08),
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(vertical: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border, width: 0.7),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.ink),
        bodyMedium: TextStyle(color: AppColors.ink),
        titleLarge: TextStyle(
          color: AppColors.deepRed,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: AppColors.deepRed,
          fontWeight: FontWeight.w700,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.red),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 0.8,
        space: 22,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.red,
          foregroundColor: AppColors.deepRed,
          disabledBackgroundColor: const Color(0xFFE8DDC8),
          disabledForegroundColor: AppColors.muted,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.deepRed,
          side: const BorderSide(color: AppColors.gold, width: 1.4),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        hintStyle: const TextStyle(color: AppColors.muted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.red, width: 1.8),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.red;
          return AppColors.gold;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.gold,
        linearTrackColor: AppColors.border,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.deepRed,
        contentTextStyle: const TextStyle(color: AppColors.lightGold),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    const background = Color(0xFF090909);
    const surface = Color(0xFF181818);
    const foreground = Color(0xFFFFF1DF);
    const muted = Color(0xFFCCB9A9);
    const border = Color(0xFF665321);

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.gold,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.gold,
      onPrimary: AppColors.deepRed,
      secondary: AppColors.lightGold,
      onSecondary: AppColors.deepRed,
      surface: background,
      onSurface: foreground,
      error: const Color(0xFFFFB4AB),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF050505),
        foregroundColor: AppColors.lightGold,
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 1.5,
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(vertical: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: border, width: 0.7),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: foreground),
        bodyMedium: TextStyle(color: foreground),
        bodySmall: TextStyle(color: muted),
        titleLarge: TextStyle(
          color: AppColors.lightGold,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: AppColors.lightGold,
          fontWeight: FontWeight.w700,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.gold),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 0.8,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: TextStyle(color: muted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.deepRed,
          minimumSize: const Size(0, 48),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.deepRed,
        contentTextStyle: const TextStyle(color: AppColors.lightGold),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeModeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'চীনা শিখি',
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: currentMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}

// -------------------- কুইজ --------------------

class Question {
  final String question;
  final List<String> options;
  final int answer;
  final String explanation;
  const Question(this.question, this.options, this.answer, this.explanation);
}

const quiz = <Question>[
  Question('“我” শব্দের অর্থ কী?', ['তুমি', 'আমি', 'সে', 'নাম'], 1,
      '我 (wǒ) অর্থ আমি।'),
  Question('“你好” এর অর্থ কী?', ['বিদায়', 'ধন্যবাদ', 'হ্যালো', 'দুঃখিত'], 2,
      '你好 (nǐ hǎo) অর্থ হ্যালো।'),
  Question('“谢谢” এর অর্থ কী?', ['ধন্যবাদ', 'শিক্ষক', 'মানুষ', 'চীন'], 0,
      '谢谢 (xièxie) অর্থ ধন্যবাদ।'),
  Question('“老师” কাকে বলে?', ['শিক্ষার্থী', 'শিক্ষক', 'বন্ধু', 'মানুষ'], 1,
      '老师 (lǎoshī) অর্থ শিক্ষক।'),
  Question('“中国” কোন দেশের নাম?', ['বাংলাদেশ', 'জাপান', 'চীন', 'কোরিয়া'], 2,
      '中国 (Zhōngguó) অর্থ চীন।'),
  Question(
      '“再见” কখন বলা হয়?',
      ['দেখা হলে', 'বিদায়ের সময়', 'ধন্যবাদ দিতে', 'প্রশ্ন করতে'],
      1,
      '再见 (zàijiàn) অর্থ বিদায়।'),
  Question('“不” শব্দের অর্থ কী?', ['হ্যাঁ', 'ভালো', 'না', 'আমি'], 2,
      '不 (bù) অর্থ না।'),
  Question('“学生” এর অর্থ কী?', ['শিক্ষার্থী', 'শিক্ষক', 'চীনা', 'নাম'], 0,
      '学生 (xuésheng) অর্থ শিক্ষার্থী।'),
  Question('“对不起” এর অর্থ কী?', ['স্বাগতম', 'দুঃখিত', 'বিদায়', 'অনুগ্রহ করে'],
      1, '对不起 (duìbuqǐ) অর্থ দুঃখিত।'),
  Question('“请” এর অর্থ কী?', ['অনুগ্রহ করে', 'সমস্যা নেই', 'মানুষ', 'তুমি'], 0,
      '请 (qǐng) অর্থ অনুগ্রহ করে।'),
];

// -------------------- বাংলা Grammar Section (HSK 1-4) --------------------

class GrammarLesson {
  final int level;
  final String title;
  final String pattern;
  final String pinyin;
  final String explanation;
  final String example;
  final String examplePinyin;
  final String translation;
  final String secondExample;
  final String secondPinyin;
  final String secondTranslation;
  final String question;
  final List<String> options;
  final int answer;
  final String note;

  const GrammarLesson({
    required this.level,
    required this.title,
    required this.pattern,
    required this.pinyin,
    required this.explanation,
    required this.example,
    required this.examplePinyin,
    required this.translation,
    required this.secondExample,
    required this.secondPinyin,
    required this.secondTranslation,
    required this.question,
    required this.options,
    required this.answer,
    required this.note,
  });
}

const List<GrammarLesson> grammarLessons = [
  GrammarLesson(
    level: 1,
    title: '是 — পরিচয় বোঝানো',
    pattern: 'Subject + 是 + Noun',
    pinyin: 'shì',
    explanation: 'কেউ কে বা কী—তা পরিচয় করিয়ে দিতে 是 (shì) ব্যবহার হয়।',
    example: '我是学生。',
    examplePinyin: 'Wǒ shì xuésheng.',
    translation: 'আমি একজন শিক্ষার্থী।',
    secondExample: '他是老师。',
    secondPinyin: 'Tā shì lǎoshī.',
    secondTranslation: 'তিনি একজন শিক্ষক।',
    question: '“আমি শিক্ষক” — সঠিক বাক্য কোনটি?',
    options: ['我老师。', '我是老师。', '我在老师。', '我有老师。'],
    answer: 1,
    note: '是 সাধারণত পরিচয় বা শ্রেণি বোঝায়; adjective-এর আগে সাধারণত 是 বসে না।',
  ),
  GrammarLesson(
    level: 1,
    title: '不 — না / অস্বীকার',
    pattern: 'Subject + 不 + Verb / Adjective',
    pinyin: 'bù',
    explanation:
        'বর্তমান বা ভবিষ্যতের কাজ/অবস্থা অস্বীকার করতে 不 (bù) ব্যবহৃত হয়।',
    example: '我不喝茶。',
    examplePinyin: 'Wǒ bù hē chá.',
    translation: 'আমি চা পান করি না।',
    secondExample: '他不忙。',
    secondPinyin: 'Tā bù máng.',
    secondTranslation: 'তিনি ব্যস্ত নন।',
    question: '“আমি যাই না” কোনটি?',
    options: ['我不去。', '我没去。', '我去不。', '不我去。'],
    answer: 0,
    note: '不-এর পরে সাধারণত verb বা adjective বসে।',
  ),
  GrammarLesson(
    level: 1,
    title: '吗 — হ্যাঁ/না প্রশ্ন',
    pattern: 'Statement + 吗？',
    pinyin: 'ma',
    explanation:
        'একটি সাধারণ বাক্যের শেষে 吗 (ma) বসালে সেটি হ্যাঁ/না প্রশ্নে পরিণত হয়।',
    example: '你是学生吗？',
    examplePinyin: 'Nǐ shì xuésheng ma?',
    translation: 'তুমি কি শিক্ষার্থী?',
    secondExample: '你喜欢茶吗？',
    secondPinyin: 'Nǐ xǐhuan chá ma?',
    secondTranslation: 'তুমি কি চা পছন্দ করো?',
    question: 'বাক্যকে হ্যাঁ/না প্রশ্ন করতে কোথায় 吗 বসে?',
    options: [
      'বাক্যের শুরুতে',
      'বাক্যের শেষে',
      'Subject-এর আগে',
      'Verb-এর মাঝে'
    ],
    answer: 1,
    note: '吗 প্রশ্নে সাধারণত বাক্যের শেষে বসে; প্রশ্নবোধক চিহ্নও দিতে হয়।',
  ),
  GrammarLesson(
    level: 2,
    title: '正在 — কাজ চলছে',
    pattern: 'Subject + 正在 + Verb',
    pinyin: 'zhèngzài',
    explanation: 'কোনো কাজ এই মুহূর্তে চলমান—এটি বোঝাতে 正在 ব্যবহার হয়।',
    example: '我正在学习中文。',
    examplePinyin: 'Wǒ zhèngzài xuéxí Zhōngwén.',
    translation: 'আমি এখন চীনা ভাষা শিখছি।',
    secondExample: '妈妈正在做饭。',
    secondPinyin: 'Māma zhèngzài zuò fàn.',
    secondTranslation: 'মা এখন রান্না করছেন।',
    question: '“আমি এখন পড়ছি” কোনটি?',
    options: ['我正在看书。', '我昨天看书。', '我不看书。', '我会看书。'],
    answer: 0,
    note: '正在-এর পরে কাজ বোঝানো Verb আসে।',
  ),
  GrammarLesson(
    level: 2,
    title: '因为…所以… — কারণ ও ফল',
    pattern: '因为 + কারণ， 所以 + ফল',
    pinyin: 'yīnwèi… suǒyǐ…',
    explanation: 'কারণ এবং তার ফলাফল একসঙ্গে প্রকাশ করতে এই গঠন ব্যবহার হয়।',
    example: '因为下雨，所以我不去。',
    examplePinyin: 'Yīnwèi xiàyǔ, suǒyǐ wǒ bú qù.',
    translation: 'বৃষ্টি হচ্ছে বলে আমি যাচ্ছি না।',
    secondExample: '因为很忙，所以他没来。',
    secondPinyin: 'Yīnwèi hěn máng, suǒyǐ tā méi lái.',
    secondTranslation: 'ব্যস্ত থাকার কারণে সে আসেনি।',
    question: 'কারণ বোঝানোর শব্দ কোনটি?',
    options: ['所以', '但是', '因为', '还是'],
    answer: 2,
    note: 'কথ্য ভাষায় কখনো একটি অংশ বাদও যেতে পারে; পূর্ণ গঠনে দুটিই থাকে।',
  ),
  GrammarLesson(
    level: 2,
    title: '比 — তুলনা করা',
    pattern: 'A + 比 + B + Adjective',
    pinyin: 'bǐ',
    explanation:
        'দুই ব্যক্তি বা বস্তুর তুলনা করতে A 比 B + adjective ব্যবহার হয়।',
    example: '我比他高。',
    examplePinyin: 'Wǒ bǐ tā gāo.',
    translation: 'আমি তার চেয়ে লম্বা।',
    secondExample: '今天比昨天冷。',
    secondPinyin: 'Jīntiān bǐ zuótiān lěng.',
    secondTranslation: 'আজ গতকালের চেয়ে ঠান্ডা।',
    question: '“A, B-এর চেয়ে বড়” কোন গঠন?',
    options: ['A 是 B 大', 'A 比 B 大', 'A 在 B 大', 'A 有 B 大'],
    answer: 1,
    note: '比 দিয়ে তুলনায় adjective-এর আগে সাধারণত 很 বসে না।',
  ),
  GrammarLesson(
    level: 3,
    title: '把 — বস্তুর ওপর কাজের প্রভাব',
    pattern: 'Subject + 把 + Object + Verb + Result',
    pinyin: 'bǎ',
    explanation:
        'কোনো বস্তুর ওপর করা কাজ এবং তার ফল/পরিবর্তন সামনে আনতে 把 ব্যবহার হয়।',
    example: '我把门关上了。',
    examplePinyin: 'Wǒ bǎ mén guān shàng le.',
    translation: 'আমি দরজাটি বন্ধ করে দিয়েছি।',
    secondExample: '请把书放在桌子上。',
    secondPinyin: 'Qǐng bǎ shū fàng zài zhuōzi shàng.',
    secondTranslation: 'দয়া করে বইটি টেবিলের ওপর রাখুন।',
    question: '把-এর ঠিক পরে সাধারণত কী বসে?',
    options: ['Object', 'সময়', 'Adjective', 'প্রশ্নবোধক শব্দ'],
    answer: 0,
    note:
        '把 বাক্যে object-এর পরে verb-এর সঙ্গে সাধারণত ফল, দিক বা অন্য পরিপূরক থাকে।',
  ),
  GrammarLesson(
    level: 3,
    title: '虽然…但是… — যদিও…তবুও',
    pattern: '虽然 + ঘটনা， 但是 + বিপরীত ফল',
    pinyin: 'suīrán… dànshì…',
    explanation:
        'একটি বাধা বা বিপরীত পরিস্থিতি থাকা সত্ত্বেও অন্য কিছু ঘটে—এটি বোঝায়।',
    example: '虽然很累，但是我很高兴。',
    examplePinyin: 'Suīrán hěn lèi, dànshì wǒ hěn gāoxìng.',
    translation: 'যদিও খুব ক্লান্ত, তবুও আমি খুব খুশি।',
    secondExample: '虽然下雨，但是他来了。',
    secondPinyin: 'Suīrán xiàyǔ, dànshì tā lái le.',
    secondTranslation: 'যদিও বৃষ্টি হচ্ছে, তবুও সে এসেছে।',
    question: '“তবুও / কিন্তু” বোঝায় কোনটি?',
    options: ['虽然', '因为', '但是', '所以'],
    answer: 2,
    note: '虽然 অংশে পরিস্থিতি, 但是 অংশে তার বিপরীত ফল বা বক্তব্য আসে।',
  ),
  GrammarLesson(
    level: 3,
    title: '除了…以外 — ছাড়া / বাদে',
    pattern: '除了 + X + 以外，(还/都)…',
    pinyin: 'chúle… yǐwài',
    explanation: 'কাউকে বা কিছুকে বাদ দিয়ে অন্য বিষয় বোঝাতে এই গঠন ব্যবহৃত হয়।',
    example: '除了中文以外，我还学英语。',
    examplePinyin: 'Chúle Zhōngwén yǐwài, wǒ hái xué Yīngyǔ.',
    translation: 'চীনা ভাষা ছাড়াও আমি ইংরেজি শিখি।',
    secondExample: '除了他以外，大家都来了。',
    secondPinyin: 'Chúle tā yǐwài, dàjiā dōu lái le.',
    secondTranslation: 'তাকে ছাড়া সবাই এসেছে।',
    question: '“ছাড়া / বাদে” বোঝাতে কোনটি ব্যবহৃত হয়?',
    options: ['除了…以外', '因为…所以', '虽然…但是', '一边…一边'],
    answer: 0,
    note: 'এর পরে 还 এলে “এছাড়াও”; 都 এলে “বাদে সবাই/সব” অর্থ হতে পারে।',
  ),
  GrammarLesson(
    level: 4,
    title: '不但…而且… — শুধু নয়, বরং',
    pattern: '不但 + বিষয়， 而且 + অতিরিক্ত বিষয়',
    pinyin: 'búdàn… érqiě…',
    explanation:
        'একটি গুণ বা তথ্যের সঙ্গে আরও একটি জোরালো তথ্য যোগ করতে ব্যবহৃত হয়।',
    example: '他不但会说中文，而且会说英文。',
    examplePinyin: 'Tā búdàn huì shuō Zhōngwén, érqiě huì shuō Yīngwén.',
    translation: 'সে শুধু চীনা বলতে পারে তা নয়, ইংরেজিও বলতে পারে।',
    secondExample: '这本书不但有趣，而且很有用。',
    secondPinyin: 'Zhè běn shū búdàn yǒuqù, érqiě hěn yǒuyòng.',
    secondTranslation: 'এই বইটি শুধু মজার নয়, খুব উপকারীও।',
    question: '“বরং / তাছাড়া” অর্থে কোনটি ব্যবহৃত হয়?',
    options: ['不但', '而且', '虽然', '因为'],
    answer: 1,
    note: '不但 প্রথম তথ্য এবং 而且 অতিরিক্ত তথ্য যোগ করে।',
  ),
  GrammarLesson(
    level: 4,
    title: '既然…就… — যেহেতু…তাই',
    pattern: '既然 + জানা অবস্থা， 就 + সিদ্ধান্ত',
    pinyin: 'jìrán… jiù…',
    explanation:
        'কোনো বিষয় আগে থেকেই সত্য বা জানা—সেই ভিত্তিতে সিদ্ধান্ত জানাতে ব্যবহৃত হয়।',
    example: '既然你来了，就一起吃饭吧。',
    examplePinyin: 'Jìrán nǐ lái le, jiù yìqǐ chīfàn ba.',
    translation: 'যেহেতু তুমি এসেছ, তাহলে একসঙ্গে খাই।',
    secondExample: '既然很累，就休息一下。',
    secondPinyin: 'Jìrán hěn lèi, jiù xiūxi yíxià.',
    secondTranslation: 'যেহেতু খুব ক্লান্ত, তাই একটু বিশ্রাম নাও।',
    question: '既然-এর পর সাধারণত কোন অংশটি আসে?',
    options: ['就', '吗', '把', '比'],
    answer: 0,
    note:
        '既然 কারণ/স্বীকৃত অবস্থা তুলে ধরে, 就 তার ভিত্তিতে ফল বা সিদ্ধান্ত জানায়।',
  ),
  GrammarLesson(
    level: 4,
    title: '无论…都… — যাই হোক না কেন',
    pattern: '无论 + বিকল্প/পরিস্থিত， 都 + ফল',
    pinyin: 'wúlùn… dōu…',
    explanation: 'যে পরিস্থিতিই হোক, ফল একই থাকবে—এমন অর্থ প্রকাশ করে।',
    example: '无论多忙，我都要学习。',
    examplePinyin: 'Wúlùn duō máng, wǒ dōu yào xuéxí.',
    translation: 'যতই ব্যস্ত থাকি না কেন, আমাকে পড়তে হবে।',
    secondExample: '无论谁来，我都欢迎。',
    secondPinyin: 'Wúlùn shéi lái, wǒ dōu huānyíng.',
    secondTranslation: 'যেই আসুক না কেন, আমি স্বাগত জানাই।',
    question: '“যাই হোক না কেন” বোঝায় কোন গঠন?',
    options: ['既然…就…', '无论…都…', '不但…而且…', '因为…所以…'],
    answer: 1,
    note:
        '无论-এর পরে প্রশ্নবোধক শব্দ বা বিকল্প থাকতে পারে; মূল বাক্যে সাধারণত 都 থাকে।',
  ),
];

class GrammarScreen extends StatefulWidget {
  const GrammarScreen({super.key});

  @override
  State<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends State<GrammarScreen> {
  int _selectedLevel = 0;
  Set<String> _completed = {};

  @override
  void initState() {
    super.initState();
    _loadCompleted();
  }

  Future<void> _loadCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() =>
        _completed = prefs.getStringList('grammar_completed')?.toSet() ?? {});
  }

  Future<void> _openLesson(GrammarLesson lesson) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GrammarLessonScreen(
          lesson: lesson,
          onCompleted: () async {
            final id = '${lesson.level}_${lesson.title}';
            final prefs = await SharedPreferences.getInstance();
            final values = prefs.getStringList('grammar_completed') ?? [];
            if (!values.contains(id)) {
              values.add(id);
              await prefs.setStringList('grammar_completed', values);
            }
            if (mounted) setState(() => _completed = values.toSet());
          },
        ),
      ),
    );
    await _loadCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final lessons = grammarLessons
        .where((e) => _selectedLevel == 0 || e.level == _selectedLevel)
        .toList();
    final total = grammarLessons.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('চীনা Grammar • বাংলা'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
                child: Text('${_completed.length}/$total',
                    style: const TextStyle(fontWeight: FontWeight.w800))),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF8E1B2B), Color(0xFF260A10)]),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.gold),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('中文语法',
                    style: TextStyle(
                        color: Color(0xFFFFD978),
                        fontSize: 29,
                        fontWeight: FontWeight.w900)),
                SizedBox(height: 5),
                Text('Chinese Grammar শেখো বাংলায়',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
                SizedBox(height: 8),
                Text('নিয়ম বুঝুন • উদাহরণ পড়ুন • কুইজ দিন',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('HSK Level বেছে নিন',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            children: [
              for (int level = 0; level <= 4; level++)
                ChoiceChip(
                  label: Text(level == 0 ? 'সব' : 'HSK $level'),
                  selected: _selectedLevel == level,
                  selectedColor: AppColors.gold,
                  onSelected: (_) => setState(() => _selectedLevel = level),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : _completed.length / total,
              minHeight: 9,
              backgroundColor: AppColors.gold.withValues(alpha: 0.16),
            ),
          ),
          const SizedBox(height: 6),
          Text('সম্পন্ন: ${_completed.length} / $total টি লেসন',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          for (final lesson in lessons)
            Card(
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                leading: CircleAvatar(
                  backgroundColor: AppColors.gold.withValues(alpha: 0.2),
                  foregroundColor: AppColors.deepRed,
                  child: Text('${lesson.level}',
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                ),
                title: Text(lesson.title,
                    style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text('HSK ${lesson.level}  •  ${lesson.pattern}',
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
                trailing: Icon(
                  _completed.contains('${lesson.level}_${lesson.title}')
                      ? Icons.check_circle_rounded
                      : Icons.arrow_forward_ios_rounded,
                  color: AppColors.gold,
                  size: 20,
                ),
                onTap: () => _openLesson(lesson),
              ),
            ),
        ],
      ),
    );
  }
}

class GrammarLessonScreen extends StatefulWidget {
  final GrammarLesson lesson;
  final Future<void> Function() onCompleted;

  const GrammarLessonScreen({
    super.key,
    required this.lesson,
    required this.onCompleted,
  });

  @override
  State<GrammarLessonScreen> createState() => _GrammarLessonScreenState();
}

class _GrammarLessonScreenState extends State<GrammarLessonScreen> {
  int? _selectedAnswer;
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final correct = _selectedAnswer == lesson.answer;

    Widget section(String title, Widget child) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 14,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 9),
                child,
              ],
            ),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: Text('HSK ${lesson.level} Grammar')),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          Text(lesson.title,
              style:
                  const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
          const SizedBox(height: 13),
          section(
              'GRAMMAR PATTERN',
              Text(lesson.pattern,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w900))),
          section(
              'বাংলায় ব্যাখ্যা',
              Text(lesson.explanation,
                  style: const TextStyle(fontSize: 15, height: 1.6))),
          section(
              'Pinyin / উচ্চারণ',
              Text(lesson.pinyin,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w800))),
          section(
              'উদাহরণ ১',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.example,
                      style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          color: AppColors.red)),
                  const SizedBox(height: 5),
                  Text('Pinyin: ${lesson.examplePinyin}'),
                  const SizedBox(height: 5),
                  Text('বাংলা: ${lesson.translation}'),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () =>
                          SpeechService.speakChinese(lesson.example),
                      icon: const Icon(Icons.volume_up_rounded,
                          color: AppColors.gold),
                      tooltip: 'উচ্চারণ শুনুন',
                    ),
                  ),
                ],
              )),
          section(
              'উদাহরণ ২',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.secondExample,
                      style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          color: AppColors.red)),
                  const SizedBox(height: 5),
                  Text('Pinyin: ${lesson.secondPinyin}'),
                  const SizedBox(height: 5),
                  Text('বাংলা: ${lesson.secondTranslation}'),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () =>
                          SpeechService.speakChinese(lesson.secondExample),
                      icon: const Icon(Icons.volume_up_rounded,
                          color: AppColors.gold),
                      tooltip: 'উচ্চারণ শুনুন',
                    ),
                  ),
                ],
              )),
          section('মনে রাখুন',
              Text(lesson.note, style: const TextStyle(height: 1.55))),
          section(
              'নিজেকে যাচাই করুন',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.question,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 8),
                  for (int i = 0; i < lesson.options.length; i++)
                    RadioListTile<int>(
                      value: i,
                      groupValue: _selectedAnswer,
                      contentPadding: EdgeInsets.zero,
                      title: Text(lesson.options[i]),
                      onChanged: _submitted
                          ? null
                          : (value) => setState(() => _selectedAnswer = value),
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _selectedAnswer == null || _submitted
                          ? null
                          : () async {
                              setState(() => _submitted = true);
                              if (correct) await widget.onCompleted();
                            },
                      child: Text(_submitted
                          ? (correct
                              ? 'সঠিক উত্তর! লেসন সম্পন্ন'
                              : 'আবার চেষ্টা করুন')
                          : 'উত্তর যাচাই করুন'),
                    ),
                  ),
                  if (_submitted && !correct)
                    TextButton(
                      onPressed: () => setState(() {
                        _selectedAnswer = null;
                        _submitted = false;
                      }),
                      child: const Text('আবার চেষ্টা করুন'),
                    ),
                  if (_submitted && correct)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                          'অভিনন্দন! আপনি এই গ্রামার লেসনটি সম্পন্ন করেছেন।',
                          style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w800)),
                    ),
                ],
              )),
        ],
      ),
    );
  }
}

// -------------------- স্থায়ী Bottom Navigation Shell --------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  DateTime? _lastBackPressed;

  void _handleBackPressed() {
    final keys = [
      _homeNavigatorKey,
      _learnNavigatorKey,
      _grammarNavigatorKey,
      _practiceNavigatorKey,
      _profileNavigatorKey,
    ];

    final currentNavigator = keys[_selectedIndex].currentState;

    // বর্তমান ট্যাবের ভেতরে আগের পেজ থাকলে সেখানে ফিরে যাবে।
    if (currentNavigator?.canPop() ?? false) {
      currentNavigator!.pop();
      return;
    }

    // অন্য ট্যাবে থাকলে Home ট্যাবে ফিরে যাবে।
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      return;
    }

    // Home-এ দুইবার Back চাপলে অ্যাপ বন্ধ হবে।
    final now = DateTime.now();

    if (_lastBackPressed != null &&
        now.difference(_lastBackPressed!) < const Duration(seconds: 2)) {
      SystemNavigator.pop();
      return;
    }

    _lastBackPressed = now;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('আবার Back চাপলে অ্যাপ বন্ধ হবে।'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  final _homeNavigatorKey = GlobalKey<NavigatorState>();
  final _learnNavigatorKey = GlobalKey<NavigatorState>();
  final _grammarNavigatorKey = GlobalKey<NavigatorState>();
  final _practiceNavigatorKey = GlobalKey<NavigatorState>();
  final _profileNavigatorKey = GlobalKey<NavigatorState>();

  void _selectTab(int index) {
    if (index == _selectedIndex) {
      final keys = [
        _homeNavigatorKey,
        _learnNavigatorKey,
        _grammarNavigatorKey,
        _practiceNavigatorKey,
        _profileNavigatorKey,
      ];
      keys[index].currentState?.popUntil((route) => route.isFirst);
      return;
    }

    setState(() => _selectedIndex = index);
  }

  Widget _tabNavigator({
    required GlobalKey<NavigatorState> navigatorKey,
    required Widget initialPage,
  }) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => initialPage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBackPressed();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _tabNavigator(
              navigatorKey: _homeNavigatorKey,
              initialPage: const _HomeDashboardScreen(),
            ),
            _tabNavigator(
              navigatorKey: _learnNavigatorKey,
              initialPage: const VocabularyScreen(),
            ),
            _tabNavigator(
              navigatorKey: _grammarNavigatorKey,
              initialPage: const GrammarScreen(),
            ),
            _tabNavigator(
              navigatorKey: _practiceNavigatorKey,
              initialPage: const QuizScreen(),
            ),
            _tabNavigator(
              navigatorKey: _profileNavigatorKey,
              initialPage: const ProfileScreen(),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NavigationBar(
                height: 66,
                selectedIndex: _selectedIndex,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                onDestinationSelected: _selectTab,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'হোম',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.menu_book_outlined),
                    selectedIcon: Icon(Icons.menu_book_rounded),
                    label: 'শিখুন',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.translate_rounded),
                    selectedIcon: Icon(Icons.translate_rounded),
                    label: 'গ্রামার',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.quiz_outlined),
                    selectedIcon: Icon(Icons.quiz_rounded),
                    label: 'প্র্যাকটিস',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: 'প্রোফাইল',
                  ),
                ],
              ),
              const BannerAdBar(),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------- হোম ড্যাশবোর্ড --------------------

class _HomeDashboardScreen extends StatefulWidget {
  const _HomeDashboardScreen();

  @override
  State<_HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<_HomeDashboardScreen> {
  int? lastScore;
  int _learnedCount = 0;
  int _todayLearned = 0;
  int _dailyGoal = 5;
  bool _dailyGoalLocked = false;
  int _streak = 0;
  late final Future<List<VocabWord>> _wordsFuture;

  @override
  void initState() {
    super.initState();
    _wordsFuture = VocabService.loadWords();
    _readScore();
    _loadLearningStats();
  }

  Future<void> _loadLearningStats() async {
    final values = await Future.wait<int>([
      LearningStore.getTotalLearnedCount(),
      LearningStore.getTodayLearnedCount(),
      LearningStore.getDailyGoal(),
      LearningStore.getStreak(),
    ]);
    final goalLocked = await LearningStore.isDailyGoalLocked();

    if (!mounted) return;
    setState(() {
      _learnedCount = values[0];
      _todayLearned = values[1];
      _dailyGoal = values[2];
      _streak = values[3];
      _dailyGoalLocked = goalLocked;
    });
  }

  Future<void> _changeDailyGoal(int goal) async {
    if (_dailyGoalLocked) return;

    await LearningStore.setDailyGoal(goal);
    if (!mounted) return;

    final locked = await LearningStore.isDailyGoalLocked();

    setState(() {
      _dailyGoal = goal;
      _dailyGoalLocked = locked;
    });
  }

  Future<void> _readScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => lastScore = prefs.getInt('lesson1_score'));
  }

  Future<void> _selectTheme(ThemeMode mode) async {
    appThemeModeNotifier.value = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedValue = switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
      await prefs.setString('app_theme_mode', savedValue);
    } catch (_) {}
  }

  Future<void> _openPage(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (mounted) await _loadLearningStats();
  }

  Future<void> _startQuiz() async {
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => const QuizScreen()),
    );
    if (result != null && mounted) {
      setState(() => lastScore = result);
    }
    if (mounted) await _loadLearningStats();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = Theme.of(context).colorScheme.onSurface;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final surface = isDark ? const Color(0xFF1C1718) : Colors.white;
    final background =
        isDark ? const Color(0xFF120D0E) : const Color(0xFFFFF9F0);

    final goalProgress = _dailyGoal <= 0
        ? 0.0
        : (_todayLearned / _dailyGoal).clamp(0.0, 1.0).toDouble();

    Widget statCard({
      required IconData icon,
      required String value,
      required String label,
    }) {
      return Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.gold, size: 24),
            const SizedBox(height: 11),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  color: foreground,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    Widget actionCard({
      required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
    }) {
      return Material(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            constraints: const BoxConstraints(minHeight: 116),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 39,
                  height: 39,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.gold, size: 22),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: muted,
                    fontSize: 10,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 18,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD978), Color(0xFFC58A22)],
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.translate_rounded,
                color: Color(0xFF3A1015),
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'চীনা শিখি',
                  style: TextStyle(
                    color: foreground,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'MANDARIN • বাংলা',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: isDark ? 'Day Mode' : 'Night Mode',
            onPressed: () => _selectTheme(
              isDark ? ThemeMode.light : ThemeMode.dark,
            ),
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: AppColors.gold,
            ),
          ),
          IconButton(
            tooltip: 'আমার অগ্রগতি',
            onPressed: () => _openPage(const ProgressScreen()),
            icon: Icon(Icons.account_circle_outlined, color: foreground),
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(17, 12, 17, 28),
        children: [
          Text(
            '欢迎回来！  •  Welcome back',
            style: TextStyle(
              color: muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'আজ কী শিখবেন?',
            style: TextStyle(
              color: foreground,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 17),

          // Premium Chinese Red & Gold welcome card
          Container(
            padding: const EdgeInsets.all(21),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF8E1B2B),
                  Color(0xFF510E1B),
                  Color(0xFF21090F),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.85),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8E1B2B).withValues(alpha: 0.22),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.65),
                        ),
                      ),
                      child: const Text(
                        '✦ YOUR CHINESE JOURNEY',
                        style: TextStyle(
                          color: Color(0xFFFFE5A0),
                          fontSize: 9,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.gold,
                      size: 25,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  '你好！',
                  style: TextStyle(
                    color: Color(0xFFFFD978),
                    fontSize: 48,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Nǐ hǎo! — হ্যালো!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'প্রতিদিন একটু একটু করে Mandarin শিখুন। '
                  'আজকের ছোট অগ্রগতিই আগামী দিনের বড় সাফল্য।',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.84),
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 19),
                Row(
                  children: [
                    const Icon(
                      Icons.school_rounded,
                      color: AppColors.gold,
                      size: 17,
                    ),
                    const SizedBox(width: 7),
                    const Text(
                      'HSK LEVEL 1–4',
                      style: TextStyle(
                        color: Color(0xFFFFE5A0),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'START TODAY',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _openPage(const VocabularyScreen()),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text(
                      'শেখা শুরু করুন',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: const Color(0xFF351016),
                      minimumSize: const Size.fromHeight(49),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),
          const _SectionHeading(
            title: 'আপনার অগ্রগতি',
            subtitle: 'আপনার Chinese learning journey এক নজরে',
          ),
          const SizedBox(height: 13),

          FutureBuilder<List<VocabWord>>(
            future: _wordsFuture,
            builder: (context, snapshot) {
              final wordCount =
                  snapshot.hasData ? snapshot.data!.length.toString() : '—';

              return GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 11,
                mainAxisSpacing: 11,
                childAspectRatio: 1.42,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  statCard(
                    icon: Icons.menu_book_rounded,
                    value: wordCount,
                    label: 'মোট শব্দ',
                  ),
                  statCard(
                    icon: Icons.check_circle_rounded,
                    value: '$_learnedCount',
                    label: 'শেখা শব্দ',
                  ),
                  statCard(
                    icon: Icons.local_fire_department_rounded,
                    value: '$_streak দিন',
                    label: 'Learning Streak',
                  ),
                  statCard(
                    icon: Icons.emoji_events_rounded,
                    value: lastScore == null ? '—' : '$lastScore/10',
                    label: 'শেষ কুইজ স্কোর',
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Daily goal and lock feature
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(21),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.55),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.10 : 0.035),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.track_changes_rounded,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'আজকের শেখার লক্ষ্য',
                            style: TextStyle(
                              color: foreground,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'প্রতিদিন নিজের লক্ষ্যে এগিয়ে যান',
                            style: TextStyle(color: muted, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$_todayLearned/$_dailyGoal',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: goalProgress,
                    minHeight: 12,
                    backgroundColor: AppColors.gold.withValues(alpha: 0.16),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.gold,
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _todayLearned >= _dailyGoal
                            ? 'অভিনন্দন! আজকের লক্ষ্য পূরণ হয়েছে।'
                            : 'আর ${_dailyGoal - _todayLearned}টি শব্দ শিখলেই লক্ষ্য পূরণ!',
                        style: TextStyle(
                          color: muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${(goalProgress * 100).round()}%',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'দৈনিক লক্ষ্য বেছে নিন',
                  style: TextStyle(
                    color: foreground,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 8,
                  runSpacing: 7,
                  children: [5, 10, 20].map((goal) {
                    return ChoiceChip(
                      label: Text('$goal শব্দ'),
                      selected: _dailyGoal == goal,
                      selectedColor: AppColors.gold,
                      onSelected: _dailyGoalLocked
                          ? null
                          : (_) => _changeDailyGoal(goal),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Icon(
                      _dailyGoalLocked
                          ? Icons.lock_rounded
                          : Icons.lock_open_rounded,
                      size: 15,
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _dailyGoalLocked
                            ? 'আজকের লক্ষ্য লক হয়েছে। আগামীকাল পরিবর্তন করতে পারবেন।'
                            : 'একটি লক্ষ্য বেছে নিন। বেছে নিলেই আজকের জন্য লক হবে।',
                        style: TextStyle(color: muted, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),
          const _SectionHeading(
            title: 'আজকের চীনা শব্দ',
            subtitle: 'প্রতিদিন একটি নতুন শব্দ শিখুন',
          ),
          const SizedBox(height: 12),

          FutureBuilder<List<VocabWord>>(
            future: _wordsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(25),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              final words = snapshot.data ?? [];
              if (words.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text('আজকের শব্দ লোড করা যায়নি।'),
                  ),
                );
              }

              final today = DateTime.now();
              final dayNumber = DateTime(today.year, today.month, today.day)
                  .difference(DateTime(2024, 1, 1))
                  .inDays;
              final word = words[dayNumber.abs() % words.length];

              return Material(
                color: surface,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _openPage(const VocabularyScreen()),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 82,
                          height: 82,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF8E1B2B),
                                Color(0xFF430D17),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.7),
                            ),
                          ),
                          child: Text(
                            word.hanzi,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFFFD978),
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'HSK ${word.level} • WORD OF THE DAY',
                                style: const TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 9,
                                  letterSpacing: 0.7,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                word.pinyin,
                                style: TextStyle(
                                  color: foreground,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                word.meaningBn.isNotEmpty
                                    ? word.meaningBn
                                    : word.meaning,
                                style: TextStyle(
                                  color: muted,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'শব্দটি শিখতে ট্যাপ করুন →',
                                style: TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 25),
          const _SectionHeading(
            title: 'দ্রুত শিখুন',
            subtitle: 'আপনার প্রয়োজনীয় ফিচারগুলো এক জায়গায়',
          ),
          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 11,
            mainAxisSpacing: 11,
            childAspectRatio: 1.12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              actionCard(
                icon: Icons.translate_rounded,
                title: 'শব্দভান্ডার',
                subtitle: 'HSK 1–4, Pinyin ও বাংলা অর্থ',
                onTap: () => _openPage(const VocabularyScreen()),
              ),
              actionCard(
                icon: Icons.star_rounded,
                title: 'প্রিয় শব্দ',
                subtitle: 'আপনার সংরক্ষিত শব্দ',
                onTap: () => _openPage(const FavoritesScreen()),
              ),
              actionCard(
                icon: Icons.psychology_alt_rounded,
                title: 'অনুশীলন কুইজ',
                subtitle: 'নিজের দক্ষতা যাচাই করুন',
                onTap: _startQuiz,
              ),
              actionCard(
                icon: Icons.insights_rounded,
                title: 'আমার অগ্রগতি',
                subtitle: 'শেখার হিসাব ও ফলাফল',
                onTap: () => _openPage(const ProgressScreen()),
              ),
            ],
          ),

          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_rounded,
                  color: AppColors.gold,
                  size: 23,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'আজকের শেখার টিপস',
                        style: TextStyle(
                          color: foreground,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'প্রতিটি Chinese শব্দের Pinyin ও Tone খেয়াল করে '
                        'জোরে জোরে উচ্চারণ করুন। নিয়মিত অনুশীলনই '
                        'আপনাকে এগিয়ে নেবে।',
                        style: TextStyle(
                          color: muted,
                          fontSize: 11,
                          height: 1.55,
                        ),
                      ),
                    ],
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

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeading({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(fontSize: 11, color: muted),
        ),
      ],
    );
  }
}

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  late final Future<List<VocabWord>> _futureWords;
  final TextEditingController _searchController = TextEditingController();

  final Set<int> _selectedLevels = {};
  String _searchText = '';
  Set<String> _favorites = {};
  Set<String> _learned = {};

  Future<void> _loadLearningState() async {
    final favorites = await LearningStore.getFavorites();
    final learned = await LearningStore.getLearnedWords();
    if (!mounted) return;
    setState(() {
      _favorites = favorites;
      _learned = learned;
    });
  }

  String _wordId(VocabWord word) {
    return LearningStore.wordId(
      level: word.level,
      hanzi: word.hanzi,
      pinyin: word.pinyin,
    );
  }

  Future<void> _toggleFavorite(VocabWord word) async {
    final id = _wordId(word);
    await LearningStore.toggleFavorite(id);
    if (!mounted) return;
    setState(() {
      if (_favorites.contains(id)) {
        _favorites.remove(id);
      } else {
        _favorites.add(id);
      }
    });
  }

  Future<void> _markLearned(VocabWord word) async {
    final id = _wordId(word);
    if (_learned.contains(id)) return;

    await LearningStore.markLearned(id);
    if (!mounted) return;
    setState(() => _learned.add(id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('${word.hanzi} — শেখা শব্দ হিসেবে সংরক্ষিত হয়েছে')),
    );
  }

  @override
  void initState() {
    super.initState();
    _futureWords = VocabService.loadWords();
    _loadLearningState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HSK 1–4 শব্দভান্ডার'),
      ),
      body: FutureBuilder<List<VocabWord>>(
        future: _futureWords,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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

          final allWords = snapshot.data ?? [];

          if (allWords.isEmpty) {
            return const Center(child: Text('কোনো শব্দ পাওয়া যায়নি।'));
          }

          final filteredWords = allWords.where((word) {
            final matchesLevel =
                _selectedLevels.isEmpty || _selectedLevels.contains(word.level);

            final query = _searchText.trim().toLowerCase();
            final matchesSearch = query.isEmpty ||
                word.hanzi.toLowerCase().contains(query) ||
                word.pinyin.toLowerCase().contains(query) ||
                word.meaning.toLowerCase().contains(query) ||
                word.meaningBn.toLowerCase().contains(query);

            return matchesLevel && matchesSearch;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => _searchText = value);
                  },
                  decoration: InputDecoration(
                    hintText: 'চীনা শব্দ, Pinyin বা বাংলা অর্থ খুঁজুন',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchText.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchText = '');
                            },
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    _levelChip('সব', null),
                    for (int level = 1; level <= 4; level++)
                      _levelChip('HSK $level', level),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'পাওয়া গেছে: ${filteredWords.length} / ${allWords.length}টি শব্দ',
                    style: const TextStyle(
                      color: AppColors.deepRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: filteredWords.isEmpty
                    ? const Center(child: Text('কোনো মিল পাওয়া যায়নি।'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                        itemCount: filteredWords.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final word = filteredWords[index];

                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 11,
                                        backgroundColor: AppColors.gold,
                                        foregroundColor: AppColors.deepRed,
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          word.hanzi,
                                          style: const TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.red,
                                          ),
                                        ),
                                      ),
                                      Chip(
                                        label: Text('HSK ${word.level}'),
                                      ),
                                      IconButton(
                                        tooltip: 'শব্দের বিস্তারিত দেখুন',
                                        onPressed: () =>
                                            _openWordDetails(word, allWords),
                                        icon: const Icon(
                                          Icons.open_in_new_rounded,
                                          color: AppColors.gold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          word.pinyin,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'শব্দের উচ্চারণ শুনুন',
                                        onPressed: () =>
                                            SpeechService.speakChinese(
                                                word.hanzi),
                                        icon: const Icon(
                                          Icons.volume_up_rounded,
                                          color: AppColors.gold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'বাংলা অর্থ: ${word.meaningBn.isNotEmpty ? word.meaningBn : word.meaning}',
                                  ),
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
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Pinyin: ${word.examplePinyin}',
                                            style: const TextStyle(
                                              color: AppColors.muted,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'উদাহরণ বাক্য শুনুন',
                                          onPressed: () =>
                                              SpeechService.speakChinese(
                                                  word.example),
                                          icon: const Icon(
                                            Icons.volume_up_rounded,
                                            color: AppColors.gold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text('বাংলা: ${word.translation}'),
                                  ],
                                  const SizedBox(height: 12),
                                  const Divider(height: 1),
                                  const SizedBox(height: 8),
                                  Builder(
                                    builder: (context) {
                                      final id = _wordId(word);
                                      final isFavorite =
                                          _favorites.contains(id);
                                      final isLearned = _learned.contains(id);

                                      return Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () =>
                                                  _toggleFavorite(word),
                                              icon: Icon(
                                                isFavorite
                                                    ? Icons.star_rounded
                                                    : Icons.star_border_rounded,
                                                color: AppColors.gold,
                                              ),
                                              label: Text(
                                                isFavorite
                                                    ? 'প্রিয় তালিকায় আছে'
                                                    : 'প্রিয় শব্দ',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 7,
                                                  vertical: 5,
                                                ),
                                                minimumSize: const Size(0, 34),
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                visualDensity:
                                                    VisualDensity.compact,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: FilledButton.icon(
                                              onPressed: isLearned
                                                  ? null
                                                  : () => _markLearned(word),
                                              icon: Icon(
                                                isLearned
                                                    ? Icons.check_circle
                                                    : Icons.check,
                                                size: 16,
                                              ),
                                              label: Text(
                                                isLearned
                                                    ? 'শেখা হয়েছে'
                                                    : 'শিখেছি',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              style: FilledButton.styleFrom(
                                                backgroundColor: AppColors.gold,
                                                foregroundColor:
                                                    AppColors.deepRed,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 7,
                                                  vertical: 5,
                                                ),
                                                minimumSize: const Size(0, 34),
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                visualDensity:
                                                    VisualDensity.compact,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
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

  Future<void> _openWordDetails(
    VocabWord word,
    List<VocabWord> allWords,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VocabularyDetailsScreen(
          word: word,
          allWords: allWords,
        ),
      ),
    );

    if (mounted) {
      await _loadLearningState();
    }
  }

  Widget _levelChip(String label, int? level) {
    final selected = level == null
        ? _selectedLevels.isEmpty
        : _selectedLevels.contains(level);

    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: AppColors.gold,
        onSelected: (_) {
          setState(() {
            if (level == null) {
              _selectedLevels.clear();
            } else {
              if (_selectedLevels.contains(level)) {
                _selectedLevels.remove(level);
              } else {
                _selectedLevels.add(level);
              }
            }
          });
        },
      ),
    );
  }
}

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late final Future<List<VocabWord>> _wordsFuture;

  Set<String> _favoriteIds = {};
  bool _loadingFavorites = true;

  @override
  void initState() {
    super.initState();
    _wordsFuture = VocabService.loadWords();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await LearningStore.getFavorites();
      if (!mounted) return;

      setState(() {
        _favoriteIds = favorites;
        _loadingFavorites = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingFavorites = false);
    }
  }

  String _wordId(VocabWord word) {
    return LearningStore.wordId(
      level: word.level,
      hanzi: word.hanzi,
      pinyin: word.pinyin,
    );
  }

  Future<void> _removeFavorite(VocabWord word) async {
    final id = _wordId(word);

    await LearningStore.toggleFavorite(id);

    if (!mounted) return;

    setState(() {
      _favoriteIds.remove(id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${word.hanzi} প্রিয় তালিকা থেকে সরানো হয়েছে')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final foreground = Theme.of(context).colorScheme.onSurface;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        title: const Text('আমার প্রিয় শব্দ ⭐'),
      ),
      body: FutureBuilder<List<VocabWord>>(
        future: _wordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              _loadingFavorites) {
            return const Center(child: CircularProgressIndicator());
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

          final allWords = snapshot.data ?? [];

          final favoriteWords = allWords
              .where((word) => _favoriteIds.contains(_wordId(word)))
              .toList();

          if (favoriteWords.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_border_rounded,
                      size: 76,
                      color: AppColors.gold.withValues(alpha: 0.8),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'এখনো কোনো প্রিয় শব্দ নেই',
                      style: TextStyle(
                        color: foreground,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'শব্দভান্ডার থেকে ⭐ প্রিয় শব্দ বাটনে চাপ দিয়ে '
                      'আপনার পছন্দের শব্দ এখানে যোগ করুন।',
                      style: TextStyle(color: muted, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VocabularyScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.menu_book_rounded),
                      label: const Text('শব্দভান্ডারে যান'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.deepRed,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'সংরক্ষিত শব্দ: ${favoriteWords.length}টি',
                      style: TextStyle(
                        color: foreground,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 16),
                  itemCount: favoriteWords.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 9),
                  itemBuilder: (context, index) {
                    final word = favoriteWords[index];

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    word.hanzi,
                                    style: const TextStyle(
                                      color: AppColors.gold,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                Chip(
                                  label: Text('HSK ${word.level}'),
                                ),
                                IconButton(
                                  tooltip: 'প্রিয় তালিকা থেকে সরান',
                                  onPressed: () => _removeFavorite(word),
                                  icon: const Icon(
                                    Icons.star_rounded,
                                    color: AppColors.gold,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              word.pinyin,
                              style: TextStyle(
                                color: foreground,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'বাংলা অর্থ: ${word.meaningBn.isNotEmpty ? word.meaningBn : word.meaning}',
                            ),
                            if (word.meaning.isNotEmpty)
                              Text(
                                'English: ${word.meaning}',
                                style: TextStyle(color: muted),
                              ),
                            if (word.example.isNotEmpty) ...[
                              const Divider(height: 22),
                              Text(
                                'উদাহরণ: ${word.example}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Pinyin: ${word.examplePinyin}',
                                style: TextStyle(color: muted),
                              ),
                              Text('বাংলা: ${word.translation}'),
                            ],
                          ],
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

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final Map<int, int> answers = {};
  int currentQuestion = 0;
  bool submitted = false;

  int get score => List.generate(quiz.length, (i) => i)
      .where((i) => answers[i] == quiz[i].answer)
      .length;

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get pageColor =>
      isDark ? const Color(0xFF090909) : const Color(0xFFF5F1E8);
  Color get panelColor => isDark ? const Color(0xFF171717) : Colors.white;
  Color get primaryText =>
      isDark ? const Color(0xFFFFF4D6) : const Color(0xFF17130B);
  Color get secondaryText =>
      isDark ? const Color(0xFFB8AE98) : const Color(0xFF746B5B);

  Future<void> _submit() async {
    if (answers.length != quiz.length) return;
    setState(() => submitted = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lesson1_score', score);
  }

  void _restart() {
    setState(() {
      answers.clear();
      currentQuestion = 0;
      submitted = false;
    });
  }

  void _next() {
    if (currentQuestion < quiz.length - 1) {
      setState(() => currentQuestion++);
    }
  }

  void _previous() {
    if (currentQuestion > 0) {
      setState(() => currentQuestion--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = quiz[currentQuestion];
    final selected = answers[currentQuestion];
    final progress = answers.length / quiz.length;

    return Scaffold(
      backgroundColor: pageColor,
      appBar: AppBar(
        title: const Text('অনুশীলন কেন্দ্র'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.55),
                  ),
                ),
                child: Text(
                  'HSK 1',
                  style: TextStyle(
                    color: isDark ? AppColors.lightGold : AppColors.deepRed,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: submitted
            ? _buildResult()
            : ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                children: [
                  _buildHero(progress),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'প্রশ্ন ${currentQuestion + 1} / ${quiz.length}',
                        style: TextStyle(
                          color: primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${answers.length}টি উত্তর দেওয়া',
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 11),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AppColors.gold.withValues(alpha: 0.16),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.gold),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: panelColor,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.45),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.22 : 0.06,
                          ),
                          blurRadius: 22,
                          offset: const Offset(0, 9),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.translate_rounded,
                                color: AppColors.gold,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'শব্দার্থ নির্বাচন করুন',
                              style: TextStyle(
                                color: secondaryText,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.workspace_premium_rounded,
                              color: AppColors.gold,
                              size: 21,
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Text(
                          q.question,
                          style: TextStyle(
                            color: primaryText,
                            fontSize: 23,
                            height: 1.45,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'সঠিক উত্তরটি বেছে নিন',
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 22),
                        ...List.generate(
                          q.options.length,
                          (index) => _buildOption(
                            index: index,
                            label: q.options[index],
                            selected: selected == index,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: currentQuestion == 0 ? null : _previous,
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text('আগের প্রশ্ন'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.gold,
                            side: BorderSide(
                              color: AppColors.gold.withValues(alpha: 0.7),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: selected == null
                              ? null
                              : currentQuestion == quiz.length - 1
                                  ? (answers.length == quiz.length
                                      ? _submit
                                      : null)
                                  : _next,
                          icon: Icon(
                            currentQuestion == quiz.length - 1
                                ? Icons.check_circle_rounded
                                : Icons.arrow_forward_rounded,
                          ),
                          label: Text(
                            currentQuestion == quiz.length - 1
                                ? 'কুইজ জমা'
                                : 'পরের প্রশ্ন',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: const Color(0xFF17130B),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'সব প্রশ্নের উত্তর দিলে কুইজ জমা দিতে পারবেন',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: secondaryText, fontSize: 11),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHero(double progress) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF17130B), Color(0xFF3B2B0B), Color(0xFF17130B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.13),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  color: AppColors.lightGold, size: 19),
              const SizedBox(width: 8),
              const Text(
                'PREMIUM PRACTICE',
                style: TextStyle(
                  color: AppColors.lightGold,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              const Icon(Icons.school_rounded,
                  color: AppColors.lightGold, size: 24),
            ],
          ),
          const SizedBox(height: 17),
          const Text(
            'আজকের চ্যালেঞ্জ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'শিখুন • মনে রাখুন • নিজের দক্ষতা যাচাই করুন',
            style: TextStyle(
              color: Color(0xFFE9DDBD),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _heroStat(Icons.quiz_rounded, '${quiz.length}', 'প্রশ্ন'),
              const SizedBox(width: 10),
              _heroStat(Icons.check_circle_outline_rounded, '${answers.length}',
                  'উত্তর'),
              const SizedBox(width: 10),
              _heroStat(Icons.stars_rounded, '${(progress * 100).round()}%',
                  'সম্পন্ন'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.lightGold, size: 17),
            const SizedBox(width: 6),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      )),
                  Text(label,
                      style: const TextStyle(
                        color: Color(0xFFE9DDBD),
                        fontSize: 10,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required int index,
    required String label,
    required bool selected,
  }) {
    final isCorrect = submitted && index == quiz[currentQuestion].answer;
    final isWrongSelected =
        submitted && selected && index != quiz[currentQuestion].answer;

    Color borderColor =
        selected ? AppColors.gold : AppColors.gold.withValues(alpha: 0.22);
    Color background = selected
        ? AppColors.gold.withValues(alpha: isDark ? 0.19 : 0.13)
        : (isDark ? const Color(0xFF202020) : const Color(0xFFFFFCF5));

    if (isCorrect) {
      borderColor = AppColors.success;
      background = AppColors.success.withValues(alpha: 0.10);
    } else if (isWrongSelected) {
      borderColor = AppColors.red;
      background = AppColors.red.withValues(alpha: 0.10);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: submitted
            ? null
            : () => setState(() => answers[currentQuestion] = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: selected || isCorrect || isWrongSelected ? 1.7 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.gold
                      : AppColors.gold.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    color: selected ? const Color(0xFF17130B) : AppColors.gold,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                isCorrect
                    ? Icons.check_circle_rounded
                    : isWrongSelected
                        ? Icons.cancel_rounded
                        : selected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                color: isCorrect
                    ? AppColors.success
                    : isWrongSelected
                        ? AppColors.red
                        : selected
                            ? AppColors.gold
                            : secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResult() {
    final percentage = (score / quiz.length * 100).round();
    final message = score >= 8
        ? 'অসাধারণ! আপনার প্রস্তুতি দারুণ।'
        : score >= 5
            ? 'ভালো চেষ্টা! আরও একটু অনুশীলন করুন।'
            : 'চিন্তা নেই—আবার চেষ্টা করলেই উন্নতি হবে।';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(22, 30, 22, 26),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF17130B), Color(0xFF49370D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.gold),
          ),
          child: Column(
            children: [
              const Icon(Icons.emoji_events_rounded,
                  color: AppColors.lightGold, size: 62),
              const SizedBox(height: 14),
              const Text(
                'কুইজ সম্পন্ন!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$score / ${quiz.length}',
                style: const TextStyle(
                  color: AppColors.lightGold,
                  fontSize: 46,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '$percentage% সঠিক উত্তর',
                style: const TextStyle(
                  color: Color(0xFFE9DDBD),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'উত্তরের বিস্তারিত',
          style: TextStyle(
            color: primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        ...List.generate(quiz.length, (i) {
          final correct = answers[i] == quiz[i].answer;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: panelColor,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: (correct ? AppColors.success : AppColors.red)
                    .withValues(alpha: 0.45),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      correct ? Icons.check_circle : Icons.cancel,
                      color: correct ? AppColors.success : AppColors.red,
                      size: 19,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'প্রশ্ন ${i + 1}: ${quiz[i].question}',
                        style: TextStyle(
                          color: primaryText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'আপনার উত্তর: ${answers[i] == null ? 'দেওয়া হয়নি' : quiz[i].options[answers[i]!]}',
                  style: TextStyle(color: secondaryText, fontSize: 13),
                ),
                Text(
                  'সঠিক উত্তর: ${quiz[i].options[quiz[i].answer]}',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  quiz[i].explanation,
                  style: TextStyle(color: secondaryText, fontSize: 12),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: _restart,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('আবার কুইজ দিন'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: const Color(0xFF17130B),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  Future<int?> _getScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('lesson1_score');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('আমার অগ্রগতি')),
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
                      textAlign: TextAlign.center),
                );
              }
              return Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.emoji_events, size: 72, color: AppColors.gold),
                const SizedBox(height: 12),
                const Text('সর্বশেষ কুইজের ফলাফল',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('$score / 10',
                    style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: AppColors.red)),
                Text(score >= 8 ? 'দারুণ অগ্রগতি!' : 'আরও অনুশীলন করুন।'),
              ]);
            },
          ),
        ),
      );
}

// -------------------- Google AdMob Banner --------------------

class BannerAdBar extends StatefulWidget {
  const BannerAdBar({super.key});
  @override
  State<BannerAdBar> createState() => _BannerAdBarState();
}

class _BannerAdBarState extends State<BannerAdBar> {
  gma.BannerAd? banner;
  bool loaded = false;

  // Google sample test Banner ID; production-এ নিজের Ad Unit ID বসাতে হবে।
  static const testBannerId = 'ca-app-pub-3940256099942544/6300978111';

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
          if (mounted) setState(() => loaded = false);
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
    if (!loaded || banner == null) return const SizedBox.shrink();
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

// -------------------- শব্দের বিস্তারিত --------------------

class VocabularyDetailsScreen extends StatefulWidget {
  final VocabWord word;
  final List<VocabWord> allWords;

  const VocabularyDetailsScreen({
    super.key,
    required this.word,
    required this.allWords,
  });

  @override
  State<VocabularyDetailsScreen> createState() =>
      _VocabularyDetailsScreenState();
}

class _VocabularyDetailsScreenState extends State<VocabularyDetailsScreen> {
  late int _currentIndex;
  bool _isFavorite = false;
  bool _isLearned = false;
  bool _loading = true;

  VocabWord get _word => widget.allWords[_currentIndex];

  String get _wordId => LearningStore.wordId(
        level: _word.level,
        hanzi: _word.hanzi,
        pinyin: _word.pinyin,
      );

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.allWords.indexOf(widget.word);
    if (_currentIndex < 0) _currentIndex = 0;
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final favorites = await LearningStore.getFavorites();
    final learned = await LearningStore.getLearnedWords();

    if (!mounted) return;

    setState(() {
      _isFavorite = favorites.contains(_wordId);
      _isLearned = learned.contains(_wordId);
      _loading = false;
    });
  }

  Future<void> _toggleFavorite() async {
    await LearningStore.toggleFavorite(_wordId);
    if (!mounted) return;

    setState(() => _isFavorite = !_isFavorite);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite
              ? '${_word.hanzi} প্রিয় শব্দে যোগ হয়েছে'
              : '${_word.hanzi} প্রিয় তালিকা থেকে সরানো হয়েছে',
        ),
      ),
    );
  }

  Future<void> _markLearned() async {
    if (_isLearned) return;

    await LearningStore.markLearned(_wordId);
    if (!mounted) return;

    setState(() => _isLearned = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_word.hanzi} শেখা হয়েছে!')),
    );
  }

  Future<void> _changeWord(int newIndex) async {
    if (newIndex < 0 || newIndex >= widget.allWords.length) return;

    setState(() {
      _currentIndex = newIndex;
      _loading = true;
    });

    await _loadStatus();
  }

  Widget _detailSection({
    required String title,
    required Widget child,
    IconData? icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColors.gold, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final word = _word;
    final foreground = Theme.of(context).colorScheme.onSurface;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    final banglaMeaning =
        word.meaningBn.isNotEmpty ? word.meaningBn : word.meaning;

    return Scaffold(
      appBar: AppBar(
        title: const Text('শব্দের বিস্তারিত'),
        actions: [
          IconButton(
            tooltip: _isFavorite ? 'প্রিয় থেকে সরান' : 'প্রিয় শব্দে রাখুন',
            onPressed: _loading ? null : _toggleFavorite,
            icon: Icon(
              _isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: AppColors.gold,
              size: 27,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // Premium Chinese word card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 28,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF302817),
                  Color(0xFF15130F),
                  Color(0xFF050505),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.75),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.10),
                  blurRadius: 22,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.55),
                    ),
                  ),
                  child: Text(
                    'HSK ${word.level} • CHINESE VOCABULARY',
                    style: const TextStyle(
                      color: AppColors.lightGold,
                      fontSize: 10,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    word.hanzi,
                    style: const TextStyle(
                      color: AppColors.lightGold,
                      fontSize: 68,
                      height: 1.2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  word.pinyin,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                IconButton(
                  tooltip: 'চীনা শব্দের উচ্চারণ শুনুন',
                  onPressed: () => SpeechService.speakChinese(word.hanzi),
                  icon: const Icon(
                    Icons.volume_up_rounded,
                    color: AppColors.lightGold,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  banglaMeaning,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.lightGold,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 17),

          _detailSection(
            title: 'শব্দের অর্থ',
            icon: Icons.translate_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'বাংলা অর্থ',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  banglaMeaning,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (word.meaning.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    'English meaning',
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    word.meaning,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          if (word.example.isNotEmpty) ...[
            _detailSection(
              title: 'উদাহরণ বাক্য',
              icon: Icons.chat_bubble_outline_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.example,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      height: 1.5,
                    ),
                  ),
                  if (word.examplePinyin.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      word.examplePinyin,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        tooltip: 'উদাহরণ বাক্যের উচ্চারণ শুনুন',
                        onPressed: () =>
                            SpeechService.speakChinese(word.example),
                        icon: const Icon(
                          Icons.volume_up_rounded,
                          color: AppColors.gold,
                          size: 27,
                        ),
                      ),
                    ),
                  ],
                  if (word.translation.isNotEmpty) ...[
                    const Divider(height: 25),
                    Text(
                      'বাংলা অনুবাদ',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      word.translation,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 8),

          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isFavorite ? _toggleFavorite : _toggleFavorite,
                    icon: Icon(
                      _isFavorite
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                    ),
                    label: Text(_isFavorite ? 'প্রিয় শব্দ' : 'প্রিয়তে রাখুন'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isLearned ? null : _markLearned,
                    icon: Icon(
                      _isLearned
                          ? Icons.check_circle_rounded
                          : Icons.check_rounded,
                    ),
                    label: Text(_isLearned ? 'শেখা হয়েছে' : 'শিখেছি'),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _currentIndex > 0
                      ? () => _changeWord(_currentIndex - 1)
                      : null,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('আগের শব্দ'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _currentIndex < widget.allWords.length - 1
                      ? () => _changeWord(_currentIndex + 1)
                      : null,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('পরের শব্দ'),
                  iconAlignment: IconAlignment.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
