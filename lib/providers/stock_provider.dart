
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/stock_model.dart';

final stockNotifierProvider = StateNotifierProvider<StockNotifier, List<Stock>>(
      (ref) => StockNotifier(),
);

class StockNotifier extends StateNotifier<List<Stock>> {
  final Map<String, double> _lastValidPrices = {};
  final Map<String, DateTime> _lastUpdateTimes = {};
  bool _disposed = false;

  StockNotifier() : super([]);

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void updateStocks(List<dynamic> data) {
    if (_disposed) {
      return;
    }

    final List<Stock> updatedStocks = [];
    final now = DateTime.now();

    for (final entry in data) {
      if (entry is! Map<String, dynamic>) {
        continue;
      }

      final ticker = entry['ticker']?.toString();
      final priceString = entry['price']?.toString();

      if (ticker == null || ticker.isEmpty || priceString == null) {

        continue;
      }

      final newPrice = double.tryParse(priceString);
      if (newPrice == null || newPrice <= 0) {
        continue;
      }

      bool isAnomalous = false;
      double displayPrice = newPrice;

      // Anomaly Detection Logic
      if (_lastValidPrices.containsKey(ticker)) {
        final lastPrice = _lastValidPrices[ticker]!;
        final priceChangeRatio = newPrice / lastPrice;

        if (priceChangeRatio < 0.1 || priceChangeRatio > 10.0) {
          isAnomalous = true;
          displayPrice = lastPrice;
        }
      }

      if (!isAnomalous) {
        _lastValidPrices[ticker] = newPrice;
        _lastUpdateTimes[ticker] = now;
      }


      final existingStockIndex = state.indexWhere((s) => s.ticker == ticker);
      Stock newStock;

      if (existingStockIndex != -1) {
        final existingStock = state[existingStockIndex];
        if (existingStock.price != displayPrice || existingStock.isAnomalous != isAnomalous) {
          newStock = existingStock.copyWith(
            price: displayPrice,
            isAnomalous: isAnomalous,
          );
        } else {
          newStock = existingStock;
        }
      } else {
        newStock = Stock(
          ticker: ticker,
          price: displayPrice,
          isAnomalous: isAnomalous,
        );
      }

      updatedStocks.add(newStock);
    }

    if (!_disposed) {
      updatedStocks.sort((a, b) => a.ticker.compareTo(b.ticker));
      state = updatedStocks;
    }
  }

  // Method to reset anomaly flags after some time
  void clearOldAnomalies() {
    if (_disposed) return;

    final now = DateTime.now();
    final updatedStocks = state.map((stock) {
      if (stock.isAnomalous) {
        final lastUpdate = _lastUpdateTimes[stock.ticker];
        if (lastUpdate != null && now.difference(lastUpdate).inSeconds > 30) {
          return stock.copyWith(isAnomalous: false);
        }
      }
      return stock;
    }).toList();

    if (updatedStocks != state) {
      state = updatedStocks;
    }
  }
}
