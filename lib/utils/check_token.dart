import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:projeto_escola/utils/https_routes.dart';

class TokenValidator {
  final String token;

  TokenValidator(this.token);

  Future<bool> checkTokenValidity() async {
    final url = Uri.parse(AppHttpsRoutes.protected);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 25), onTimeout: () {
        print('Request timed out');
        return http.Response('{"message": "Timeout"}', 408); 
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print('Response data: $responseData');
        return responseData['message'] == 'Token valido' ? true : false;
      } else {
        print('Request failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}
