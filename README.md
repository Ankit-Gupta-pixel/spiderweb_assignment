# spiderweb_assignment:  Unstable Ticker

A  Flutter application that consumes data from an 
unstable WebSocket feed and displays real-time stock prices 
with advanced error handling, anomaly detection, and network resilience.

How to Run the Application
1. Clone the repository
   git clone <your-repository-url>
   cd unstable-ticker
2. Install dependencies
    flutter pub get
3. Start the Mock WebSocket Server
   dart mock_server.dart
4. Run the Flutter application
    flutter run

Architectural Decisions :

State Management : Riverpod

Decision: Used hooks_riverpod for state management

Compile-time Safety: Unlike Provider, Riverpod catches errors at compile time
No BuildContext Dependency: Can be accessed anywhere without context
Better Testing: Easy to mock and test providers in isolation
Performance: Fine-grained reactivity prevents unnecessary rebuilds
Scalability: Excellent for complex state relationships

Project Structure
lib/
├── main.dart                 # App entry point
├── models/
│   └── stock_model.dart      # Data model with immutable Stock class
├── providers/
│   └── stock_provider.dart   # Business logic and state management
├── services/
│   └── websocket_service.dart # Network layer abstraction
├── screens/
│   └── home_screen.dart      # UI layer
└── widgets/
└── stock_tile.dart       # Reusable UI components

Separation of Concerns:

Models: Pure data classes with no business logic
Providers: Business logic, state management, and data transformation
Services: External API/WebSocket communication
Screens: UI coordination and lifecycle management
Widgets: Reusable UI components with local state only

Anomaly Detection Heuristic

// Detect anomalies: price drop > 90% or price increase > 10x
if (priceChangeRatio < 0.1 || priceChangeRatio > 10.0) {
isAnomalous = true;
displayPrice = lastPrice;
}

90% Price Drop Threshold: Stocks rarely lose 90% value in one second under normal circumstances
10x Price Increase Threshold: Similarly, stocks don't typically increase 1000% instantly

Performance Analysis:
Flutter DevTools Performance Overlay
location: asset/images.png

Performance Optimization :
1. Efficient Widget Rebuilds
   ListView.builder(
   // Using ValueKey to prevent unnecessary widget recreation
   ListView.builder(
   itemBuilder: (context, index) {
   return StockTile(
   key: ValueKey(stocks[index].ticker), // Prevents rebuild on reorder
   stock: stocks[index],
   );
   },
   )
2. Object Reuse in State Management
   // Only create new objects when data actually changes
   if (existingStock.price != displayPrice || existingStock.isAnomalous != isAnomalous) {
   newStock = existingStock.copyWith(price: displayPrice, isAnomalous: isAnomalous);
   } else {
   newStock = existingStock; // Reuse existing object
   }
3. Memory Management
   Proper Disposal: WebSocket connections and animation controllers disposed
   Stream Subscription Cleanup: Prevents memory leaks
   Bounded Data Storage: Only store necessary historical data

Development Time
Estimated Time: 6 hours
Initial setup and architecture: 1 hour
Core functionality implementation: 2 hours
Anomaly detection: 1 hour
Debugging & error fixing: 2 hours

Dependencies :
dependencies:
flutter:
sdk: flutter


cupertino_icons: ^1.0.8
web_socket_channel: ^3.0.3
flutter_hooks: ^0.21.2
hooks_riverpod: ^2.6.1