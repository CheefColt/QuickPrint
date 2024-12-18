import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../models/order.dart';
import '../models/print_config.dart';

class ApiService {
  static const baseUrl = 'http://localhost:8000/api';
  
  Future<String> submitOrder(File document, PrintConfig config) async {
    try {
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('$baseUrl/orders')
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('document', document.path)
      );
      
      request.fields['config'] = jsonEncode({
        'paper_size': config.paperSize,
        'is_color': config.isColor,
        'is_duplex': config.isDuplex,
        'copies': config.copies,
      });
      
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 201) {
        return jsonDecode(responseData)['id'];
      }
      throw Exception(responseData);
    } catch (e) {
      throw Exception('Failed to submit order: $e');
    }
  }
}