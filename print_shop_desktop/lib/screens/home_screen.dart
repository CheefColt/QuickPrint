import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Shop Desktop'),
        actions: [
          Consumer<OrderProvider>(
            builder: (context, provider, child) {
              return Chip(
                label: Text(
                  provider.isConnected ? 'Connected' : 'Disconnected',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor:
                    provider.isConnected ? Colors.green : Colors.red,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<OrderProvider>().refreshOrders();
            },
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.orders.isEmpty) {
            return const Center(
              child: Text('No orders in queue'),
            );
          }

          return ListView.builder(
            itemCount: provider.orders.length,
            itemBuilder: (context, index) {
              final order = provider.orders[index];
              return OrderCard(order: order);
            },
          );
        },
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: const Icon(Icons.description),
        title: Text(order.filename),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${order.status}'),
            Text(
              'Config: ${order.config.copies} copies, ' +
              'Color: ${order.config.color ? "Yes" : "No"}, ' +
              'Double-sided: ${order.config.doubleSided ? "Yes" : "No"}'
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: () {
                // TODO: Implement print functionality
              },
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // TODO: Show order details/actions
              },
            ),
          ],
        ),
      ),
    );
  }
}