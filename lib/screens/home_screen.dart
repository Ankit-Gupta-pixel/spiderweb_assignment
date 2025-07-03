
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/stock_provider.dart';
import '../services/websocket_service.dart';
import '../widgets/stock_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final WebSocketService _wsService;
  ConnectionStatus _connectionStatus = ConnectionStatus.connecting;

  @override
  void initState() {
    super.initState();
    _wsService = WebSocketService();
    _wsService.onData = (data) {
      if (mounted) {
        ref.read(stockNotifierProvider.notifier).updateStocks(data);
      }
    };
    _wsService.onStatusChanged = (status) {
      if (mounted) {
        setState(() => _connectionStatus = status);
      }
    };
    _wsService.connect();
  }

  @override
  void dispose() {
    _wsService.dispose();
    super.dispose();
  }

  String _getStatusText(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connecting:
        return "Connecting";
      case ConnectionStatus.connected:
        return "Connected";
      case ConnectionStatus.reconnecting:
        return "Reconnecting...";
      case ConnectionStatus.disconnected:
        return "Disconnected";
    }
  }

  Color _getStatusColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.connecting:
      case ConnectionStatus.reconnecting:
        return Colors.orange;
      case ConnectionStatus.disconnected:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stocks = ref.watch(stockNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unstable Ticker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_connectionStatus == ConnectionStatus.connecting ||
                      _connectionStatus == ConnectionStatus.reconnecting)
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  if (_connectionStatus == ConnectionStatus.connecting ||
                      _connectionStatus == ConnectionStatus.reconnecting)
                    const SizedBox(width: 8),
                  Text(
                    _getStatusText(_connectionStatus),
                    style: TextStyle(
                      color: _getStatusColor(_connectionStatus),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: stocks.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Waiting for stock data...'),
            const SizedBox(height: 8),
            Text(
              'Status: ${_getStatusText(_connectionStatus)}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: stocks.length,
        itemBuilder: (context, index) {
          return StockTile(
            key: ValueKey(stocks[index].ticker),
            stock: stocks[index],
          );
        },
      ),
    );
  }
}
