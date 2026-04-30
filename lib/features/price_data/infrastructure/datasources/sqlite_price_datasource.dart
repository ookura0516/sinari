import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/instrument.dart';
import '../../domain/entities/price_bar.dart';

class SqlitePriceDataSource {
  final Database db;
  final _uuid = const Uuid();

  SqlitePriceDataSource(this.db);

  Future<List<Instrument>> getInstruments() async {
    final rows = await db.query('instruments', orderBy: 'created_at DESC');
    return rows.map(_rowToInstrument).toList();
  }

  Future<Instrument> insertInstrument(String symbol, String name, String type) async {
    final instrument = Instrument(
      id: _uuid.v4(),
      symbol: symbol,
      name: name,
      type: type,
      createdAt: DateTime.now(),
    );
    await db.insert('instruments', {
      'id': instrument.id,
      'symbol': instrument.symbol,
      'name': instrument.name,
      'type': instrument.type,
      'created_at': instrument.createdAt.toIso8601String(),
    });
    return instrument;
  }

  Future<void> deleteInstrument(String id) async {
    await db.transaction((txn) async {
      final results = await txn.query(
        'backtest_results',
        columns: ['id'],
        where: 'instrument_id = ?',
        whereArgs: [id],
      );
      for (final row in results) {
        await txn.delete('trades', where: 'backtest_result_id = ?', whereArgs: [row['id']]);
      }
      await txn.delete('backtest_results', where: 'instrument_id = ?', whereArgs: [id]);
      await txn.delete('price_bars', where: 'instrument_id = ?', whereArgs: [id]);
      await txn.delete('instruments', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<List<PriceBar>> getPriceBars(String instrumentId) async {
    final rows = await db.query(
      'price_bars',
      where: 'instrument_id = ?',
      whereArgs: [instrumentId],
      orderBy: 'date ASC',
    );
    return rows.map(_rowToPriceBar).toList();
  }

  Future<int> insertPriceBars(String instrumentId, List<PriceBar> bars) async {
    int inserted = 0;
    await db.transaction((txn) async {
      for (final bar in bars) {
        await txn.insert(
          'price_bars',
          {
            'id': _uuid.v4(),
            'instrument_id': instrumentId,
            'date': bar.date.toIso8601String(),
            'open': bar.open,
            'high': bar.high,
            'low': bar.low,
            'close': bar.close,
            'volume': bar.volume,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        inserted++;
      }
    });
    return inserted;
  }

  Future<int> getPriceBarCount(String instrumentId) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM price_bars WHERE instrument_id = ?',
      [instrumentId],
    );
    return result.first['count'] as int;
  }

  Instrument _rowToInstrument(Map<String, dynamic> row) => Instrument(
        id: row['id'] as String,
        symbol: row['symbol'] as String,
        name: row['name'] as String,
        type: row['type'] as String,
        createdAt: DateTime.parse(row['created_at'] as String),
      );

  PriceBar _rowToPriceBar(Map<String, dynamic> row) => PriceBar(
        id: row['id'] as String,
        instrumentId: row['instrument_id'] as String,
        date: DateTime.parse(row['date'] as String),
        open: row['open'] as double,
        high: row['high'] as double,
        low: row['low'] as double,
        close: row['close'] as double,
        volume: row['volume'] as double?,
      );
}
