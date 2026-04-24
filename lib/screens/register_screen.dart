import 'package:flutter/material.dart';
import 'package:notes_app/services/api_services.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _apiService = ApiServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // APP Bar
      appBar: AppBar(
        title: Text("Register"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            // Username TextField
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 16,
            ),

            //Email TextField
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                label: Text("Email"),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 16,
            ),

            //Password Text Field
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                label: Text("Password"),
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(
              height: 24,
            ),

            //Register Button

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final success = await _apiService.register(
                    _usernameController.text,
                    _emailController.text,
                    _passwordController.text,
                  );

                  if (!mounted) return;

                  if (success) {
                    Navigator.pushReplacementNamed(context, '/login');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Registration failed. Try again."),
                      ),
                    );
                  }
                },
                child: Text("Register"),
              ),
            ),

            // Text Button for redirect in Login Page

            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
