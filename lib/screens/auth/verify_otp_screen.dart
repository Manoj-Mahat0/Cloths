import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key, this.prefilledUsername});

  final String? prefilledUsername;

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _otp = TextEditingController();
  bool _submitting = false;
  String? _error;
  bool _argsInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsInitialized) return;
    _argsInitialized = true;
    final Object? rawArg = ModalRoute.of(context)?.settings.arguments;
    final String? argFromRoute = rawArg is String ? rawArg : null;
    final String? arg = widget.prefilledUsername ?? argFromRoute;
    if (arg != null && arg.isNotEmpty) {
      _username.text = arg;
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _otp.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await AuthService().verifyOtp(username: _username.text.trim(), otp: _otp.text.trim());
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/post-login', (Route<dynamic> r) => false);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _resend() async {
    try {
      await AuthService().resendOtp(username: _username.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP resent')));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 8),
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _username,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    filled: true,
                    fillColor: const Color(0xFFF5F6FA),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _otp,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'OTP',
                    filled: true,
                    fillColor: const Color(0xFFF5F6FA),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
                  ),
                ),
                const SizedBox(height: 12),
                if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                const Spacer(),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E4DFF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _submitting ? null : _verify,
                          child: _submitting
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Verify'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(onPressed: _resend, child: const Text('Resend')),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


