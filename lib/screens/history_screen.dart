import 'package:flutter/material.dart';
import '../models/game_state.dart';

/// 行動履歴画面
class HistoryScreen extends StatelessWidget {
  final List<HistoryEntry> history;

  const HistoryScreen({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0520),
        elevation: 0,
        title: const Text(
          '行動履歴',
          style: TextStyle(
            color: Color(0xFF8B7D6B),
            fontSize: 16,
            letterSpacing: 3,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF6A5A4A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: Color(0xFF2A1040), height: 1),
        ),
      ),
      body: history.isEmpty
          ? const Center(
              child: Text(
                'まだ行動がありません',
                style: TextStyle(color: Color(0xFF4A3A2A), fontSize: 14),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              itemCount: history.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: Color(0xFF1A0A2E), height: 1),
              itemBuilder: (context, index) {
                final entry = history[index];
                return _HistoryTile(
                  index: index + 1,
                  entry: entry,
                );
              },
            ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final int index;
  final HistoryEntry entry;

  const _HistoryTile({required this.index, required this.entry});

  @override
  Widget build(BuildContext context) {
    final sanColor = entry.sanAtTime > 50
        ? const Color(0xFF4FC3F7)
        : entry.sanAtTime >= 30
            ? const Color(0xFFFF9800)
            : const Color(0xFFE53935);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 番号
          SizedBox(
            width: 28,
            child: Text(
              '$index',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF3A2A1A),
              ),
            ),
          ),

          // テキスト
          Expanded(
            child: Text(
              entry.text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFA09080),
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // SAN / 因果 の当時の値
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'SAN ${entry.sanAtTime}',
                style: TextStyle(
                  fontSize: 10,
                  color: sanColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '因果 ${entry.karmaAtTime}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF6A5A3A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
