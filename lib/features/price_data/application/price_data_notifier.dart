import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/entities/instrument.dart';
import '../../domain/entities/price_bar.dart';
import '../../domain/repositories/price_data_repository.dart';
import '../../infrastructure/datasources/sqlite_price_datasource.dart';
import '../../infrastructure/repositories/price_data_repository_impl.dart';
import '../../../../shared/providers/database_provider.dart';

final priceDataRepositoryProvider = Provider<PriceDataRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return PriceDataRepositoryImpl(SqlitePriceDataSource(db));
});

class PriceDataState {
  final List<Instrument> instruments;
  final Map<String, int> barCounts;

  const PriceDataState({this.instruments = const [], this.barCounts = const {}});

  PriceDataState copyWith({List<Instrument>? instruments, Map<String, int>? barCounts}) =>
      PriceDataState(
        instruments: instruments ?? this.instruments,
        barCounts: barCounts ?? this.barCounts,
      );
}

class PriceDataNotifier extends AsyncNotifier<PriceDataState> {
  PriceDataRepository get _repo => ref.read(priceDataRepositoryProvider);

  @override
  Future<PriceDataState> build() async {
    final instruments = await _repo.getInstruments();
    final counts = <String, int>{};
    for (final inst in instruments) {
      counts[inst.id] = await _repo.getPriceBarCount(inst.id);
    }
    return PriceDataState(instruments: instruments, barCounts: counts);
  }

  Future<void> addInstrument(String symbol, String name, String type) async {
    await _repo.addInstrument(symbol, name, type);
    ref.invalidateSelf();
  }

  Future<void> deleteInstrument(String id) async {
    await _repo.deleteInstrument(id);
    ref.invalidateSelf();
  }

  Future<int> importCsv(String instrumentId, String csvContent) async {
    final rows = const CsvToListConverter(eol: '\n').convert(csvContent);
    if (rows.isEmpty) return 0;

    final header = rows.first.map((e) => e.toString().trim().toLowerCase()).toList();
    final dateIdx = header.indexOf('date');
    final openIdx = header.indexOf('open');
    final highIdx = header.indexOf('high');
    final lowIdx = header.indexOf('low');
    final closeIdx = header.indexOf('close');
    final volumeIdx = header.indexOf('volume');

    if ([dateIdx, openIdx, highIdx, lowIdx, closeIdx].any((i) => i == -1)) {
      throw const FormatException('CSV must have columns: date,open,high,low,close');
    }

    final bars = <PriceBar>[];
    for (final row in rows.skip(1)) {
      if (row.length <= closeIdx) continue;
      try {
        bars.add(PriceBar(
          id: '',
          instrumentId: instrumentId,
          date: DateTime.parse(row[dateIdx].toString().trim()),
          open: double.parse(row[openIdx].toString()),
          high: double.parse(row[highIdx].toString()),
          low: double.parse(row[lowIdx].toString()),
          close: double.parse(row[closeIdx].toString()),
          volume: volumeIdx != -1 && row.length > volumeIdx && row[volumeIdx] != null
              ? double.tryParse(row[volumeIdx].toString())
              : null,
        ));
      } catch (_) {
        // skip malformed rows
      }
    }

    final count = await _repo.importPriceBars(instrumentId, bars);
    ref.invalidateSelf();
    return count;
  }

  Future<List<PriceBar>> getPriceBars(String instrumentId) =>
      _repo.getPriceBars(instrumentId);
}

final priceDataNotifierProvider =
    AsyncNotifierProvider<PriceDataNotifier, PriceDataState>(PriceDataNotifier.new);
