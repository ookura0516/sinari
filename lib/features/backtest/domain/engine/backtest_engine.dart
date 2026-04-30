import 'package:uuid/uuid.dart';

import '../../domain/entities/backtest_result.dart';
import '../../domain/entities/trade.dart';
import '../../../price_data/domain/entities/price_bar.dart';
import '../../../strategy/domain/entities/strategy.dart';

class BacktestEngine {
  final _uuid = const Uuid();

  BacktestResult run({
    required String resultId,
    required Strategy strategy,
    required String instrumentId,
    required List<PriceBar> bars,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final filtered = bars
        .where((b) => !b.date.isBefore(startDate) && !b.date.isAfter(endDate))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    double capital = strategy.initialCapital;
    final equityCurve = <double>[capital];
    final trades = <Trade>[];

    bool inPosition = false;
    double entryPrice = 0;
    DateTime entryDate = startDate;
    double quantity = 0;

    for (int i = 1; i < filtered.length; i++) {
      final bar = filtered[i];
      final prev = filtered[i - 1];

      if (inPosition) {
        bool shouldExit = false;
        double exitPrice = bar.close;

        final tp = strategy.takeProfitCondition;
        final sl = strategy.stopLossCondition;

        if (tp.type == ExitType.percentGain) {
          if ((bar.close - entryPrice) / entryPrice * 100 >= tp.value) {
            shouldExit = true;
            exitPrice = entryPrice * (1 + tp.value / 100);
          }
        } else if (tp.type == ExitType.holdingDays) {
          if (bar.date.difference(entryDate).inDays >= tp.value) {
            shouldExit = true;
          }
        }

        if (!shouldExit) {
          if (sl.type == ExitType.percentLoss) {
            if ((entryPrice - bar.close) / entryPrice * 100 >= sl.value) {
              shouldExit = true;
              exitPrice = entryPrice * (1 - sl.value / 100);
            }
          } else if (sl.type == ExitType.holdingDays) {
            if (bar.date.difference(entryDate).inDays >= sl.value) {
              shouldExit = true;
            }
          }
        }

        if (shouldExit) {
          final pl = (exitPrice - entryPrice) * quantity;
          final plPct = (exitPrice - entryPrice) / entryPrice * 100;
          capital += pl;
          final tradeResult = pl > 0
              ? TradeResult.win
              : pl < 0
                  ? TradeResult.loss
                  : TradeResult.breakeven;

          trades.add(Trade(
            id: _uuid.v4(),
            backtestResultId: resultId,
            entryDate: entryDate,
            entryPrice: entryPrice,
            exitDate: bar.date,
            exitPrice: exitPrice,
            quantity: quantity,
            profitLoss: pl,
            profitLossPercent: plPct,
            result: tradeResult,
          ));
          equityCurve.add(capital);
          inPosition = false;
        }
      } else {
        final entry = strategy.entryCondition;
        bool shouldEnter = false;

        switch (entry.type) {
          case ConditionType.percentDrop:
            shouldEnter =
                (prev.close - bar.close) / prev.close * 100 >= entry.value;
          case ConditionType.percentRise:
            shouldEnter =
                (bar.close - prev.close) / prev.close * 100 >= entry.value;
          case ConditionType.crossAbove:
            shouldEnter = bar.close > entry.value;
          case ConditionType.crossBelow:
            shouldEnter = bar.close < entry.value;
        }

        if (shouldEnter && capital > 0) {
          final allocation = capital * strategy.positionSizePercent / 100;
          entryPrice = bar.close;
          entryDate = bar.date;
          quantity = allocation / entryPrice;
          inPosition = true;
        }
      }
    }

    // Close any open position at last bar
    if (inPosition && filtered.isNotEmpty) {
      final lastBar = filtered.last;
      final pl = (lastBar.close - entryPrice) * quantity;
      final plPct = (lastBar.close - entryPrice) / entryPrice * 100;
      capital += pl;
      trades.add(Trade(
        id: _uuid.v4(),
        backtestResultId: resultId,
        entryDate: entryDate,
        entryPrice: entryPrice,
        exitDate: lastBar.date,
        exitPrice: lastBar.close,
        quantity: quantity,
        profitLoss: pl,
        profitLossPercent: plPct,
        result: pl > 0
            ? TradeResult.win
            : pl < 0
                ? TradeResult.loss
                : TradeResult.breakeven,
      ));
      equityCurve.add(capital);
    }

    final winningTrades = trades.where((t) => t.result == TradeResult.win).length;
    final totalTrades = trades.length;
    final winRate = totalTrades > 0 ? winningTrades / totalTrades * 100 : 0.0;
    final totalPL = capital - strategy.initialCapital;
    final totalReturn = totalPL / strategy.initialCapital * 100;
    final maxDrawdown = _calcMaxDrawdown(equityCurve);

    return BacktestResult(
      id: resultId,
      strategyId: strategy.id,
      instrumentId: instrumentId,
      startDate: startDate,
      endDate: endDate,
      initialCapital: strategy.initialCapital,
      finalCapital: capital,
      totalProfitLoss: totalPL,
      totalReturn: totalReturn,
      totalTrades: totalTrades,
      winningTrades: winningTrades,
      winRate: winRate,
      maxDrawdown: maxDrawdown,
      trades: trades,
      equityCurve: equityCurve,
      createdAt: DateTime.now(),
    );
  }

  double _calcMaxDrawdown(List<double> curve) {
    if (curve.length < 2) return 0;
    double peak = curve[0];
    double maxDD = 0;
    for (final v in curve) {
      if (v > peak) peak = v;
      final dd = (peak - v) / peak * 100;
      if (dd > maxDD) maxDD = dd;
    }
    return maxDD;
  }
}
