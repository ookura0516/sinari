import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/strategy.dart';
import '../../domain/repositories/strategy_repository.dart';
import '../../infrastructure/datasources/sqlite_strategy_datasource.dart';
import '../../infrastructure/repositories/strategy_repository_impl.dart';
import '../../../../shared/providers/database_provider.dart';

final strategyRepositoryProvider = Provider<StrategyRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return StrategyRepositoryImpl(SqliteStrategyDataSource(db));
});

class StrategyNotifier extends AsyncNotifier<List<Strategy>> {
  final _uuid = const Uuid();
  StrategyRepository get _repo => ref.read(strategyRepositoryProvider);

  @override
  Future<List<Strategy>> build() => _repo.getStrategies();

  Future<void> save({
    String? id,
    required String name,
    required String description,
    required EntryCondition entryCondition,
    required ExitCondition takeProfitCondition,
    required ExitCondition stopLossCondition,
    required double initialCapital,
    required double positionSizePercent,
  }) async {
    final strategy = Strategy(
      id: id ?? _uuid.v4(),
      name: name,
      description: description,
      entryCondition: entryCondition,
      takeProfitCondition: takeProfitCondition,
      stopLossCondition: stopLossCondition,
      initialCapital: initialCapital,
      positionSizePercent: positionSizePercent,
      createdAt: id != null ? (state.value ?? []).firstWhere((s) => s.id == id).createdAt : DateTime.now(),
    );
    await _repo.saveStrategy(strategy);
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    await _repo.deleteStrategy(id);
    ref.invalidateSelf();
  }
}

final strategyNotifierProvider =
    AsyncNotifierProvider<StrategyNotifier, List<Strategy>>(StrategyNotifier.new);
