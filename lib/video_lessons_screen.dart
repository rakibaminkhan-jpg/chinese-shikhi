import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:video_player/video_player.dart';

class VideoLesson {
  final String title;
  final String subtitle;
  final String videoId;
  final String category;
  final String description;

  // URL দিলে সার্ভার থেকে MP4 চলবে; খালি থাকলে YouTube fallback চলবে।
  final String videoUrl;
  final String thumbnailUrl;

  const VideoLesson({
    required this.title,
    required this.subtitle,
    required this.videoId,
    required this.category,
    this.description = '',
    this.videoUrl = '',
    this.thumbnailUrl = '',
  });
}

// যাচাই করা বর্তমান ভিডিওগুলো রাখা হয়েছে।
const List<VideoLesson> chineseVideoLessons = [
  VideoLesson(
    title: 'Chinese Beginner Course – Lesson 1',
    subtitle: 'Pinyin, Initials ও Finals শেখা শুরু করুন',
    videoId: 'T4IyhRiz3SQ',
    category: 'Beginner',
    description:
        'চীনা ভাষা শেখার শুরুতে Pinyin, Initials এবং Finals সম্পর্কে ধারণা নিন।',
  ),
  VideoLesson(
    title: 'Chinese Pinyin – Lesson 2',
    subtitle: 'Pinyin pronunciation অনুশীলন করুন',
    videoId: 'M3qaSl8OLw0',
    category: 'Pinyin',
    description: 'Pinyin উচ্চারণ ও চীনা শব্দের সঠিক ধ্বনি শোনার অনুশীলন করুন।',
  ),
];

/// ভিডিওর Favorite এবং Watched History স্থানীয়ভাবে সংরক্ষণ করে।
class VideoLessonStore {
  static const String _favoriteKey = 'video_favorites_v1';
  static const String _watchedKey = 'video_watched_v1';

  static Future<Set<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_favoriteKey) ?? []).toSet();
  }

  static Future<Set<String>> getWatched() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_watchedKey) ?? []).toSet();
  }

  static Future<void> toggleFavorite(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = (prefs.getStringList(_favoriteKey) ?? []).toSet();

    if (!ids.add(videoId)) {
      ids.remove(videoId);
    }

    await prefs.setStringList(_favoriteKey, ids.toList());
  }

  static Future<void> markWatched(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = (prefs.getStringList(_watchedKey) ?? []).toSet();
    ids.add(videoId);
    await prefs.setStringList(_watchedKey, ids.toList());
  }
}

class VideoLessonsHomeSection extends StatelessWidget {
  final VoidCallback onSeeAll;

