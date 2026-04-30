import '../../domain/entities/instrument.dart';
import '../../domain/entities/price_bar.dart';
import '../../domain/repositories/price_data_repository.dart';
import '../datasources/sqlite_price_datasource.dart';

class PriceDataRepositoryImpl implements PriceDataRepository {
  final SqlitePriceDataSource _dataSource;

  PriceDataRepositoryImpl(this._dataSource);

  @override
  Future<List<Instrument>> getInstruments() => _dataSource.getInstruments();

  @override
  Future<Instrument> addInstrument(String symbol, String name, String type) =>
      _dataSource.insertInstrument(symbol, name, type);

  @override
  Future<void> deleteInstrument(String id) => _dataSource.deleteInstrument(id);

  @override
  Future<List<PriceBar>> getPriceBars(String instrumentId) =>
      _dataSource.getPriceBars(instrumentId);

  @override
  Future<int> importPriceBars(String instrumentId, List<PriceBar> bars) =>
      _dataSource.insertPriceBars(instrumentId, bars);

  @override
  Future<int> getPriceBarCount(String instrumentId) =>
      _dataSource.getPriceBarCount(instrumentId);
}
