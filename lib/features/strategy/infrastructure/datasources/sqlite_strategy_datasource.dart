import 'package:sqflite/sqflite.dart';

import '../../domain/entities/strategy.dart';

class SqliteStrategyDataSource {
  final Database db;

  SqliteStrategyDataSource(this.db);

  Future<List<Strategy>> getStrategies() async {
    final rows = await db.query('strategies', orderBy: 'created_at DESC');
    return rows.map(_rowToStrategy).toList();
  }

  Future<Strategy> upsertStrategy(Strategy strategy) async {
    await db.insert(
      'strategies',
      _strategyToRow(strategy),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return strategy;
  }

  Future<void> deleteStrategy(String id) async {
    await db.delete('strategies', where: 'id = ?', whereArgs: [id]);
  }

  Map<String, dynamic> _strategyToRow(Strategy s) => {
        'id': s.id,
        'name': s.name,
        'description': s.description,
        'entry_condition_type': s.entryCondition.type.name,
        'entry_condition_value': s.entryCondition.value,
        'take_profit_type': s.takeProfitCondition.type.name,
        'take_profit_value': s.takeProfitCondition.value,
        'stop_loss_type': s.stopLossCondition.type.name,
        'stop_loss_value': s.stopLossCondition.value,
        'initial_capital': s.initialCapital,
        'position_size_percent': s.positionSizePercent,
        'created_at': s.createdAt.toIso8601String(),
      };

  Strategy _rowToStrategy(Map<String, dynamic> row) => Strategy(
        id: row['id'] as String,
        name: row['name'] as String,
        description: row['description'] as String,
        entryCondition: EntryCondition(
          type: ConditionType.values.byName(row['entry_condition_type'] as String),
          value: row['entry_condition_value'] as double,
        ),
        takeProfitCondition: ExitCondition(
          type: ExitType.values.byName(row['take_profit_type'] as String),
          value: row['take_profit_value'] as double,
        ),
        stopLossCondition: ExitCondition(
          type: ExitType.values.byName(row['stop_loss_type'] as String),
          value: row['stop_loss_value'] as double,
        ),
        initialCapital: row['initial_capital'] as double,
        positionSizePercent: row['position_size_percent'] as double,
        createdAt: DateTime.parse(row['created_at'] as String),
      );
}
