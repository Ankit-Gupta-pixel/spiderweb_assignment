
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

enum ConnectionStatus { connecting, connected, reconnecting, disconnected }

class WebSocketService {
  final _url = 'ws://127.0.0.1:8080/ws';
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  Function(List<dynamic>)? onData;
  Function(ConnectionStatus)? onStatusChanged;

  int _reconnectDelay = 2;
  Timer? _reconnectTimer;
  ConnectionStatus _status = ConnectionStatus.connecting;
  bool _disposed = false;

  ConnectionStatus get status => _status;

  void connect() {
    if (_disposed) return;
    _updateStatus(ConnectionStatus.connecting);
    try {
      _channel?.sink.close();
      _subscription?.cancel();
      _channel = WebSocketChannel.connect(Uri.parse(_url));
      _subscription = _channel!.stream.listen(
        _handleData,
        onDone: _handleDisconnect,
        onError: _handleError,
      );

      _updateStatus(ConnectionStatus.connected);
      _reconnectDelay = 2; // Reset delay on successful connection

    } catch (e) {
      print('failed to connect WebSocket : $e');
      _handleDisconnect();
    }
  }

  void _handleData(dynamic data) {
    if (_disposed) return;
    try {
      final decoded = jsonDecode(data);
      if (decoded is List) {
        onData?.call(decoded);
      } else {
        print('data : ${decoded.runtimeType}');
      }
    } catch (e) {
      print('malformed data $e');
    }
  }

  void _handleError(dynamic error) {
    _handleDisconnect();
  }

  void _handleDisconnect() {
    if (_disposed) return;
    _updateStatus(ConnectionStatus.reconnecting);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    if (_reconnectDelay > 30) _reconnectDelay = 30;
    _reconnectTimer = Timer(Duration(seconds: _reconnectDelay), () {
      if (!_disposed) {
        _reconnectDelay *= 2;
        connect();
      }
    });
  }

  void _updateStatus(ConnectionStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      onStatusChanged?.call(newStatus);
    }
  }

  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
  }
}