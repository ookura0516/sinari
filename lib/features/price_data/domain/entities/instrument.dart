class Instrument {
  final String id;
  final String symbol;
  final String name;
  final String type;
  final DateTime createdAt;

  const Instrument({
    required this.id,
    required this.symbol,
    required this.name,
    required this.type,
    required this.createdAt,
  });
}
