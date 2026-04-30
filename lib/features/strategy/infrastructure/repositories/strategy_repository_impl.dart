import '../../domain/entities/strategy.dart';
import '../../domain/repositories/strategy_repository.dart';
import '../datasources/sqlite_strategy_datasource.dart';

class StrategyRepositoryImpl implements StrategyRepository {
  final SqliteStrategyDataSource _dataSource;

  StrategyRepositoryImpl(this._dataSource);

  @override
  Future<List<Strategy>> getStrategies() => _dataSource.getStrategies();

  @override
  Future<Strategy> saveStrategy(Strategy strategy) => _dataSource.upsertStrategy(strategy);

  @override
  Future<void> deleteStrategy(String id) => _dataSource.deleteStrategy(id);
}
