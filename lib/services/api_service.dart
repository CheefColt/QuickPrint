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
      
      debugPrint('📥 Status: ${response.statusCode}');
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

      debugPrint('🔍 Fetching orders from: $baseUrl/orders');
      final response = await _client.get(
        Uri.parse('$baseUrl/orders'),
        headers: {'Accept': 'application/json'},
      );

      debugPrint('📥 Response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load orders: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Get orders error: $e');
      rethrow;
    }
  }

  Future<bool> submitOrder(File file, PrintConfig config) async {
    try {
      if (!await testConnection()) {
        throw Exception('Server not reachable');
      }

      var uri = Uri.parse('$baseUrl/orders');
      var request = http.MultipartRequest('POST', uri);
      
      // Add file
      debugPrint('📤 Adding file: ${file.path}');
      request.files.add(
        await http.MultipartFile.fromPath('file', file.path)
      );
      
      // Add config
      request.fields['config'] = jsonEncode({
        'copies': config.copies,
        'color': config.color,
        'double_sided': config.doubleSided,
      });

      debugPrint('📤 Sending request to: $uri');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      debugPrint('📥 Response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode != 201) {
        throw Exception('Failed to submit order: ${response.body}');
      }
      
      return true;
    } catch (e) {
      debugPrint('❌ Submit error: $e');
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}