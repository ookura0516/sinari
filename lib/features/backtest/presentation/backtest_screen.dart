import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../application/backtest_notifier.dart';
import '../domain/entities/backtest_result.dart';
import '../../price_data/application/price_data_notifier.dart';
import '../../strategy/application/strategy_notifier.dart';
import '../../strategy/domain/entities/strategy.dart';
import 'backtest_result_screen.dart';
import '../../../../core/utils/number_formatter.dart';

class BacktestScreen extends ConsumerStatefulWidget {
  const BacktestScreen({super.key});

  @override
  ConsumerState<BacktestScreen> createState() => _BacktestScreenState();
}

class _BacktestScreenState extends ConsumerState<BacktestScreen> {
  String? _selectedInstrumentId;
  String? _selectedStrategyId;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 365));
  DateTime _endDate = DateTime.now();
  bool _running = false;

  Future<void> _pickDate(bool isStart) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _runBacktest(Strategy strategy) async {
    if (_selectedInstrumentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('銘柄を選択してください')));
      return;
    }

    setState(() => _running = true);
    try {
      final result = await ref.read(backtestNotifierProvider.notifier).runBacktest(
            strategy: strategy,
            instrumentId: _selectedInstrumentId!,
            startDate: _startDate,
            endDate: _endDate,
          );
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BacktestResultScreen(result: result)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('エラー: $e')));
      }
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final priceState = ref.watch(priceDataNotifierProvider);
    final strategiesAsync = ref.watch(strategyNotifierProvider);
    final backtestsAsync = ref.watch(backtestNotifierProvider);
    final dateFmt = DateFormat('yyyy/MM/dd');

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Configuration card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              children: [
                Text('バックテスト設定', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),

                // Instrument selector
                priceState.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                  data: (state) => DropdownButtonFormField<String>(
                    value: _selectedInstrumentId,
                    decoration: const InputDecoration(
                      labelText: '銘柄',
                      border: OutlineInputBorder(),
                    ),
                    items: state.instruments
                        .map((i) => DropdownMenuItem(
                            value: i.id, child: Text('${i.symbol} - ${i.name}')))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedInstrumentId = v),
                    hint: const Text('銘柄を選択'),
                  ),
                ),
                const SizedBox(height: 12),

                // Strategy selector
                strategiesAsync.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                  data: (strategies) => DropdownButtonFormField<String>(
                    value: _selectedStrategyId,
                    decoration: const InputDecoration(
                      labelText: '戦略',
                      border: OutlineInputBorder(),
                    ),
                    items: strategies
                        .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedStrategyId = v),
                    hint: const Text('戦略を選択'),
                  ),
                ),
                const SizedBox(height: 12),

                // Date range
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text('開始: ${dateFmt.format(_startDate)}'),
                      onPressed: () => _pickDate(true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text('終了: ${dateFmt.format(_endDate)}'),
                      onPressed: () => _pickDate(false),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),

                // Run button
                strategiesAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (strategies) {
                    final selectedStrategy = _selectedStrategyId != null
                        ? strategies.where((s) => s.id == _selectedStrategyId).firstOrNull
                        : null;
                    return SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: _running
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.play_arrow),
                        label: const Text('バックテスト実行'),
                        onPressed: (_running || selectedStrategy == null)
                            ? null
                            : () => _runBacktest(selectedStrategy),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Text('過去のバックテスト', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),

          // Past results
          backtestsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (results) => results.isEmpty
                ? const Center(child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('バックテスト結果がありません')))
                : Column(
                    children: results.map((r) => _buildResultCard(context, r, ref)).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, BacktestResult result, WidgetRef ref) {
    final priceState = ref.read(priceDataNotifierProvider).valueOrNull;
    final strategies = ref.read(strategyNotifierProvider).valueOrNull;

    final instrumentName = priceState?.instruments
        .where((i) => i.id == result.instrumentId)
        .firstOrNull
        ?.symbol ?? result.instrumentId;
    final strategyName = strategies
        ?.where((s) => s.id == result.strategyId)
        .firstOrNull
        ?.name ?? result.strategyId;

    final isPositive = result.totalReturn >= 0;
    final color = isPositive
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text('$instrumentName / $strategyName'),
        subtitle: Text(
            '${DateFormat('yyyy/MM/dd').format(result.createdAt)} · '
            '${result.totalTrades}取引 · 勝率${result.winRate.toStringAsFixed(1)}%'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              NumberFormatter.percent(result.totalReturn),
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(NumberFormatter.currency(result.totalProfitLoss),
                style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BacktestResultScreen(result: result)),
        ),
        onLongPress: () => _confirmDelete(context, ref, result.id),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('結果を削除'),
        content: const Text('このバックテスト結果を削除しますか？'),
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
      await ref.read(backtestNotifierProvider.notifier).delete(id);
    }
  }
}
