class Validators {
  // Kiểm tra email hợp lệ
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return "Vui lòng nhập email";
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return "Email không hợp lệ";
    }

    return null; // Email hợp lệ
  }

  // Kiểm tra mật khẩu hợp lệ (Ít nhất 8 ký tự, bao gồm cả chữ và số)
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return "Vui lòng nhập mật khẩu";
    }

    if (password.length < 8) {
      return "Mật khẩu phải có ít nhất 8 ký tự";
    }

    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');

    if (!passwordRegex.hasMatch(password)) {
      return "Mật khẩu phải chứa ít nhất một chữ cái và một số";
    }

    return null; // Mật khẩu hợp lệ
  }
}
