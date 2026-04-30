enum ConditionType { percentDrop, percentRise, crossAbove, crossBelow }

enum ExitType { percentGain, percentLoss, holdingDays }

class EntryCondition {
  final ConditionType type;
  final double value;

  const EntryCondition({required this.type, required this.value});
}

class ExitCondition {
  final ExitType type;
  final double value;

  const ExitCondition({required this.type, required this.value});
}

class Strategy {
  final String id;
  final String name;
  final String description;
  final EntryCondition entryCondition;
  final ExitCondition takeProfitCondition;
  final ExitCondition stopLossCondition;
  final double initialCapital;
  final double positionSizePercent;
  final DateTime createdAt;

  const Strategy({
    required this.id,
    required this.name,
    required this.description,
    required this.entryCondition,
    required this.takeProfitCondition,
    required this.stopLossCondition,
    required this.initialCapital,
    required this.positionSizePercent,
    required this.createdAt,
  });
}
