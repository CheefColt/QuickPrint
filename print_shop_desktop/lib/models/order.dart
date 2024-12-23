import 'print_config.dart';

class Order {
  final String id;
  final String filename;
  final String status;
  final PrintConfig config;
  final DateTime timestamp;

  Order({
    required this.id,
    required this.filename,
    required this.status,
    required this.config,
    required this.timestamp,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      filename: json['filename'],
      status: json['status'],
      config: PrintConfig.fromJson(json['config']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}