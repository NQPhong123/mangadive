import 'package:flutter/material.dart';
import 'package:mangadive/services/auth_service.dart';
// Adjust the import path as necessary
import 'package:firebase_auth/firebase_auth.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _obscureText = true;
  final AuthService authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: "Email",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordController,
          obscureText: _obscureText,
          decoration: InputDecoration(
            labelText: "Password",
            border: OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text(
              "Forgot Password?",
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: handleSignIn,
            child: const Text("Sign In"),
          ),
        ),
      ],
    );
  }

  void handleSignIn() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    User? user = await authService.signIn(email, password);
    if (user != null) {
      print("🎉 Login successfully!");
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      print("❌ Login failed!");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Sai email hoặc mật khẩu")));
    }
  }
}
