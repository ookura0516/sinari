import '../entities/instrument.dart';
import '../entities/price_bar.dart';

abstract class PriceDataRepository {
  Future<List<Instrument>> getInstruments();
  Future<Instrument> addInstrument(String symbol, String name, String type);
  Future<void> deleteInstrument(String id);
  Future<List<PriceBar>> getPriceBars(String instrumentId);
  Future<int> importPriceBars(String instrumentId, List<PriceBar> bars);
  Future<int> getPriceBarCount(String instrumentId);
}
