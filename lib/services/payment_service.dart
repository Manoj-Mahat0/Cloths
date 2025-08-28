import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:upi_pay/upi_pay.dart';
import 'package:flutter/material.dart';

class PaymentService {
  // static const String _razorpayKey = 'rzp_test_YOUR_KEY_HERE'; // Replace with your actual key
  static const String _defaultReceiverUpiId = '8709790175@ibl';

  Future<void> startPayment({
    required String productName,
    required int amountInCents,
    required String userEmail,
    required String userPhone,
    required String orderId,
  }) async {
    try {
      // Check if we're on a supported platform
      if (kIsWeb) {
        // Web platform - show web payment options
        _showWebPaymentOptions(productName, amountInCents);
        return;
      }

      if (Platform.isAndroid || Platform.isIOS) {
        // Mobile platform - show mobile payment options
        _showMobilePaymentOptions(productName, amountInCents);
        return;
      }

      // Desktop platform - show desktop payment options
      _showDesktopPaymentOptions(productName, amountInCents);
    } catch (e) {
      debugPrint('Error starting payment: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> startUpiPayment({
    required String productName,
    required int amountInCents,
    String? userUpiId, // Now optional
    String? transactionNote,
  }) async {
    try {
      final upiPay = UpiPay();
      final apps = await upiPay.getInstalledUpiApplications(
        statusType: UpiApplicationDiscoveryAppStatusType.all,
      );
      if (apps.isEmpty) {
        debugPrint('No UPI apps installed');
        return {'status': 'no_app'};
      }
      final response = await upiPay.initiateTransaction(
        amount: (amountInCents / 100).toStringAsFixed(2),
        app: apps.first.upiApplication,
        receiverName: productName,
        receiverUpiAddress: userUpiId ?? _defaultReceiverUpiId,
        transactionRef: DateTime.now().millisecondsSinceEpoch.toString(),
        transactionNote: transactionNote ?? 'Payment for $productName',
      );
      debugPrint('UPI Payment Status: ${response.status}');
      debugPrint('UPI Raw Response: ${response.rawResponse}');
      final raw = (response.rawResponse ?? {}) as Map<String, dynamic>;
      return {
        'status': response.status.toString(),
        'txnId': raw['txnId'] ?? raw['txnID'] ?? '',
        'approvalRefNo': raw['ApprovalRefNo'] ?? raw['approvalRefNo'] ?? '',
        'rawResponse': raw,
      };
    } catch (e) {
      debugPrint('Error in UPI payment: $e');
      return {'status': 'error', 'error': e.toString()};
    }
  }

  void _showWebPaymentOptions(String productName, int amountInCents) {
    // For web, we'll show a dialog with payment options
    debugPrint('Web payment for $productName: ₹${(amountInCents / 100).toStringAsFixed(2)}');
    // You can implement web-specific payment here
  }

  void _showMobilePaymentOptions(String productName, int amountInCents) {
    // For mobile, show payment app options
    debugPrint('Mobile payment for $productName: ₹${(amountInCents / 100).toStringAsFixed(2)}');
    // Example usage of UPI payment (replace userUpiId with actual value from user input)
    // startUpiPayment(productName: productName, amountInCents: amountInCents, userUpiId: 'user@upi');
    _showPaymentMethodDialog(productName, amountInCents);
  }

  void _showDesktopPaymentOptions(String productName, int amountInCents) {
    // For desktop, show payment options
    debugPrint('Desktop payment for $productName: ₹${(amountInCents / 100).toStringAsFixed(2)}');
    
    // Show payment method selection dialog
    _showPaymentMethodDialog(productName, amountInCents);
  }

  void _showPaymentMethodDialog(String productName, int amountInCents) {
    // This will be called from the UI to show payment options
    debugPrint('Payment method dialog for $productName: ₹${(amountInCents / 100).toStringAsFixed(2)}');
  }

  // Method to simulate successful payment (for testing)
  Future<bool> simulatePayment() async {
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));
    return true; // Simulate success
  }

  void dispose() {
    // Cleanup if needed
  }
}
