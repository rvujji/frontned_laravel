import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/navigation/app_shell.dart';
import '../auth/auth_provider.dart';
import '../auth/auth_service.dart';

class EmailVerificationRequiredPage extends ConsumerStatefulWidget {
  final bool returnToPreviousPage;

  const EmailVerificationRequiredPage({
    super.key,
    this.returnToPreviousPage = true,
  });

  @override
  ConsumerState<EmailVerificationRequiredPage> createState() =>
      _EmailVerificationRequiredPageState();
}

class _EmailVerificationRequiredPageState
    extends ConsumerState<EmailVerificationRequiredPage> {
  final AuthService _authService = AuthService();

  bool _checking = false;
  bool _resending = false;

  Future<void> _checkVerification() async {
    setState(() {
      _checking = true;
    });

    try {
      final verified = await _authService.emailVerificationStatus();

      if (!mounted) return;

      if (verified) {
        // Refresh Riverpod auth state
        await ref.read(authProvider.notifier).refreshUser();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email verified successfully.')),
        );

        if (widget.returnToPreviousPage) {
          context.pop(true);
        } else {
          context.go('/login');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email is still not verified.')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    if (mounted) {
      setState(() {
        _checking = false;
      });
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _resending = true;
    });

    try {
      await _authService.resendVerificationEmail();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Verification email sent.')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    if (mounted) {
      setState(() {
        _resending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: 550,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_user_outlined, size: 80),

                    const SizedBox(height: 24),

                    const Text(
                      'Email Verification Required',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'You must verify your email address before enrolling in workshops.',
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _checking ? null : _checkVerification,
                        child: _checking
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('I Have Verified My Email'),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _resending ? null : _resendVerificationEmail,
                        child: _resending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Resend Verification Email'),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: () {
                        context.go('/workshops');
                      },
                      child: const Text('Back To Workshops'),
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
