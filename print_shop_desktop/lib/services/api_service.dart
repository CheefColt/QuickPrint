import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import '../models/print_config.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.0.100:8000';
  final http.Client _client = http.Client();

  Future<bool> testConnection() async {
    try {
      debugPrint('Testing connection to $baseUrl/health');
      final response = await _client.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Connection error: $e');
      return false;
    }
  }

  Future<List<Order>> getOrders() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/orders'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      }
      throw Exception('Failed to load orders');
    } catch (e) {
      debugPrint('Error getting orders: $e');
      return [];
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    final response = await _client.patch(
      Uri.parse('$baseUrl/orders/$orderId'),
      body: json.encode({'status': status}),
      headers: {'Content-Type': 'application/json'},
    );
    return response.statusCode == 200;
  }
}