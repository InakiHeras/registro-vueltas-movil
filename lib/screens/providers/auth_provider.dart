import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthProvider with ChangeNotifier {
  String _token = '';
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;
  String get token => _token;

  Future<void> login(String email, String password) async {
    final url = Uri.parse('${dotenv.env['API_URL']}/login_app');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
        _isAuthenticated = true;
        notifyListeners();
      } else {
        throw Exception('Error de inicio de sesión');
      }
    } catch (e) {
      throw e;
    }
  }

  void logout(BuildContext context) {
    _token = '';
    _isAuthenticated = false;
    Navigator.of(context).pushReplacementNamed('/');
    notifyListeners();
  }
}
