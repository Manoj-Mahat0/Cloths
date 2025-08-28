import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class PhoneVerificationService {
  static String get _baseUrl => AuthService.baseUrl;
  
  // Send OTP to phone number
  Future<bool> sendOTP(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/send-otp'),
        headers: await AuthService.getHeaders(),
        body: json.encode({'phone': phoneNumber}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error sending OTP: $e');
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOTP(String phoneNumber, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/verify-otp'),
        headers: await AuthService.getHeaders(),
        body: json.encode({
          'phone': phoneNumber,
          'otp': otp,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }
}
