import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/order.dart';
import '../models/print_config.dart';
import '../services/api_service.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService apiService;
  List<Order> _orders = [];
  bool _isLoading = false;

  OrderProvider({required this.apiService});

  bool get isLoading => _isLoading;
  List<Order> get orders => _orders;

  List<Order> get pendingOrders => 
    _orders.where((order) => order.status == 'pending').toList();
  
  List<Order> get completedOrders => 
    _orders.where((order) => order.status == 'completed').toList();

  Stream<List<Order>> watchOrders() async* {
    while (true) {
      try {
        final orders = await apiService.getOrders();
        _orders = orders;
        yield orders;
      } catch (e) {
        debugPrint('❌ Watch error: $e');
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Future<void> addOrder(String documentPath, PrintConfig config) async {
    try {
      _isLoading = true;
      notifyListeners();

      final order = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        filename: documentPath.split('\\').last,
        config: config,
        status: 'pending',
        timestamp: DateTime.now(),
      );

      await apiService.submitOrder(File(documentPath), config);
      _orders.insert(0, order);
      
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Add order error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshOrders() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _orders = await apiService.getOrders();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Refresh error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitOrder(String documentPath, PrintConfig config) async {
    try {
      return await apiService.submitOrder(File(documentPath), config);
    } catch (e) {
      debugPrint('Error submitting order: $e');
      return false;
    }
  }
}