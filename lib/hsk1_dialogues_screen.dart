import 'package:material_ui/material_ui.dart';
import 'package:video_player/video_player.dart';

class Hsk1DialoguesScreen extends StatefulWidget {
  const Hsk1DialoguesScreen({super.key});

  @override
  State<Hsk1DialoguesScreen> createState() => _Hsk1DialoguesScreenState();
}

class _Hsk1DialoguesScreenState extends State<Hsk1DialoguesScreen> {
  static const String _videoUrl =
      'https://res.cloudinary.com/wdkupge5/video/upload/v1794831585/HSK_1_Dialogues_Exposed__The_Secrets_You_Didn_t_Know.mp4';

  static const Color _gold = Color(0xFFD4AF37);
  static const Color _dark = Color(0xFF101010);

  VideoPlayerController? _controller;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(_videoUrl),
    );

    _controller = controller;

    try {
      await controller.initialize();
      await controller.setLooping(false);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _loading = false;
        _error = null;
      });
    } catch (e) {
      await controller.dispose();

      if (!mounted) return;

      if (identical(_controller, controller)) {
        _controller = null;
      }

      setState(() {
        _loading = false;
        _error =
            'ভিডিও লোড করা যায়নি। ইন্টারনেট সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।';
      });
    }
  }

  Future<void> _retryVideo() async {
    final oldController = _controller;
    _controller = null;

    await oldController?.dispose();

    if (!mounted) return;

    await _initializeVideo();
  }

  Future<void> _togglePlayback() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours;

    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  Widget _buildVideoPlayer() {
    final controller = _controller;

    if (_loading) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: ColoredBox(
          color: _dark,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: _gold),
                SizedBox(height: 14),
                Text(
                  'সার্ভার থেকে ভিডিও লোড হচ্ছে...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_error != null ||
        controller == null ||
        !controller.value.isInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: _dark,
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: _gold,
                  size: 42,
                ),
                const SizedBox(height: 12),
                Text(
                  _error ?? 'ভিডিও পাওয়া যায়নি।',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: _retryVideo,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('আবার চেষ্টা করুন'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        return AspectRatio(
          aspectRatio: value.aspectRatio > 0 ? value.aspectRatio : 16 / 9,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: VideoPlayer(controller),
              ),
              if (!value.isPlaying)
                IconButton.filled(
                  onPressed: _togglePlayback,
                  style: IconButton.styleFrom(
                    backgroundColor: _gold,
                    foregroundColor: _dark,
                  ),
                  iconSize: 42,
                  icon: const Icon(Icons.play_arrow_rounded),
                ),
              if (value.isPlaying)
                Positioned(
                  right: 12,
                  top: 12,
                  child: IconButton.filledTonal(
                    onPressed: _togglePlayback,
                    icon: const Icon(Icons.pause_rounded),
                  ),
                ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 8,
                child: VideoProgressIndicator(
                  controller,
                  allowScrubbing: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  colors: const VideoProgressColors(
                    playedColor: _gold,
                    bufferedColor: Colors.white54,
                    backgroundColor: Colors.white24,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _gold.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: _gold, size: 25),
            const SizedBox(height: 7),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HSK 1 Dialogues',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'ভিডিও আবার লোড করুন',
            onPressed: _retryVideo,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_dark, Color(0xFF382B10)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _gold.withValues(alpha: 0.6)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HSK 1 • LISTENING PRACTICE',
                  style: TextStyle(
                    color: _gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                SizedBox(height: 9),
                Text(
                  'চীনা কথোপকথন শিখুন',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'শুনুন, বুঝুন এবং Mandarin উচ্চারণ অনুশীলন করুন।',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 17),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: _buildVideoPlayer(),
          ),
          const SizedBox(height: 12),
          if (controller != null && controller.value.isInitialized)
            ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(value.position),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _formatDuration(value.duration),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                );
              },
            ),
          const SizedBox(height: 20),
          const Text(
            'এই ভিডিওতে কী শিখবেন?',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 9),
          Text(
            'HSK 1 পর্যায়ের Chinese dialogues শুনে দৈনন্দিন কথোপকথন, '
            'সাধারণ বাক্য এবং Mandarin listening দক্ষতা অনুশীলন করুন। '
            'ভিডিওটি মনোযোগ দিয়ে দেখুন এবং শোনা বাক্যগুলো নিজে বলার চেষ্টা করুন।',
            style: TextStyle(
              height: 1.65,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              _buildFeature(
                icon: Icons.headphones_rounded,
                title: 'Listening',
                subtitle: 'শুনে বুঝুন',
              ),
              const SizedBox(width: 10),
              _buildFeature(
                icon: Icons.record_voice_over_rounded,
                title: 'Speaking',
                subtitle: 'উচ্চারণ করুন',
              ),
              const SizedBox(width: 10),
              _buildFeature(
                icon: Icons.school_rounded,
                title: 'HSK 1',
                subtitle: 'Beginner level',
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: _gold.withValues(alpha: 0.35)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: _gold),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'শেখার টিপস: ভিডিওটি প্রথমে মনোযোগ দিয়ে শুনুন। '
                    'দ্বিতীয়বার শুনে বাক্যগুলো থামিয়ে থামিয়ে নিজে বলুন।',
                    style: TextStyle(height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: _retryVideo,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('ভিডিও পুনরায় লোড করুন'),
          ),
        ],
      ),
    );
  }
}
