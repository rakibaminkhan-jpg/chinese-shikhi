import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  SpeechService._();

  static final FlutterTts _tts = FlutterTts();
  static bool _initialized = false;

  static Future<void> _initialize() async {
    if (_initialized) return;

    await _tts.setLanguage('zh-CN');
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);

    _initialized = true;
  }

  static Future<void> speakChinese(String text) async {
    if (text.trim().isEmpty) return;

    try {
      await _initialize();
      await _tts.stop();
      await _tts.speak(text);
    } catch (e) {
      // TTS কাজ না করলেও মূল অ্যাপ বন্ধ হবে না।
    }
  }

  static Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
