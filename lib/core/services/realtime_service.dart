import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'storage_service.dart';

class RealtimeService {
  static WebSocketChannel? _channel;
  static Timer? _heartbeatTimer;
  static Timer? _reconnectTimer;
  static bool _isConnected = false;
  static int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;
  
  // Stream controllers for different data types
  static final StreamController<Map<String, dynamic>> _businessDataController =
      StreamController<Map<String, dynamic>>.broadcast();
  static final StreamController<Map<String, dynamic>> _financialDataController =
      StreamController<Map<String, dynamic>>.broadcast();
  static final StreamController<Map<String, dynamic>> _networkingDataController =
      StreamController<Map<String, dynamic>>.broadcast();
  static final StreamController<Map<String, dynamic>> _learningDataController =
      StreamController<Map<String, dynamic>>.broadcast();
  static final StreamController<Map<String, dynamic>> _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();
  static final StreamController<Map<String, dynamic>> _generalController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Public streams
  static Stream<Map<String, dynamic>> get businessDataStream => _businessDataController.stream;
  static Stream<Map<String, dynamic>> get financialDataStream => _financialDataController.stream;
  static Stream<Map<String, dynamic>> get networkingDataStream => _networkingDataController.stream;
  static Stream<Map<String, dynamic>> get learningDataStream => _learningDataController.stream;
  static Stream<Map<String, dynamic>> get notificationStream => _notificationController.stream;
  static Stream<Map<String, dynamic>> get generalStream => _generalController.stream;

  // Connection status
  static bool get isConnected => _isConnected;

  // Initialize realtime service
  static Future<void> init() async {
    await _connect();
  }

  // Connect to WebSocket
  static Future<void> _connect() async {
    try {
      if (kDebugMode) {
        print('🔄 Connecting to realtime service...');
      }

      // For demo purposes, we'll simulate a WebSocket connection
      // In production, replace with actual WebSocket URL
      _channel = IOWebSocketChannel.connect('wss://api.biznest.com/realtime');
      
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );

      _isConnected = true;
      _reconnectAttempts = 0;
      
      // Start heartbeat
      _startHeartbeat();
      
      // Send authentication
      await _sendAuth();
      
      if (kDebugMode) {
        print('✅ Connected to realtime service');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to connect to realtime service: $e');
      }
      _scheduleReconnect();
    }
  }

  // Handle incoming messages
  static void _handleMessage(dynamic message) {
    try {
      final data = json.decode(message);
      final type = data['type'] as String?;
      final payload = data['payload'] as Map<String, dynamic>?;

      if (type == null || payload == null) return;

      // Route message to appropriate controller
      switch (type) {
        case 'business_data':
          _businessDataController.add(payload);
          break;
        case 'financial_data':
          _financialDataController.add(payload);
          break;
        case 'networking_data':
          _networkingDataController.add(payload);
          break;
        case 'learning_data':
          _learningDataController.add(payload);
          break;
        case 'notification':
          _notificationController.add(payload);
          break;
        case 'general':
          _generalController.add(payload);
          break;
        case 'pong':
          // Heartbeat response
          break;
        default:
          if (kDebugMode) {
            print('📨 Unknown message type: $type');
          }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error handling message: $e');
      }
    }
  }

  // Handle connection errors
  static void _handleError(error) {
    if (kDebugMode) {
      print('❌ WebSocket error: $error');
    }
    _isConnected = false;
    _scheduleReconnect();
  }

  // Handle disconnection
  static void _handleDisconnection() {
    if (kDebugMode) {
      print('🔌 WebSocket disconnected');
    }
    _isConnected = false;
    _scheduleReconnect();
  }

  // Schedule reconnection
  static void _scheduleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      if (kDebugMode) {
        print('❌ Max reconnection attempts reached');
      }
      return;
    }

    _reconnectAttempts++;
    final delay = Duration(seconds: _reconnectAttempts * 2);
    
    if (kDebugMode) {
      print('🔄 Scheduling reconnection in ${delay.inSeconds} seconds (attempt $_reconnectAttempts)');
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      _connect();
    });
  }

  // Start heartbeat
  static void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        _sendHeartbeat();
      }
    });
  }

  // Send heartbeat
  static void _sendHeartbeat() {
    _sendMessage({
      'type': 'ping',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Send authentication
  static Future<void> _sendAuth() async {
    final token = await StorageService.getString('auth_token');
    if (token != null) {
      _sendMessage({
        'type': 'auth',
        'token': token,
      });
    }
  }

  // Send message
  static void _sendMessage(Map<String, dynamic> message) {
    if (_channel != null && _isConnected) {
      try {
        _channel!.sink.add(json.encode(message));
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error sending message: $e');
        }
      }
    }
  }

  // Subscribe to data type
  static void subscribe(String dataType) {
    _sendMessage({
      'type': 'subscribe',
      'data_type': dataType,
    });
  }

  // Unsubscribe from data type
  static void unsubscribe(String dataType) {
    _sendMessage({
      'type': 'unsubscribe',
      'data_type': dataType,
    });
  }

  // Request specific data
  static void requestData(String dataType, {Map<String, dynamic>? filters}) {
    _sendMessage({
      'type': 'request_data',
      'data_type': dataType,
      'filters': filters,
    });
  }

  // Send user activity
  static void sendUserActivity(String activity, {Map<String, dynamic>? data}) {
    _sendMessage({
      'type': 'user_activity',
      'activity': activity,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Send business plan update
  static void sendBusinessPlanUpdate(String planId, Map<String, dynamic> updates) {
    _sendMessage({
      'type': 'business_plan_update',
      'plan_id': planId,
      'updates': updates,
    });
  }

  // Send financial data update
  static void sendFinancialUpdate(String calculationId, Map<String, dynamic> data) {
    _sendMessage({
      'type': 'financial_update',
      'calculation_id': calculationId,
      'data': data,
    });
  }

  // Send networking activity
  static void sendNetworkingActivity(String activity, Map<String, dynamic> data) {
    _sendMessage({
      'type': 'networking_activity',
      'activity': activity,
      'data': data,
    });
  }

  // Send learning progress
  static void sendLearningProgress(String courseId, int progress) {
    _sendMessage({
      'type': 'learning_progress',
      'course_id': courseId,
      'progress': progress,
    });
  }

  // Get connection status
  static Map<String, dynamic> getConnectionStatus() {
    return {
      'is_connected': _isConnected,
      'reconnect_attempts': _reconnectAttempts,
      'max_attempts': maxReconnectAttempts,
    };
  }

  // Disconnect
  static void disconnect() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _isConnected = false;
    
    if (kDebugMode) {
      print('🔌 Disconnected from realtime service');
    }
  }

  // Dispose
  static void dispose() {
    disconnect();
    _businessDataController.close();
    _financialDataController.close();
    _networkingDataController.close();
    _learningDataController.close();
    _notificationController.close();
    _generalController.close();
  }
}
