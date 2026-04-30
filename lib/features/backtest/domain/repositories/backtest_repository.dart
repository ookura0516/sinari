import '../entities/backtest_result.dart';

abstract class BacktestRepository {
  Future<List<BacktestResult>> getBacktestResults();
  Future<BacktestResult> saveBacktestResult(BacktestResult result);
  Future<BacktestResult?> getBacktestResultById(String id);
  Future<void> deleteBacktestResult(String id);
}
