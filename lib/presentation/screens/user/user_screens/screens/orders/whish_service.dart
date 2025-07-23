import 'dart:convert';
import 'package:http/http.dart' as http;

class WhishService {
  static const String baseUrl = "https://lb.sandbox.whish.money/itel-service/api";

  static Future<String?> generateWhishPaymentUrl({
    required double amount,
    required String currency,
    required String invoice,
    required int externalId,
    required String successUrl,
    required String failureUrl,
  }) async {
    final uri = Uri.parse('$baseUrl/payment/whish');

    final headers = {
      'Content-Type': 'application/json',
      'channel': '10195600',
      'secret': '558ac0db615644cc98d9dea309da7c99',
      'websiteurl': 'https://mashru3i.com',
    };

    final body = jsonEncode({
      "amount": amount.toInt(),
      "currency": currency,
      "invoice": invoice,
      "externalId": externalId,
      "successCallbackUrl": successUrl,
      "failureCallbackUrl": failureUrl,
      "successRedirectUrl": successUrl,
      "failureRedirectUrl": failureUrl,
    });

    final response = await http.post(uri, headers: headers, body: body);

    print('Whish response: ${response.body}');

    final json = jsonDecode(response.body);

    if (json['status'] == true && json['data'] != null && json['data']['collectUrl'] != null) {
      String url = json['data']['collectUrl'];
      if (!url.startsWith('http')) {
        url = 'https://$url';
      }
      return url;
    } else {
      throw Exception(json['dialog'] ?? 'Whish payment failed');
    }
  }
}
