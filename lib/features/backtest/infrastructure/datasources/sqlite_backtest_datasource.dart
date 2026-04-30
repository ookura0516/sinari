import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/backtest_result.dart';
import '../../domain/entities/trade.dart';

class SqliteBacktestDataSource {
  final Database db;
  final _uuid = const Uuid();

  SqliteBacktestDataSource(this.db);

  Future<List<BacktestResult>> getBacktestResults() async {
    final rows = await db.query('backtest_results', orderBy: 'created_at DESC');
    final results = <BacktestResult>[];
    for (final row in rows) {
      final trades = await _getTradesForResult(row['id'] as String);
      results.add(_rowToResult(row, trades));
    }
    return results;
  }

  Future<BacktestResult?> getBacktestResultById(String id) async {
    final rows = await db.query('backtest_results', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    final trades = await _getTradesForResult(id);
    return _rowToResult(rows.first, trades);
  }

  Future<BacktestResult> saveBacktestResult(BacktestResult result) async {
    await db.transaction((txn) async {
      await txn.insert(
        'backtest_results',
        {
          'id': result.id,
          'strategy_id': result.strategyId,
          'instrument_id': result.instrumentId,
          'start_date': result.startDate.toIso8601String(),
          'end_date': result.endDate.toIso8601String(),
          'initial_capital': result.initialCapital,
          'final_capital': result.finalCapital,
          'total_profit_loss': result.totalProfitLoss,
          'total_return': result.totalReturn,
          'total_trades': result.totalTrades,
          'winning_trades': result.winningTrades,
          'win_rate': result.winRate,
          'max_drawdown': result.maxDrawdown,
          'equity_curve': jsonEncode(result.equityCurve),
          'created_at': result.createdAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      for (final trade in result.trades) {
        await txn.insert(
          'trades',
          {
            'id': trade.id.isEmpty ? _uuid.v4() : trade.id,
            'backtest_result_id': result.id,
            'entry_date': trade.entryDate.toIso8601String(),
            'entry_price': trade.entryPrice,
            'exit_date': trade.exitDate?.toIso8601String(),
            'exit_price': trade.exitPrice,
            'quantity': trade.quantity,
            'profit_loss': trade.profitLoss,
            'profit_loss_percent': trade.profitLossPercent,
            'result': trade.result?.name,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
    return result;
  }

  Future<void> deleteBacktestResult(String id) async {
    await db.transaction((txn) async {
      await txn.delete('trades', where: 'backtest_result_id = ?', whereArgs: [id]);
      await txn.delete('backtest_results', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<List<Trade>> _getTradesForResult(String backtestResultId) async {
    final rows = await db.query(
      'trades',
      where: 'backtest_result_id = ?',
      whereArgs: [backtestResultId],
      orderBy: 'entry_date ASC',
    );
    return rows.map((r) => _rowToTrade(r)).toList();
  }

  BacktestResult _rowToResult(Map<String, dynamic> row, List<Trade> trades) {
    final curveJson = row['equity_curve'] as String;
    final curveList = (jsonDecode(curveJson) as List).map((e) => (e as num).toDouble()).toList();
    return BacktestResult(
      id: row['id'] as String,
      strategyId: row['strategy_id'] as String,
      instrumentId: row['instrument_id'] as String,
      startDate: DateTime.parse(row['start_date'] as String),
      endDate: DateTime.parse(row['end_date'] as String),
      initialCapital: row['initial_capital'] as double,
      finalCapital: row['final_capital'] as double,
      totalProfitLoss: row['total_profit_loss'] as double,
      totalReturn: row['total_return'] as double,
      totalTrades: row['total_trades'] as int,
      winningTrades: row['winning_trades'] as int,
      winRate: row['win_rate'] as double,
      maxDrawdown: row['max_drawdown'] as double,
      trades: trades,
      equityCurve: curveList,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  Trade _rowToTrade(Map<String, dynamic> row) => Trade(
        id: row['id'] as String,
        backtestResultId: row['backtest_result_id'] as String,
        entryDate: DateTime.parse(row['entry_date'] as String),
        entryPrice: row['entry_price'] as double,
        exitDate: row['exit_date'] != null ? DateTime.parse(row['exit_date'] as String) : null,
        exitPrice: row['exit_price'] as double?,
        quantity: row['quantity'] as double,
        profitLoss: row['profit_loss'] as double?,
        profitLossPercent: row['profit_loss_percent'] as double?,
        result: row['result'] != null ? TradeResult.values.byName(row['result'] as String) : null,
      );
}
