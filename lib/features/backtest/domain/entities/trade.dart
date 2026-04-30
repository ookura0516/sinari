enum TradeResult { win, loss, breakeven }

class Trade {
  final String id;
  final String backtestResultId;
  final DateTime entryDate;
  final double entryPrice;
  final DateTime? exitDate;
  final double? exitPrice;
  final double quantity;
  final double? profitLoss;
  final double? profitLossPercent;
  final TradeResult? result;

  const Trade({
    required this.id,
    required this.backtestResultId,
    required this.entryDate,
    required this.entryPrice,
    this.exitDate,
    this.exitPrice,
    required this.quantity,
    this.profitLoss,
    this.profitLossPercent,
    this.result,
  });
}
