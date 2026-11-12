import '../models/vocab_word.dart';

const lessonOne = <VocabWord>[
  VocabWord(hanzi:'我', pinyin:'wǒ', meaning:'আমি', example:'我是学生。', examplePinyin:'Wǒ shì xuésheng.', translation:'আমি একজন শিক্ষার্থী।'),
  VocabWord(hanzi:'你', pinyin:'nǐ', meaning:'তুমি', example:'你是老师吗？', examplePinyin:'Nǐ shì lǎoshī ma?', translation:'তুমি কি শিক্ষক?'),
  VocabWord(hanzi:'他', pinyin:'tā', meaning:'সে (পুরুষ)', example:'他是我的朋友。', examplePinyin:'Tā shì wǒ de péngyou.', translation:'সে আমার বন্ধু।'),
  VocabWord(hanzi:'她', pinyin:'tā', meaning:'সে (নারী)', example:'她是学生。', examplePinyin:'Tā shì xuésheng.', translation:'সে একজন শিক্ষার্থী।'),
  VocabWord(hanzi:'我们', pinyin:'wǒmen', meaning:'আমরা', example:'我们学习中文。', examplePinyin:'Wǒmen xuéxí Zhōngwén.', translation:'আমরা চীনা ভাষা শিখি।'),
  VocabWord(hanzi:'你们', pinyin:'nǐmen', meaning:'তোমরা', example:'你们好吗？', examplePinyin:'Nǐmen hǎo ma?', translation:'তোমরা কি ভালো আছ?'),
  VocabWord(hanzi:'他们', pinyin:'tāmen', meaning:'তারা', example:'他们是朋友。', examplePinyin:'Tāmen shì péngyou.', translation:'তারা বন্ধু।'),
  VocabWord(hanzi:'是', pinyin:'shì', meaning:'হওয়া / হয়', example:'我是老师。', examplePinyin:'Wǒ shì lǎoshī.', translation:'আমি শিক্ষক।'),
  VocabWord(hanzi:'不', pinyin:'bù', meaning:'না', example:'我不是老师。', examplePinyin:'Wǒ bú shì lǎoshī.', translation:'আমি শিক্ষক নই।'),
  VocabWord(hanzi:'有', pinyin:'yǒu', meaning:'আছে / থাকা', example:'我有朋友。', examplePinyin:'Wǒ yǒu péngyou.', translation:'আমার বন্ধু আছে।'),
  VocabWord(hanzi:'没', pinyin:'méi', meaning:'নেই / না', example:'我没有钱。', examplePinyin:'Wǒ méiyǒu qián.', translation:'আমার টাকা নেই।'),
  VocabWord(hanzi:'人', pinyin:'rén', meaning:'মানুষ', example:'他是中国人。', examplePinyin:'Tā shì Zhōngguó rén.', translation:'সে চীনা মানুষ।'),
  VocabWord(hanzi:'朋友', pinyin:'péngyou', meaning:'বন্ধু', example:'她是我的朋友。', examplePinyin:'Tā shì wǒ de péngyou.', translation:'সে আমার বন্ধু।'),
  VocabWord(hanzi:'老师', pinyin:'lǎoshī', meaning:'শিক্ষক', example:'老师好！', examplePinyin:'Lǎoshī hǎo!', translation:'শিক্ষক, নমস্কার!'),
  VocabWord(hanzi:'学生', pinyin:'xuésheng', meaning:'শিক্ষার্থী', example:'我是学生。', examplePinyin:'Wǒ shì xuésheng.', translation:'আমি একজন শিক্ষার্থী।'),
  VocabWord(hanzi:'中国', pinyin:'Zhōngguó', meaning:'চীন', example:'我去中国。', examplePinyin:'Wǒ qù Zhōngguó.', translation:'আমি চীনে যাই।'),
  VocabWord(hanzi:'中文', pinyin:'Zhōngwén', meaning:'চীনা ভাষা', example:'我学习中文。', examplePinyin:'Wǒ xuéxí Zhōngwén.', translation:'আমি চীনা ভাষা শিখি।'),
  VocabWord(hanzi:'学习', pinyin:'xuéxí', meaning:'শেখা / অধ্যয়ন করা', example:'我学习汉语。', examplePinyin:'Wǒ xuéxí Hànyǔ.', translation:'আমি চীনা ভাষা অধ্যয়ন করি।'),
  VocabWord(hanzi:'什么', pinyin:'shénme', meaning:'কী', example:'你叫什么名字？', examplePinyin:'Nǐ jiào shénme míngzi?', translation:'তোমার নাম কী?'),
  VocabWord(hanzi:'谁', pinyin:'shéi', meaning:'কে', example:'谁是老师？', examplePinyin:'Shéi shì lǎoshī?', translation:'কে শিক্ষক?'),
];

class QuizQuestion {
  final String question;
  final List<String> options;
  final int answer;
  final String explanation;
  const QuizQuestion(this.question, this.options, this.answer, this.explanation);
}

const lessonOneQuiz = <QuizQuestion>[
  QuizQuestion('我 (wǒ) অর্থ কী?', ['তুমি','আমি','সে','আমরা'], 1, '我 অর্থ আমি।'),
  QuizQuestion('朋友 (péngyou) অর্থ কী?', ['শিক্ষক','মানুষ','বন্ধু','শিক্ষার্থী'], 2, '朋友 অর্থ বন্ধু।'),
  QuizQuestion('老师 (lǎoshī) অর্থ কী?', ['শিক্ষক','ছাত্র','বন্ধু','পরিবার'], 0, '老师 অর্থ শিক্ষক।'),
  QuizQuestion('中文 (Zhōngwén) অর্থ কী?', ['চীন','বাংলা','ইংরেজি','চীনা ভাষা'], 3, '中文 অর্থ চীনা ভাষা।'),
  QuizQuestion('你 (nǐ) অর্থ কী?', ['আমি','তুমি','সে','তারা'], 1, '你 অর্থ তুমি।'),
  QuizQuestion('学习 (xuéxí) অর্থ কী?', ['খাওয়া','যাওয়া','শেখা','বলা'], 2, '学习 অর্থ শেখা বা অধ্যয়ন করা।'),
  QuizQuestion('什么 (shénme) অর্থ কী?', ['কে','কোথায়','কখন','কী'], 3, '什么 অর্থ কী।'),
  QuizQuestion('不 (bù) অর্থ কী?', ['না','হ্যাঁ','আছে','কে'], 0, '不 সাধারণত নেতিবাচক অর্থ প্রকাশ করে।'),
  QuizQuestion('我们 (wǒmen) অর্থ কী?', ['তোমরা','তারা','আমরা','সে'], 2, '我们 অর্থ আমরা।'),
  QuizQuestion('谁 (shéi) অর্থ কী?', ['কী','কে','কোথায়','কেন'], 1, '谁 অর্থ কে।'),
];
