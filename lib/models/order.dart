import 'print_config.dart';

class Order {
  final String id;
  final String filename;
  final PrintConfig config;
  final String status;
  final DateTime timestamp;

  Order({
    required this.id,
    required this.filename,
    required this.config,
    required this.status,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Order copyWith({
    String? id,
    String? filename,
    PrintConfig? config,
    String? status,
    DateTime? timestamp,
  }) {
    return Order(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      config: config ?? this.config,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'filename': filename,
    'config': config.toJson(),
    'status': status,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      filename: json['filename'],
      config: PrintConfig.fromJson(json['config']),
      status: json['status'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  
  double get totalCost => config.calculateCost();

  @override
  String toString() => 
    'Order(id: $id, filename: $filename, status: $status)';

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is Order &&
    id == other.id &&
    filename == other.filename &&
    config == other.config &&
    status == other.status &&
    timestamp == other.timestamp;

  @override
  int get hashCode =>
    id.hashCode ^
    filename.hashCode ^
    config.hashCode ^
    status.hashCode ^
    timestamp.hashCode;
}