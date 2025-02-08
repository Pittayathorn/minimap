import 'package:flutter/material.dart';
import 'login_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = "";
  bool _isLoading = false;

  // Function to handle login action
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _message = "";
    });

    final result = await login(
      _usernameController.text,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
      _message = result;
    });

    // หากล็อกอินสำเร็จ, ไปยังหน้า HomePage
    if (_message == 'Login successful!') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: Text('Login'),
                  ),
            SizedBox(height: 20),
            Text(_message),
          ],
        ),
      ),
    );
  }
}
