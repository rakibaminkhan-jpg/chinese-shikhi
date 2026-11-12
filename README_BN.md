# চীনা শিখি (Chinese Shikhi) — Flutter Starter

এই প্রজেক্টটি একটি **প্রথম MVP/starter app**: Home, HSK 1-এর ২০টি শব্দ, উদাহরণ বাক্য, ১০টি MCQ, লোকাল কুইজ স্কোর এবং AdMob-এর Google test banner ad।

## ১) যা ইনস্টল করতে হবে
1. Flutter SDK (stable channel)
2. Android Studio
3. Android SDK ও Android Emulator অথবা USB debugging চালু করা Android ফোন
4. Windows হলে Flutter-এর `bin` ফোল্ডার PATH-এ যোগ করুন।

ইনস্টল যাচাই:
```bash
flutter doctor
```
যে Android license বাকি থাকবে:
```bash
flutter doctor --android-licenses
```

## ২) প্রজেক্ট চালু
ZIP extract করুন। টার্মিনালে `chinese_shikhi_flutter` ফোল্ডারে যান:
```bash
flutter pub get
flutter run
```

প্রথমবার Android Studio-তে খুললে Gradle/SDK সেটআপ শেষ হতে দিন। Flutter-এর নতুন stable template থেকে Android wrapper তৈরি করতে চাইলে:
```bash
flutter create --platforms=android .
```
এরপর `android/app/src/main/AndroidManifest.xml`-এ থাকা AdMob `<meta-data>` আবার যাচাই করুন; Flutter template তৈরি করলে manifest overwrite হতে পারে।

## ৩) AdMob
এই starter-এ Google-এর **sample test App ID এবং sample banner unit ID** রাখা হয়েছে। এগুলো দিয়ে শুধু development/test করুন। নিজের বিজ্ঞাপনে কখনো ক্লিক করবেন না এবং production-এ test ID ব্যবহার করবেন না।

Production-এর আগে:
- AdMob-এ app তৈরি করে নিজের Android App ID সংগ্রহ করুন।
- নিজের Banner Ad Unit ID তৈরি করুন।
- `android/app/src/main/AndroidManifest.xml`-এ `APPLICATION_ID`-এর value বদলান।
- `lib/services/ad_service.dart`-এ `_androidBannerTestId` বদলান।
- প্রয়োজনীয় consent/privacy ব্যবস্থা এবং Google Play/AdMob নীতিমালা যাচাই করুন।
- বিজ্ঞাপন স্বাভাবিক ব্যবহার ব্যাহত করবে এমনভাবে বসাবেন না।

## ৪) Android build
```bash
flutter build apk --release
```
ফাইল পাওয়া যাবে:
`build/app/outputs/flutter-apk/app-release.apk`

Play Store-এর জন্য সাধারণত:
```bash
flutter build appbundle --release
```
ফাইল:
`build/app/outputs/bundle/release/app-release.aab`

## ৫) ফোল্ডার
```text
lib/
  main.dart
  data/
    lesson_one.dart
  models/
    vocab_word.dart
  services/
    ad_service.dart
android/
  app/src/main/AndroidManifest.xml
pubspec.yaml
```

## ৬) বর্তমান সীমাবদ্ধতা
- শুধু Lesson 01-এর ২০টি শব্দ ও ১০টি কুইজ আছে।
- স্কোর এই ডিভাইসেই SharedPreferences-এ রাখা হয়; account/cloud sync নেই।
- উচ্চারণের অডিও নেই; ভবিষ্যতে অনুমোদিত audio source/TTS যোগ করতে হবে।
- HSK 2–4 এখনো যুক্ত হয়নি।
- Privacy Policy URL, app icon, screenshots, store listing এবং production AdMob IDs প্রকাশের আগে যোগ করতে হবে।
- Play Console-এর বর্তমান testing/verification শর্ত আপনার account type ও policy অনুযায়ী দেখে নিতে হবে।

## ৭) গুরুত্বপূর্ণ
এই ZIP source code; এটি নিজে থেকে APK নয় এবং এখানে Android build চালানো হয়নি। Flutter SDK-সহ কম্পিউটারে উপরের কমান্ড চালিয়ে build ও device testing করতে হবে।

## ৮) কম্পিউটারে Flutter ইনস্টল না করেও APK build (GitHub Actions)
এই প্রজেক্টে `.github/workflows/build-apk.yml` workflow আছে। GitHub-এ প্রজেক্ট upload করার পর:
1. GitHub-এ নতুন একটি repository তৈরি করে এই ফোল্ডারের সব ফাইল upload/push করুন।
2. Repository-এর **Actions** tab খুলুন।
3. **Build Chinese Shikhi APK** workflow নির্বাচন করে **Run workflow** চাপুন (অথবা `main` branch-এ push হলে নিজে থেকে build হবে)।
4. Build সফল হলে workflow run-এর নিচের **Artifacts** অংশ থেকে `chinese-shikhi-release-apk` ZIP ডাউনলোড করুন।
5. ZIP extract করে `app-release.apk` Android ফোনে পাঠিয়ে ইনস্টল করুন। ফোনে প্রয়োজন হলে browser/file manager-এর জন্য “Install unknown apps” অনুমতি দিন।

GitHub Actions-এ APK build হওয়া নিশ্চিত নয় যতক্ষণ workflow সফলভাবে শেষ না হয়। Build error হলে Actions log থেকে ত্রুটি ঠিক করতে হবে। এই APK development build; Play Store-এ প্রকাশের আগে নিজের AdMob IDs, privacy policy, signing ও Play policy প্রস্তুত করুন।
