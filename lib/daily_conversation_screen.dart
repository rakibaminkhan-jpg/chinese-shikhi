import 'package:material_ui/material_ui.dart';

import 'daily_conversation_data.dart';
import 'daily_conversation_detail_screen.dart';

class DailyConversationScreen extends StatelessWidget {
  const DailyConversationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<int>>{};
    for (var i = 0; i < conversationTopics.length; i++) {
      grouped.putIfAbsent(conversationTopics[i].category, () => []).add(i);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Conversation')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('বাস্তব জীবনের Mandarin কথোপকথন',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  const Text('HSK 1–4 ভিত্তিক ২৫০টি কথোপকথনের পরিকল্পনা। '
                      'নতুন কনটেন্ট যোগ হওয়ার সঙ্গে সঙ্গে তালিকা বাড়বে।'),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: conversationTopics.length / 250,
                  ),
                  const SizedBox(height: 6),
                  Text('${conversationTopics.length} / 250টি তৈরি'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final entry in grouped.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 6),
              child: Text(entry.key,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            for (final index in entry.value)
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(conversationTopics[index].icon,
                        style: const TextStyle(fontSize: 20)),
                  ),
                  title: Text(conversationTopics[index].titleBn),
                  subtitle: Text(
                    '${conversationTopics[index].titleEn}\n'
                    'HSK ${conversationTopics[index].hskLevel} · '
                    '${conversationTopics[index].lines.length}টি সংলাপ',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DailyConversationDetailScreen(
                          topics: conversationTopics,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ],
      ),
    );
  }
}
