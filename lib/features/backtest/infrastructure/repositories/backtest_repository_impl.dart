import '../../domain/entities/backtest_result.dart';
import '../../domain/repositories/backtest_repository.dart';
import '../datasources/sqlite_backtest_datasource.dart';

class BacktestRepositoryImpl implements BacktestRepository {
  final SqliteBacktestDataSource _dataSource;

  BacktestRepositoryImpl(this._dataSource);

  @override
  Future<List<BacktestResult>> getBacktestResults() => _dataSource.getBacktestResults();

  @override
  Future<BacktestResult> saveBacktestResult(BacktestResult result) =>
      _dataSource.saveBacktestResult(result);

  @override
  Future<BacktestResult?> getBacktestResultById(String id) =>
      _dataSource.getBacktestResultById(id);

  @override
  Future<void> deleteBacktestResult(String id) => _dataSource.deleteBacktestResult(id);
}
