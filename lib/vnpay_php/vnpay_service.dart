import 'dart:convert';
import 'package:http/http.dart' as http;

class VNPayService {
  final _createUrl = Uri.parse(
    'https://32ce-123-21-101-235.ngrok-free.app/vnpay_php/vnpay_create_payment.php',
  );

  Future<String> createOrder(String orderId, int amount) async {
    // 1) gửi request
    final resp = await http.post(_createUrl, body: {
      'order_id': orderId,
      'amount': amount.toString(),
    });

    // 2) kiểm tra HTTP status
    if (resp.statusCode != 200) {
      throw Exception('Server error: ${resp.statusCode}');
    }

    // 3) parse JSON
    final body = jsonDecode(resp.body) as Map<String, dynamic>;

    // 4) tìm URL trong JSON
    final url = (body['payUrl'] ?? body['data']) as String?;
    if (url == null || url.isEmpty) {
      throw Exception(
        'Không tìm thấy payUrl trong response: ${resp.body}',
      );
    }

    return url;
  }
}
