class PriceBar {
  final String id;
  final String instrumentId;
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final double? volume;

  const PriceBar({
    required this.id,
    required this.instrumentId,
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.volume,
  });
}
