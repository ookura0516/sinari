import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/strategy_notifier.dart';
import 'widgets/strategy_list_tile.dart';
import 'strategy_form_screen.dart';

class StrategyListScreen extends ConsumerWidget {
  const StrategyListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStrategies = ref.watch(strategyNotifierProvider);

    return asyncStrategies.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (strategies) => Scaffold(
        body: strategies.isEmpty
            ? const Center(child: Text('戦略がありません。\n右下のボタンから追加してください。'))
            : ListView.separated(
                itemCount: strategies.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final strategy = strategies[index];
                  return StrategyListTile(
                    strategy: strategy,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StrategyFormScreen(strategy: strategy),
                      ),
                    ),
                    onDelete: () => _confirmDelete(context, ref, strategy.id, strategy.name),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StrategyFormScreen()),
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('戦略を削除'),
        content: Text('「$name」を削除しますか？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('キャンセル')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      try {
        await ref.read(strategyNotifierProvider.notifier).delete(id);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('エラー: $e')));
        }
      }
    }
  }
}
