import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/print_config.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.0.100:8000';
  final http.Client _client = http.Client();

  Future<bool> testConnection() async {
    try {
      debugPrint('🔍 Testing connection to: $baseUrl/health');
      final response = await _client.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      debugPrint('📥 Connection status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Connection error: $e');
      return false;
    }
  }

  Future<List<Order>> getOrders() async {
    try {
      if (!await testConnection()) {
        throw Exception('Server not reachable');
      }

      final response = await _client.get(
        Uri.parse('$baseUrl/orders'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      debugPrint('❌ Get orders error: $e');
      rethrow;
    }
  }

  Future<bool> submitOrder(File file, PrintConfig config) async {
    try {
      debugPrint('📤 Submitting order for ${file.path}');
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/orders'));
      
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      request.fields['config'] = jsonEncode({
        'copies': config.copies,
        'color': config.color,
        'double_sided': config.doubleSided,
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      debugPrint('📥 Response: ${response.statusCode} - ${response.body}');
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('❌ Submit error: $e');
      return false;
    }
  }
}