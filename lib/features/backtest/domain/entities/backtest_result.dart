import 'trade.dart';

class BacktestResult {
  final String id;
  final String strategyId;
  final String instrumentId;
  final DateTime startDate;
  final DateTime endDate;
  final double initialCapital;
  final double finalCapital;
  final double totalProfitLoss;
  final double totalReturn;
  final int totalTrades;
  final int winningTrades;
  final double winRate;
  final double maxDrawdown;
  final List<Trade> trades;
  final List<double> equityCurve;
  final DateTime createdAt;

  const BacktestResult({
    required this.id,
    required this.strategyId,
    required this.instrumentId,
    required this.startDate,
    required this.endDate,
    required this.initialCapital,
    required this.finalCapital,
    required this.totalProfitLoss,
    required this.totalReturn,
    required this.totalTrades,
    required this.winningTrades,
    required this.winRate,
    required this.maxDrawdown,
    required this.trades,
    required this.equityCurve,
    required this.createdAt,
  });
}
