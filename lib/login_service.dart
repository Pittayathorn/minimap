import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> login(String username, String password) async {
  try {
    final response = await http.post(
      Uri.parse('https://web.mini-map.shop/login'),
      body: json.encode({
        'username': username,
        'password': password,
      }),
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    );

    if (response.statusCode == 200) {
      return 'Login successful!';
    } else {
      return 'Invalid username or password.';
    }
  } catch (e) {
    return 'Failed to connect to the server. Please try again later.';
  }
}
