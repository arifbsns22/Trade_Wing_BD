import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trade_wign_bd/features/users/e-commerce/domain/models/order_model.dart';

class SteadfastService {
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('settings_delivery_steadfast_api_key') ?? '';
    final secretKey = prefs.getString('settings_delivery_steadfast_secret_key') ?? '';
    return {
      'Api-Key': apiKey,
      'Secret-Key': secretKey,
      'Content-Type': 'application/json',
    };
  }

  static Future<String> _getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('settings_delivery_steadfast_base_url') ?? 'https://portal.packzy.com/api/v1';
  }

  static Future<bool> isActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('settings_delivery_steadfast_active') ?? false;
  }

  static Future<double?> getBalance() async {
    try {
      final headers = await _getHeaders();
      final baseUrl = await _getBaseUrl();
      if (headers['Api-Key']!.isEmpty || headers['Secret-Key']!.isEmpty) return null;

      final url = Uri.parse('$baseUrl/get_balance');
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200) {
          return (data['current_balance'] ?? 0.0).toDouble();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> createOrder({
    required OrderModel order,
    required double codAmount,
    String? note,
    String? itemDescription,
    int? deliveryType, // 0 = Home Delivery, 1 = Hub Pick Up
  }) async {
    try {
      final headers = await _getHeaders();
      final baseUrl = await _getBaseUrl();
      if (headers['Api-Key']!.isEmpty || headers['Secret-Key']!.isEmpty) {
        return {
          'status': 'error',
          'message': 'Steadfast API Key or Secret Key is not configured.',
        };
      }

      final url = Uri.parse('$baseUrl/create_order');
      final body = {
        'invoice': order.orderId,
        'recipient_name': order.userName,
        'recipient_phone': order.userMobile,
        'recipient_address': order.address,
        'cod_amount': codAmount,
        'note': note ?? 'Order from Trade Wign BD',
        'item_description': itemDescription ?? 'E-commerce goods',
        'delivery_type': deliveryType ?? 0,
      };

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200 && data['consignment'] != null) {
          final consignment = data['consignment'];
          return {
            'status': 'success',
            'consignment_id': consignment['consignment_id']?.toString(),
            'tracking_code': consignment['tracking_code'],
            'delivery_status': consignment['status'] ?? 'pending',
          };
        } else {
          return {
            'status': 'error',
            'message': data['message'] ?? 'Failed to place order in Steadfast.',
          };
        }
      } else {
        return {
          'status': 'error',
          'message': 'Steadfast returned status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Steadfast Connection Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> checkStatus(String trackingCode) async {
    try {
      final headers = await _getHeaders();
      final baseUrl = await _getBaseUrl();
      final url = Uri.parse('$baseUrl/status_by_trackingcode/$trackingCode');
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
      return {'status': 'error', 'message': 'Failed to fetch status'};
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error: $e'};
    }
  }
}
