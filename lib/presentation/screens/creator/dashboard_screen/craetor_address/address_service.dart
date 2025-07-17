import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../data/models/creator_address.dart';

class AddressService {
  final String baseUrl = 'http://46.202.175.64:3000/api/addresses';

  Future<AddressModel?> getAddress(int creatorId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$creatorId'),
        headers: _buildHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return AddressModel.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('getAddress error: $e');
      rethrow;
    }
  }

  Future<bool> upsertAddress(AddressModel address, String token) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: _buildHeaders(token),
        body: jsonEncode(address.toJson()),
      );

      final data = jsonDecode(response.body);
      return (response.statusCode == 200 || response.statusCode == 201) && data['success'] == true;
    } catch (e) {
      print('upsertAddress error: $e');
      rethrow;
    }
  }

  Map<String, String> _buildHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
}
