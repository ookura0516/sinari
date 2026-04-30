import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/constants/app_constants.dart';

final databaseProvider = Provider<Database>((ref) => throw UnimplementedError());

class DatabaseHelper {
  static Future<Database> open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);
    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE instruments (
        id TEXT PRIMARY KEY,
        symbol TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE price_bars (
        id TEXT PRIMARY KEY,
        instrument_id TEXT NOT NULL,
        date TEXT NOT NULL,
        open REAL NOT NULL,
        high REAL NOT NULL,
        low REAL NOT NULL,
        close REAL NOT NULL,
        volume REAL,
        FOREIGN KEY (instrument_id) REFERENCES instruments(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE strategies (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        entry_condition_type TEXT NOT NULL,
        entry_condition_value REAL NOT NULL,
        take_profit_type TEXT NOT NULL,
        take_profit_value REAL NOT NULL,
        stop_loss_type TEXT NOT NULL,
        stop_loss_value REAL NOT NULL,
        initial_capital REAL NOT NULL,
        position_size_percent REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE backtest_results (
        id TEXT PRIMARY KEY,
        strategy_id TEXT NOT NULL,
        instrument_id TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        initial_capital REAL NOT NULL,
        final_capital REAL NOT NULL,
        total_profit_loss REAL NOT NULL,
        total_return REAL NOT NULL,
        total_trades INTEGER NOT NULL,
        winning_trades INTEGER NOT NULL,
        win_rate REAL NOT NULL,
        max_drawdown REAL NOT NULL,
        equity_curve TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE trades (
        id TEXT PRIMARY KEY,
        backtest_result_id TEXT NOT NULL,
        entry_date TEXT NOT NULL,
        entry_price REAL NOT NULL,
        exit_date TEXT,
        exit_price REAL,
        quantity REAL NOT NULL,
        profit_loss REAL,
        profit_loss_percent REAL,
        result TEXT,
        FOREIGN KEY (backtest_result_id) REFERENCES backtest_results(id)
      )
    ''');
  }
}
