import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/price_data_notifier.dart';
import '../../../core/constants/app_constants.dart';
import 'widgets/instrument_list_tile.dart';
import 'widgets/csv_import_dialog.dart';

class PriceDataScreen extends ConsumerWidget {
  const PriceDataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(priceDataNotifierProvider);

    return asyncState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (state) => Scaffold(
        body: state.instruments.isEmpty
            ? const Center(child: Text('銘柄がありません。\n右下のボタンから追加してください。'))
            : ListView.separated(
                itemCount: state.instruments.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final inst = state.instruments[index];
                  return InstrumentListTile(
                    instrument: inst,
                    barCount: state.barCounts[inst.id] ?? 0,
                    onTap: () => _showImportDialog(context, inst.id, inst.symbol),
                    onDelete: () => _confirmDelete(context, ref, inst.id, inst.symbol),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddDialog(context, ref),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final symbolCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    String selectedType = AppConstants.instrumentTypes.first;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('銘柄を追加'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: symbolCtrl,
                decoration: const InputDecoration(labelText: 'シンボル (例: AAPL)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: '名前 (例: Apple Inc.)'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'タイプ'),
                items: AppConstants.instrumentTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => selectedType = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('キャンセル')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('追加')),
          ],
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(priceDataNotifierProvider.notifier).addInstrument(
              symbolCtrl.text.trim(),
              nameCtrl.text.trim(),
              selectedType,
            );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('エラー: $e')));
        }
      }
    }
  }

  void _showImportDialog(BuildContext context, String instrumentId, String symbol) {
    showDialog(
      context: context,
      builder: (_) => CsvImportDialog(instrumentId: instrumentId, instrumentName: symbol),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, String id, String symbol) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('銘柄を削除'),
        content: Text('$symbol を削除しますか？関連する全データも削除されます。'),
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
        await ref.read(priceDataNotifierProvider.notifier).deleteInstrument(id);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('エラー: $e')));
        }
      }
    }
  }
}
