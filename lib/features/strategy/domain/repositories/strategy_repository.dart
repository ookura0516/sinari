import '../entities/strategy.dart';

abstract class StrategyRepository {
  Future<List<Strategy>> getStrategies();
  Future<Strategy> saveStrategy(Strategy strategy);
  Future<void> deleteStrategy(String id);
}
