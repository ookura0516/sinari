import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../domain/entities/backtest_result.dart';
import 'widgets/equity_curve_chart.dart';
import 'widgets/trade_list_tile.dart';
import '../../../core/utils/number_formatter.dart';

class BacktestResultScreen extends StatelessWidget {
  static const routeName = '/backtest/result';

  final BacktestResult result;

  const BacktestResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('yyyy/MM/dd');
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('バックテスト結果'),
            Text(
              '${dateFmt.format(result.startDate)} 〜 ${dateFmt.format(result.endDate)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _summaryCard(context),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('エクイティカーブ', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 220,
                    child: EquityCurveChart(equityCurve: result.equityCurve),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('取引履歴 (${result.trades.length}件)',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...result.trades.asMap().entries.map(
                (e) => TradeListTile(trade: e.value, index: e.key),
              ),
        ],
      ),
    );
  }

  Widget _summaryCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        children: [
          Text('サマリー', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _statItem(
                context,
                'トータルリターン',
                NumberFormatter.percent(result.totalReturn),
                color: result.totalReturn >= 0 ? cs.primary : cs.error,
              ),
              _statItem(context, '勝率', '${result.winRate.toStringAsFixed(1)}%'),
              _statItem(context, '最大ドローダウン',
                  '-${result.maxDrawdown.toStringAsFixed(2)}%',
                  color: cs.error),
              _statItem(context, '総取引数', '${result.totalTrades}'),
              _statItem(context, '勝利数', '${result.winningTrades}'),
              _statItem(
                context,
                '損益',
                NumberFormatter.currency(result.totalProfitLoss),
                color: result.totalProfitLoss >= 0 ? cs.primary : cs.error,
              ),
              _statItem(
                  context, '最終資産', NumberFormatter.currency(result.finalCapital)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(BuildContext context, String label, String value, {Color? color}) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.outline)),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
