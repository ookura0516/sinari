import 'package:flutter/material.dart';

import '../../features/backtest/domain/entities/backtest_result.dart';
import '../../features/backtest/presentation/backtest_result_screen.dart';
import '../../features/strategy/presentation/strategy_form_screen.dart';
import '../../features/strategy/domain/entities/strategy.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case BacktestResultScreen.routeName:
        final result = settings.arguments as BacktestResult;
        return MaterialPageRoute(
          builder: (_) => BacktestResultScreen(result: result),
        );
      case StrategyFormScreen.routeName:
        final strategy = settings.arguments as Strategy?;
        return MaterialPageRoute(
          builder: (_) => StrategyFormScreen(strategy: strategy),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
