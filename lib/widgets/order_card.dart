import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  
  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(order.filename),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${order.status}'),
            Text('Config: ${order.config.paperSize}, ${order.config.copies} copies'),
            Text(DateFormat('MMM d, HH:mm').format(order.timestamp)),
          ],
        ),
      ),
    );
  }
}