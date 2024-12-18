import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/order_provider.dart';

class StatusScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orders = Provider.of<OrderProvider>(context).orders;

    return Scaffold(
      appBar: AppBar(
        title: Text('Check Order Status'),
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return ListTile(
            title: Text(order.documentName),
            subtitle: Text('Status: ${order.status}'),
          );
        },
      ),
    );
  }
}