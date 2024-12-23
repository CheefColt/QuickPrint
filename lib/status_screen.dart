import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/order_provider.dart';
import 'models/order.dart';
import 'services/api_service.dart';

class StatusScreen extends StatefulWidget {
  final ApiService apiService;
  
  const StatusScreen({Key? key, required this.apiService}) : super(key: key);
  
  @override
  _StatusScreenState createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  List<Order> orders = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final newOrders = await orderProvider.getOrders();
      
      if (!mounted) return;
      
      setState(() {
        orders = newOrders;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      debugPrint('Error loading orders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Status'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOrders,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: orders.isEmpty
          ? const Center(child: Text('No orders found'))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) => _buildOrderItem(orders[index]),
            ),
    );
  }

  Widget _buildOrderItem(Order order) {
    return ListTile(
      title: Text(order.filename),
      subtitle: Text('Status: ${order.status}'),
      trailing: Text(order.timestamp.toString()),
    );
  }
}

class OrderProvider extends ChangeNotifier {
  Future<List<Order>> getOrders() async {
    // Implement your order fetching logic here
    // For example, using your API service
    // Return a List<Order>
    return [];
  }
}