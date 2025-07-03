
class Stock {
  final String ticker;
  final double price;
  final bool isAnomalous;

  Stock({
    required this.ticker,
    required this.price,
    this.isAnomalous = false,
  });

  Stock copyWith({
    String? ticker,
    double? price,
    bool? isAnomalous,
  }) {
    return Stock(
      ticker: ticker ?? this.ticker,
      price: price ?? this.price,
      isAnomalous: isAnomalous ?? this.isAnomalous,
    );
  }

  @override
  String toString() {
    return 'Stock(ticker: $ticker, price: $price, isAnomalous: $isAnomalous)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Stock &&
        other.ticker == ticker &&
        other.price == price &&
        other.isAnomalous == isAnomalous;
  }

  @override
  int get hashCode => Object.hash(ticker, price, isAnomalous);
}
