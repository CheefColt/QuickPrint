import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/print_config.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  
  List<Order> get pendingOrders => 
    _orders.where((order) => order.isPending).toList();
  
  List<Order> get completedOrders => 
    _orders.where((order) => order.isCompleted).toList();

  Future<void> addOrder(String documentPath, PrintConfig config) async {
    try {
      _isLoading = true;
      notifyListeners();

      final order = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        documentName: documentPath.split('\\').last,
        config: config,
        status: Order.STATUS_PENDING,
        createdAt: DateTime.now(),
      );

      _orders.add(order);
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void removeOrder(String id) {
    _orders.removeWhere((order) => order.id == id);
    notifyListeners();
  }

  void updateOrderStatus(String id, String status) {
    final orderIndex = _orders.indexWhere((order) => order.id == id);
    if (orderIndex != -1) {
      _orders[orderIndex] = _orders[orderIndex].copyWith(status: status);
      notifyListeners();
    }
  }

  double get totalCost => 
    _orders.fold(0, (sum, order) => sum + order.config.calculateCost());

  void clear() {
    _orders.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _orders.clear();
    super.dispose();
  }
}