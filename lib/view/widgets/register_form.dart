import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mangadive/services/auth_service.dart'; // Adjust the import path as necessary
import 'package:intl_phone_field/intl_phone_field.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();
  bool _obscureText = true;
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Full Name"),
        TextField(
          controller: fullNameController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Enter your full name",
          ),
        ),
        const SizedBox(height: 16),

        const Text("Email"),
        TextField(
          controller: emailController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Enter your email",
          ),
        ),
        const SizedBox(height: 16),

        const Text("Birth of Date"),
        TextField(
          readOnly: true,
          onTap: () => _selectDate(context),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
            hintText:
                _selectedDate == null
                    ? "Select your birth date"
                    : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
          ),
        ),
        const SizedBox(height: 16),

        const Text("Phone Number"),
        IntlPhoneField(
          controller: phoneController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Enter your phone number",
          ),
          initialCountryCode: 'US',
          onChanged: (phone) {
            print(phone.completeNumber);
          },
        ),
        const SizedBox(height: 16),

        const Text("Set Password"),
        TextField(
          controller: passwordController,
          obscureText: _obscureText,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: "Enter your password",
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
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              User? user = await authService.signUp(
                emailController.text,
                passwordController.text,
              );
              if (user != null) {
                print("🎉 Register successfully!");
                Navigator.pop(context);
              } else {
                print("❌ Register failed!");
              }
            },
            child: const Text("Register"),
          ),
        ),
      ],
    );
  }
}
