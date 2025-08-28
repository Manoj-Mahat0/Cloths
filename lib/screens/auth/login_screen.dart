import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameOrEmailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _prefillUsername();
  }

  Future<void> _prefillUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? saved = prefs.getString('username');
    if (saved != null && saved.isNotEmpty) {
      _usernameOrEmailController.text = saved;
    }
  }

  @override
  void dispose() {
    _usernameOrEmailController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final bool sent = await AuthService().requestOtp(
        usernameOrEmail: _usernameOrEmailController.text.trim(),
      );
      if (!mounted) return;
      if (sent) {
        final bool? verified = await _openOtpSheet(username: _usernameOrEmailController.text.trim());
        if (verified == true && mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/post-login', (Route<dynamic> r) => false);
        }
      } else {
        setState(() => _error = 'Failed to send OTP.');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  InputDecoration _inputDecoration(String label, {Widget? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF5F6FA),
      prefixIcon: prefixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
    );
  }

  Future<bool?> _openOtpSheet({required String username}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext ctx) => _OtpSheet(username: username),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool canSubmit = _usernameOrEmailController.text.trim().isNotEmpty && !_submitting;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 10),
                    const _LogoMark(),
                    const SizedBox(height: 18),
                    Text('Login to your account', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text("Welcome back, we have missed you!", style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF7C7C7C))),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _usernameOrEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration('Username or Email', prefixIcon: const Icon(Icons.person_outline)),
                      onChanged: (_) => setState(() {}),
                      validator: (String? v) => (v == null || v.trim().isEmpty) ? 'Enter username or email' : null,
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red)),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E4DFF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: canSubmit ? () {
                          if (_formKey.currentState!.validate()) _requestOtp();
                        } : null,
                        child: _submitting
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Login with OTP'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text("Don't have an account? "),
                        TextButton(
                          onPressed: () => Navigator.of(context).pushNamed('/auth/signup'),
                          child: const Text('Sign up'),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF2E4DFF), width: 2)),
          alignment: Alignment.center,
          child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF2E4DFF), shape: BoxShape.circle)),
        ),
        const SizedBox(width: 10),
        Text('VOGUEO', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

// Removed non-functional social buttons for a production-only experience

class _OtpSheet extends StatefulWidget {
  const _OtpSheet({required this.username});

  final String username;

  @override
  State<_OtpSheet> createState() => _OtpSheetState();
}

class _OtpSheetState extends State<_OtpSheet> {
  final TextEditingController _otp = TextEditingController();
  bool _verifying = false;
  bool _resending = false;
  String? _error;

  InputDecoration _otpDecoration() {
    return InputDecoration(
      labelText: 'OTP',
      filled: true,
      fillColor: const Color(0xFFF5F6FA),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
    );
  }

  Future<void> _verify() async {
    setState(() {
      _verifying = true;
      _error = null;
    });
    try {
      await AuthService().verifyOtp(username: widget.username, otp: _otp.text.trim());
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = 'Invalid code or error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      await AuthService().resendOtp(username: widget.username);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP resent')));
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets viewInsets = MediaQuery.of(context).viewInsets;
    final bool canVerify = _otp.text.trim().length >= 6 && !_verifying;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 14), decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(40))),
              ),
              Text('Enter OTP', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('Code sent to ${widget.username}', style: const TextStyle(color: Color(0xFF7C7C7C))),
              const SizedBox(height: 16),
              TextField(
                controller: _otp,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: _otpDecoration().copyWith(counterText: ''),
                onChanged: (_) => setState(() {}),
              ),
              if (_error != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(_error!, style: const TextStyle(color: Colors.red))),
              const SizedBox(height: 12),
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
                        onPressed: canVerify ? _verify : null,
                        child: _verifying
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Verify'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: _resending ? null : _resend,
                    child: _resending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Resend'),
                  )
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}


