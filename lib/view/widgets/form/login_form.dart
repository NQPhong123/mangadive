import 'package:flutter/material.dart';
import 'package:mangadive/controllers/auth_controller.dart';
import 'package:mangadive/utils/validators.dart';
import 'package:provider/provider.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) => Validators.validateEmail(value),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Mật khẩu',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mật khẩu';
              }
              return null;
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/forgot-password');
              },
              child: const Text(
                'Quên mật khẩu?',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed:
                authController.isLoading
                    ? null
                    : () {
                      if (_formKey.currentState!.validate()) {
                        authController.login(
                          context,
                          _emailController.text,
                          _passwordController.text,
                        );
                      }
                    },
            child:
                authController.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }
}
