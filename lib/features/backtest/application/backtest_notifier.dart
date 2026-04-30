import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/backtest_result.dart';
import '../../domain/engine/backtest_engine.dart';
import '../../domain/repositories/backtest_repository.dart';
import '../../infrastructure/datasources/sqlite_backtest_datasource.dart';
import '../../infrastructure/repositories/backtest_repository_impl.dart';
import '../../../price_data/application/price_data_notifier.dart';
import '../../../strategy/domain/entities/strategy.dart';
import '../../../../shared/providers/database_provider.dart';

final backtestRepositoryProvider = Provider<BacktestRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return BacktestRepositoryImpl(SqliteBacktestDataSource(db));
});

class BacktestNotifier extends AsyncNotifier<List<BacktestResult>> {
  final _uuid = const Uuid();
  final _engine = BacktestEngine();

  BacktestRepository get _repo => ref.read(backtestRepositoryProvider);

  @override
  Future<List<BacktestResult>> build() => _repo.getBacktestResults();

  Future<BacktestResult> runBacktest({
    required Strategy strategy,
    required String instrumentId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final bars = await ref.read(priceDataNotifierProvider.notifier).getPriceBars(instrumentId);
    final resultId = _uuid.v4();
    final result = _engine.run(
      resultId: resultId,
      strategy: strategy,
      instrumentId: instrumentId,
      bars: bars,
      startDate: startDate,
      endDate: endDate,
    );
    await _repo.saveBacktestResult(result);
    ref.invalidateSelf();
    return result;
  }

  Future<void> delete(String id) async {
    await _repo.deleteBacktestResult(id);
    ref.invalidateSelf();
  }
}

final backtestNotifierProvider =
    AsyncNotifierProvider<BacktestNotifier, List<BacktestResult>>(BacktestNotifier.new);
