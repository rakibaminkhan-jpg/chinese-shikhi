
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HskVocabularyScreen extends StatefulWidget {
  const HskVocabularyScreen({super.key});

  @override
  State<HskVocabularyScreen> createState() =>
      _HskVocabularyScreenState();
}

class _HskVocabularyScreenState extends State<HskVocabularyScreen> {
  List<Map<String, dynamic>> allWords = [];
  List<Map<String, dynamic>> filteredWords = [];

  int selectedLevel = 1;
  bool isLoading = true;
  String searchText = '';

  final TextEditingController searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    loadVocabulary();
  }

  Future<void> loadVocabulary() async {
    try {
      final String data = await rootBundle.loadString(
        'assets/data/hsk_2025_vocab.json',
      );

      final decoded = jsonDecode(data);

      List<dynamic> words;

      if (decoded is List) {
        words = decoded;
      } else if (decoded is Map && decoded['words'] is List) {
        words = decoded['words'];
      } else {
        throw Exception('Invalid vocabulary JSON format');
      }

      allWords = words
          .map((word) => Map<String, dynamic>.from(word))
          .toList();

      filterWords();
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      debugPrint('Vocabulary loading error: $e');
    }
  }

  void filterWords() {
    final result = allWords.where((word) {
      final level = int.tryParse(
            word['hsk_level'].toString(),
          ) ??
          0;

      final matchesLevel = level == selectedLevel;

      final search = searchText.toLowerCase();

      final matchesSearch =
          word['word'].toString().toLowerCase().contains(search) ||
          word['pinyin'].toString().toLowerCase().contains(search) ||
          word['translation'].toString().toLowerCase().contains(search);

      return matchesLevel && matchesSearch;
    }).toList();

    setState(() {
      filteredWords = result;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void showWordDetails(Map<String, dynamic> word) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                word['word'].toString(),
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                word['pinyin'].toString(),
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                word['translation'].toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 12),
              Text(
                'Word Type: ${word['pos'] ?? 'Not available'}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('বন্ধ করুন'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final levelCounts = {
      for (int level = 1; level <= 4; level++)
        level: allWords.where(
          (word) =>
              int.tryParse(word['hsk_level'].toString()) == level,
        ).length,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('New HSK 1–4 শব্দভান্ডার'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(4, (index) {
                final level = index + 1;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            selectedLevel == level
                                ? Colors.red.shade700
                                : Colors.grey.shade200,
                        foregroundColor:
                            selectedLevel == level
                                ? Colors.white
                                : Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        setState(() {
                          selectedLevel = level;
                        });
                        filterWords();
                      },
                      child: Text('HSK $level'),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                searchText = value;
                filterWords();
              },
              decoration: InputDecoration(
                hintText: 'শব্দ, Pinyin অথবা অর্থ খুঁজুন...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'HSK $selectedLevel • ${levelCounts[selectedLevel] ?? 0} টি শব্দ • পাওয়া গেছে ${filteredWords.length} টি',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : filteredWords.isEmpty
                    ? const Center(
                        child: Text('কোনো শব্দ পাওয়া যায়নি'),
                      )
                    : ListView.builder(
                        itemCount: filteredWords.length,
                        itemBuilder: (context, index) {
                          final word = filteredWords[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            child: ListTile(
                              onTap: () => showWordDetails(word),
                              leading: CircleAvatar(
                                backgroundColor: Colors.red.shade50,
                                child: Text(
                                  '${word['number'] ?? index + 1}',
                                  style: const TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              title: Text(
                                word['word'].toString(),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${word['pinyin'] ?? ''}\n${word['translation'] ?? ''}',
                              ),
                              isThreeLine: true,
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

