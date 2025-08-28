class RegisterRequest {
  RegisterRequest({
    required this.username,
    required this.fullName,
    required this.password,
    required this.role,
    required this.email,
  });

  final String username;
  final String fullName;
  final String password;
  final String role; // user | warehouse | admin
  final String email;
}

class OtpLoginRequest {
  OtpLoginRequest({required this.usernameOrEmail});

  final String usernameOrEmail;
}

class VerifyOtpRequest {
  VerifyOtpRequest({required this.username, required this.otp});

  final String username;
  final String otp;
}


