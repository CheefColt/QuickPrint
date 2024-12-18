import 'print_config.dart';

class Order {
  static const String STATUS_PENDING = 'pending';
  static const String STATUS_PROCESSING = 'processing';
  static const String STATUS_COMPLETED = 'completed';
  static const String STATUS_FAILED = 'failed';

  final String id;
  final String documentName;
  final PrintConfig config;
  final String status;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.documentName,
    required this.config,
    required this.status,
    required this.createdAt,
  });

  Order copyWith({
    String? id,
    String? documentName,
    PrintConfig? config,
    String? status,
    DateTime? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      documentName: documentName ?? this.documentName,
      config: config ?? this.config,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'document_name': documentName,
    'config': config.toJson(),
    'status': status,
    'created_at': createdAt.toIso8601String(),
  };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'],
    documentName: json['document_name'],
    config: PrintConfig.fromJson(json['config']),
    status: json['status'],
    createdAt: DateTime.parse(json['created_at']),
  );

  bool get isPending => status == STATUS_PENDING;
  bool get isProcessing => status == STATUS_PROCESSING;
  bool get isCompleted => status == STATUS_COMPLETED;
  bool get isFailed => status == STATUS_FAILED;
  
  double get totalCost => config.calculateCost();

  @override
  String toString() => 
    'Order(id: $id, documentName: $documentName, status: $status)';

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is Order &&
    id == other.id &&
    documentName == other.documentName &&
    config == other.config &&
    status == other.status &&
    createdAt == other.createdAt;

  @override
  int get hashCode =>
    id.hashCode ^
    documentName.hashCode ^
    config.hashCode ^
    status.hashCode ^
    createdAt.hashCode;
}