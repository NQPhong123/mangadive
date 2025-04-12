import 'package:flutter/material.dart';
import 'package:mangadive/services/auth_service.dart'; // Giả sử đây là đường dẫn tới AuthService

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _changePassword() async {
    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Kiểm tra đầu vào
    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng điền đầy đủ thông tin.';
        _isLoading = false;
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = 'Mật khẩu mới và xác nhận mật khẩu không khớp.';
        _isLoading = false;
      });
      return;
    }

    if (newPassword.length < 6) {
      setState(() {
        _errorMessage = 'Mật khẩu mới phải có ít nhất 6 ký tự.';
        _isLoading = false;
      });
      return;
    }

    try {
      await _authService.changePassword(currentPassword, newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: const Text('Đổi mật khẩu thành công!')),
      );
      Navigator.pop(context); // Quay lại màn hình trước
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi: ${e.toString().replaceAll('Exception: ', '')}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đổi Mật Khẩu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _currentPasswordController,
              decoration: InputDecoration(
                labelText: 'Mật khẩu hiện tại',
                errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu mới',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Xác nhận mật khẩu mới',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _changePassword,
                    child: const Text('Cập nhật mật khẩu'),
                  ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