  const VideoLessonsHomeSection({
    super.key,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ভিডিও একাডেমি',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'ভিডিও দেখে সহজে Mandarin শিখুন',
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onSeeAll,
              child: const Text(
                'সব ভিডিও দেখুন →',
                style: TextStyle(
                  color: Color(0xFFB8860B),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 205,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: chineseVideoLessons.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final lesson = chineseVideoLessons[index];
              return SizedBox(
                width: 245,
                child: _VideoLessonCard(
                  lesson: lesson,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoPlayerScreen(lesson: lesson),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _VideoLessonCard extends StatelessWidget {
  final VideoLesson lesson;
  final VoidCallback onTap;
  final bool isFavorite;
  final bool isWatched;
  final VoidCallback? onFavoriteTap;

  const _VideoLessonCard({
    required this.lesson,
    required this.onTap,
    this.isFavorite = false,
    this.isWatched = false,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    lesson.thumbnailUrl.trim().isNotEmpty
                        ? lesson.thumbnailUrl
                        : 'https://img.youtube.com/vi/${lesson.videoId}/hqdefault.jpg',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF351016),
                      child: const Icon(
                        Icons.ondemand_video_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD4AF37),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Color(0xFF351016),
                    size: 25,
                  ),
                ),
                if (isWatched)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'দেখা হয়েছে ✓',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (onFavoriteTap != null)
                  Positioned(
                    top: 3,
                    right: 3,
                    child: IconButton(
                      onPressed: onFavoriteTap,
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.white,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 8, 11, 3),
              child: Text(
                lesson.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 0, 11, 8),
              child: Text(
                lesson.category,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFFB8860B),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoLessonsScreen extends StatefulWidget {
  const VideoLessonsScreen({super.key});

  @override
  State<VideoLessonsScreen> createState() => _VideoLessonsScreenState();
}

class _VideoLessonsScreenState extends State<VideoLessonsScreen> {
  static const categories = [
    'সব',
    'Beginner',
    'Pinyin',
    'HSK 1',
    'HSK 2',
    'HSK 3',
    'HSK 4',
    'প্রিয়',
    'দেখা হয়েছে',
  ];

  String selectedCategory = 'সব';
  String searchQuery = '';
  Set<String> favorites = {};
  Set<String> watched = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final savedFavorites = await VideoLessonStore.getFavorites();
    final savedWatched = await VideoLessonStore.getWatched();

    if (!mounted) return;

    setState(() {
      favorites = savedFavorites;
      watched = savedWatched;
      isLoading = false;
    });
  }

  Future<void> _toggleFavorite(VideoLesson lesson) async {
    await VideoLessonStore.toggleFavorite(lesson.videoId);
    await _loadSavedData();
  }

  List<VideoLesson> get filteredLessons {
    return chineseVideoLessons.where((lesson) {
      final matchesCategory = switch (selectedCategory) {
        'সব' => true,
        'প্রিয়' => favorites.contains(lesson.videoId),
        'দেখা হয়েছে' => watched.contains(lesson.videoId),
        _ => lesson.category == selectedCategory,
      };

      final query = searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          lesson.title.toLowerCase().contains(query) ||
          lesson.subtitle.toLowerCase().contains(query) ||
          lesson.category.toLowerCase().contains(query) ||
          lesson.description.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final lessons = filteredLessons;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ভিডিও একাডেমি',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF351016),
                          Color(0xFF101010),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.school_rounded,
                          color: Color(0xFFD4AF37),
                          size: 38,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'আজই শেখা শুরু করুন!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${watched.length}টি দেখা • '
                                '${favorites.length}টি প্রিয়',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    onChanged: (value) {
                      setState(() => searchQuery = value);
                    },
                    decoration: InputDecoration(
                      hintText: 'ভিডিও খুঁজুন...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return ChoiceChip(
                        label: Text(category),
                        selected: selectedCategory == category,
                        selectedColor: const Color(0xFFD4AF37),
                        onSelected: (_) {
                          setState(() => selectedCategory = category);
                        },
                      );
                    },
                  ),
                ),
                Expanded(
                  child: lessons.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.video_library_outlined,
                                  size: 55,
                                  color: Color(0xFFB8860B),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'এই ক্যাটাগরিতে ভিডিও পাওয়া যায়নি।',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  selectedCategory.startsWith('HSK')
                                      ? 'এই লেভেলের ভিডিও শীঘ্রই যোগ করা হবে।'
                                      : 'অন্য ক্যাটাগরি বা শব্দ দিয়ে খুঁজুন।',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: lessons.length,
                          itemBuilder: (context, index) {
                            final lesson = lessons[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _VideoLessonCard(
                                lesson: lesson,
                                isFavorite: favorites.contains(lesson.videoId),
                                isWatched: watched.contains(lesson.videoId),
                                onFavoriteTap: () => _toggleFavorite(lesson),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          VideoPlayerScreen(lesson: lesson),
                                    ),
                                  );
                                  if (mounted) _loadSavedData();
                                },
                              ),
                            );
                          },
                        ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: Text(
                    'ভিডিও YouTube থেকে ইন্টারনেটের মাধ্যমে চালানো হয়।',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final VideoLesson lesson;

  const VideoPlayerScreen({
    super.key,
    required this.lesson,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  YoutubePlayerController? youtubeController;
  VideoPlayerController? mp4Controller;

  bool mp4Ready = false;
  bool isFavorite = false;
  bool isWatched = false;
  String? mp4Error;

  bool get usesMp4 => widget.lesson.videoUrl.trim().isNotEmpty;

  int get currentIndex => chineseVideoLessons.indexWhere(
        (lesson) => lesson.videoId == widget.lesson.videoId,
      );

  @override
  void initState() {
    super.initState();

    if (usesMp4) {
      _initializeMp4();
    } else {
      youtubeController = YoutubePlayerController.fromVideoId(
        videoId: widget.lesson.videoId,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          enableCaption: true,
          interfaceLanguage: 'en',
          privacyEnhancedMode: true,
        ),
      );
    }

    _loadStatus();
  }

  Future<void> _initializeMp4() async {
    final url = widget.lesson.videoUrl.trim();
    final uri = Uri.tryParse(url);

    if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
      if (!mounted) return;
      setState(() {
        mp4Error = 'ভিডিও URL সঠিক নয়। HTTPS MP4 URL ব্যবহার করুন।';
      });
      return;
    }

    final videoController = VideoPlayerController.networkUrl(uri);
    mp4Controller = videoController;

    try {
      await videoController.initialize();

      if (!mounted) return;

      setState(() {
        mp4Ready = true;
        mp4Error = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        mp4Ready = false;
        mp4Error =
            'ভিডিও লোড করা যায়নি। ইন্টারনেট বা ভিডিও সার্ভার পরীক্ষা করুন।';
      });
    }
  }

  Future<void> _retryMp4() async {
    final oldController = mp4Controller;
    mp4Controller = null;

    await oldController?.dispose();

    if (!mounted) return;

    setState(() {
      mp4Ready = false;
      mp4Error = null;
    });

    await _initializeMp4();
  }

  Widget _buildMp4Player() {
    final videoController = mp4Controller;

    if (videoController == null || !mp4Ready) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(20),
          child: mp4Error != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      mp4Error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _retryMp4,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('আবার চেষ্টা করুন'),
                    ),
                  ],
                )
              : const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFD4AF37)),
                    SizedBox(height: 12),
                    Text(
                      'সার্ভার থেকে ভিডিও লোড হচ্ছে...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: videoController.value.aspectRatio > 0
          ? videoController.value.aspectRatio
          : 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: VideoPlayer(videoController),
            ),
            IconButton.filled(
              onPressed: () async {
                if (videoController.value.isPlaying) {
                  await videoController.pause();
                } else {
                  await videoController.play();
                }

                if (mounted) setState(() {});
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
              ),
              iconSize: 38,
              icon: Icon(
                videoController.value.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 8,
              child: VideoProgressIndicator(
                videoController,
                allowScrubbing: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                colors: const VideoProgressColors(
                  playedColor: Color(0xFFD4AF37),
                  bufferedColor: Colors.white54,
                  backgroundColor: Colors.white24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadStatus() async {
    final favorites = await VideoLessonStore.getFavorites();
    final watched = await VideoLessonStore.getWatched();

    if (!mounted) return;

    setState(() {
      isFavorite = favorites.contains(widget.lesson.videoId);
      isWatched = watched.contains(widget.lesson.videoId);
    });
  }

  Future<void> _toggleFavorite() async {
    await VideoLessonStore.toggleFavorite(widget.lesson.videoId);
    await _loadStatus();
  }

  Future<void> _markWatched() async {
    await VideoLessonStore.markWatched(widget.lesson.videoId);
    await _loadStatus();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ভিডিওটি দেখা হয়েছে হিসেবে সংরক্ষণ করা হয়েছে।'),
      ),
    );
  }

  void _openLesson(int index) {
    if (index < 0 || index >= chineseVideoLessons.length) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          lesson: chineseVideoLessons[index],
        ),
      ),
    );
  }

  @override
  void dispose() {
    youtubeController?.close();
    mp4Controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasPrevious = currentIndex > 0;
    final hasNext =
        currentIndex >= 0 && currentIndex < chineseVideoLessons.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ভিডিও ক্লাস',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'প্রিয় ভিডিও',
            onPressed: _toggleFavorite,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: usesMp4
                ? _buildMp4Player()
                : YoutubePlayer(
                    controller: youtubeController!,
                    aspectRatio: 16 / 9,
                  ),
          ),
          const SizedBox(height: 18),
          Text(
            widget.lesson.title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            widget.lesson.subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.lesson.description,
            style: const TextStyle(fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Color(0xFFB8860B),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'ভিডিও দেখার সময় Pinyin ও Chinese pronunciation মনোযোগ দিয়ে শুনুন।',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: isWatched ? null : _markWatched,
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: Text(
              isWatched ? 'দেখা হয়েছে ✓' : 'ভিডিওটি দেখা শেষ করেছি',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      hasPrevious ? () => _openLesson(currentIndex - 1) : null,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('আগের ভিডিও'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      hasNext ? () => _openLesson(currentIndex + 1) : null,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('পরের ভিডিও'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
