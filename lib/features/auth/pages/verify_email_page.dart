import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/navigation/app_shell.dart';
import '../auth_service.dart';

class VerifyEmailPage extends StatefulWidget {
  final String id;
  final String hash;
  final String expires;
  final String signature;

  const VerifyEmailPage({
    super.key,
    required this.id,
    required this.hash,
    required this.expires,
    required this.signature,
  });

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final AuthService _authService = AuthService();

  bool _loading = true;
  bool _success = false;

  String? _message;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _verifyEmail());
  }

  Future<void> _verifyEmail() async {
    try {
      await _authService.verifyEmail(
        id: widget.id,
        hash: widget.hash,
        expires: widget.expires,
        signature: widget.signature,
      );

      if (!mounted) return;

      setState(() {
        _success = true;
        _loading = false;

        _message = 'Your email has been verified successfully.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _success = false;
        _loading = false;

        _message = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: Center(
        child: SizedBox(
          width: 550,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_loading) ...[
                    const CircularProgressIndicator(),

                    const SizedBox(height: 24),

                    const Text(
                      'Verifying your email...',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else if (_success) ...[
                    const Icon(Icons.verified, size: 80, color: Colors.green),

                    const SizedBox(height: 24),

                    const Text(
                      'Email Verified',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(_message ?? '', textAlign: TextAlign.center),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.go('/login');
                        },
                        child: const Text('Go To Login'),
                      ),
                    ),
                  ] else ...[
                    const Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red,
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Verification Failed',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      _message ?? 'Verification link is invalid or expired.',
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.go('/login');
                        },
                        child: const Text('Go To Login'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
