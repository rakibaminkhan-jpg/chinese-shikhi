import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

const Color _radioGold = Color(0xFFD4AF37);
const Color _radioDark = Color(0xFF171717);

class _RadioStation {
  final String name;
  final String chineseName;
  final String description;
  final String url;

  const _RadioStation({
    required this.name,
    required this.chineseName,
    required this.description,
    required this.url,
  });
}

class ChineseLiveRadioScreen extends StatefulWidget {
  const ChineseLiveRadioScreen({super.key});

  @override
  State<ChineseLiveRadioScreen> createState() => _ChineseLiveRadioScreenState();
}

class _ChineseLiveRadioScreenState extends State<ChineseLiveRadioScreen> {
  static const List<_RadioStation> _stations = [
    _RadioStation(
      name: 'CNR 1 — China National Radio',
      chineseName: '中国之声',
      description: 'চীনের সংবাদ ও সাধারণ অনুষ্ঠান',
      url: 'https://lhttp.qtfm.cn/live/15318317/64k.mp3',
    ),
    _RadioStation(
      name: 'CNR 3 — Music Radio',
      chineseName: '音乐之声',
      description: 'চীনা গান ও সংগীত অনুষ্ঠান',
      url: 'https://ngcdn001.cnr.cn/live/yyzs/index.m3u8',
    ),
    _RadioStation(
      name: 'Shanghai FM 101',
      chineseName: '上海人民广播电台',
      description: 'সাংহাইয়ের রেডিও সম্প্রচার',
      url: 'https://lhttp.qingting.fm/live/274/64k.mp3',
    ),
    _RadioStation(
      name: 'Beijing News Radio',
      chineseName: '北京新闻广播',
      description: 'চীনা সংবাদ ও আলোচনা',
      url: 'https://lhttp.qtfm.cn/live/339/64k.mp3',
    ),
  ];

  final AudioPlayer _player = AudioPlayer();
  int _selectedIndex = 0;
  bool _loading = false;
  bool _hasSource = false;
  String? _error;

  _RadioStation get _selectedStation => _stations[_selectedIndex];

  Future<void> _playStation(int index) async {
    setState(() {
      _selectedIndex = index;
      _loading = true;
      _error = null;
      _hasSource = false;
    });

    try {
      await _player.stop();
      await _player.setUrl(_selectedStation.url);
      if (!mounted) return;

      setState(() {
        _loading = false;
        _hasSource = true;
      });
      unawaited(_player.play());
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasSource = false;
        _error = 'এই স্টেশনটি এখন চালু করা যাচ্ছে না। অন্য স্টেশন চেষ্টা করো।';
      });
    }
  }

  Future<void> _togglePlayback() async {
    if (_loading) return;

    if (_player.playing) {
      await _player.pause();
    } else if (!_hasSource) {
      await _playStation(_selectedIndex);
    } else {
      setState(() => _error = null);
      unawaited(_player.play());
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chinese Live Radio')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [_radioDark, Color(0xFF493719)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.radio_rounded, color: _radioGold, size: 54),
                const SizedBox(height: 12),
                const Text(
                  '中文电台',
                  style: TextStyle(
                    color: _radioGold,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'চীনা ভাষা শুনে শুনে শেখো',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 22),
                Text(
                  _selectedStation.chineseName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _selectedStation.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 18),
                StreamBuilder<PlayerState>(
                  stream: _player.playerStateStream,
                  builder: (context, snapshot) {
                    final state = snapshot.data;
                    final playing = state?.playing ?? false;
                    final buffering = _loading ||
                        state?.processingState == ProcessingState.loading ||
                        state?.processingState == ProcessingState.buffering;

                    return Column(
                      children: [
                        if (buffering)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: CircularProgressIndicator(color: _radioGold),
                          ),
                        FilledButton.icon(
                          onPressed: buffering ? null : _togglePlayback,
                          style: FilledButton.styleFrom(
                            backgroundColor: _radioGold,
                            foregroundColor: _radioDark,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 26,
                              vertical: 13,
                            ),
                          ),
                          icon: Icon(
                            buffering
                                ? Icons.hourglass_top_rounded
                                : playing
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                          ),
                          label: Text(
                            buffering
                                ? 'লোড হচ্ছে...'
                                : playing
                                    ? 'Pause Radio'
                                    : 'Play Radio',
                          ),
                        ),
                        if (playing) ...[
                          const SizedBox(height: 10),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.graphic_eq, color: _radioGold),
                              SizedBox(width: 6),
                              Text(
                                'LIVE চলছে',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ],
                    );
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.orangeAccent),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'রেডিও স্টেশন বেছে নাও',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          ...List.generate(_stations.length, (index) {
            final station = _stations[index];
            final selected = index == _selectedIndex;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: selected ? _radioGold : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: ListTile(
                onTap: () => _playStation(index),
                leading: CircleAvatar(
                  backgroundColor: _radioGold.withValues(alpha: 0.18),
                  child: Icon(
                    selected ? Icons.equalizer_rounded : Icons.radio_rounded,
                    color: const Color(0xFF9B7410),
                  ),
                ),
                title: Text(
                  station.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${station.chineseName} • ${station.description}',
                ),
                trailing: Icon(
                  selected ? Icons.check_circle : Icons.play_circle_outline,
                  color: selected ? _radioGold : null,
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          const Text(
            'নোট: ইন্টারনেট সংযোগ প্রয়োজন। কোনো স্ট্রিম সাময়িকভাবে বন্ধ থাকলে অন্য স্টেশন বেছে নাও।',
            style: TextStyle(color: Colors.grey, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
