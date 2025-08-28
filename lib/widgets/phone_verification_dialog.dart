import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/phone_verification_service.dart';

class PhoneVerificationDialog extends StatefulWidget {
  final String phoneNumber;
  final Function(bool) onVerificationComplete;

  const PhoneVerificationDialog({
    super.key,
    required this.phoneNumber,
    required this.onVerificationComplete,
  });

  @override
  State<PhoneVerificationDialog> createState() => _PhoneVerificationDialogState();
}

class _PhoneVerificationDialogState extends State<PhoneVerificationDialog> {
  final PhoneVerificationService _verificationService = PhoneVerificationService();
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
  bool _loading = false;
  bool _otpSent = false;
  bool _verifying = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _sendOTP();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B8FAC).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.phone_android,
                    color: Color(0xFF0B8FAC),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Verify Phone Number',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.phoneNumber,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // OTP Input
            if (_otpSent) ...[
              const Text(
                'Enter 6-digit OTP sent to your phone',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    height: 55,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF0B8FAC), width: 2),
                        ),
                        contentPadding: const EdgeInsets.all(8),
                      ),
                      onChanged: (value) {
                        if (value.length == 1 && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red.shade600, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Verify Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _verifying ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B8FAC),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _verifying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Verify OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive OTP? ",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  TextButton(
                    onPressed: _loading ? null : _resendOTP,
                    child: Text(
                      'Resend',
                      style: TextStyle(
                        color: _loading ? Colors.grey : const Color(0xFF0B8FAC),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Loading state while sending OTP
              const SizedBox(height: 40),
              const CircularProgressIndicator(color: Color(0xFF0B8FAC)),
              const SizedBox(height: 20),
              Text(
                'Sending OTP...',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _sendOTP() async {
    setState(() => _loading = true);
    
    try {
      final success = await _verificationService.sendOTP(widget.phoneNumber);
      if (mounted) {
        setState(() {
          _loading = false;
          _otpSent = success;
          if (!success) {
            _errorMessage = 'Failed to send OTP. Please try again.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = 'Error: $e';
        });
      }
    }
  }

  Future<void> _resendOTP() async {
    setState(() => _loading = true);
    _errorMessage = '';
    
    try {
      final success = await _verificationService.sendOTP(widget.phoneNumber);
      if (mounted) {
        setState(() {
          _loading = false;
          if (!success) {
            _errorMessage = 'Failed to resend OTP. Please try again.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = 'Error: $e';
        });
      }
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((controller) => controller.text).join();
    if (otp.length != 6) {
      setState(() => _errorMessage = 'Please enter complete 6-digit OTP');
      return;
    }

    setState(() {
      _verifying = true;
      _errorMessage = '';
    });

    try {
      final success = await _verificationService.verifyOTP(widget.phoneNumber, otp);
      if (mounted) {
        setState(() => _verifying = false);
        if (success) {
          widget.onVerificationComplete(true);
          Navigator.pop(context);
        } else {
          setState(() => _errorMessage = 'Invalid OTP. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _verifying = false;
          _errorMessage = 'Error: $e';
        });
      }
    }
  }
}
