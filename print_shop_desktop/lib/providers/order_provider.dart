import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/order.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService _apiService;
  List<Order> _orders = [];
  bool _isConnected = false;

  OrderProvider({required ApiService apiService}) : _apiService = apiService {
    _init();
  }

  bool get isConnected => _isConnected;
  List<Order> get orders => _orders;

  Future<void> _init() async {
    await _checkConnection();
    await refreshOrders();
  }

  Future<void> _checkConnection() async {
    _isConnected = await _apiService.testConnection();
    notifyListeners();
  }

  Future<void> refreshOrders() async {
    try {
      _orders = await _apiService.getOrders();
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing orders: $e');
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    final success = await _apiService.updateOrderStatus(orderId, status);
    if (success) {
      await refreshOrders();
    }
    return success;
  }
}