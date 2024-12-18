import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';
import 'upload_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UploadScreen()),
            ),
          ),
        ],
      ),
      body: _buildBody(orderProvider),
    );
  }

  Widget _buildBody(OrderProvider orderProvider) {
    if (orderProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orderProvider.orders.isEmpty) {
      return const Center(child: Text('No orders yet'));
    }

    return ListView.builder(
      itemCount: orderProvider.orders.length,
      itemBuilder: (context, index) {
        final order = orderProvider.orders[index];
        return _buildOrderItem(order);
      },
    );
  }

  Widget _buildOrderItem(Order order) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(order.documentName),
        subtitle: Text('Status: ${order.status}'),
        trailing: Text('${order.config.copies} copies'),
      ),
    );
  }
}