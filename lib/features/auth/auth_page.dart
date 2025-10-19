import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final AuthService _authService = AuthService();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_error != null) ...[
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                  ],
                  ElevatedButton.icon(
                    /* icon: Image.asset(
                      'assets/google_logo.png',
                      height: 24,
                      width: 24,
                    ), */
                    label: const Text('Sign in with Google'),
                    onPressed: () async {
                      setState(() {
                        _loading = true;
                        _error = null;
                      });
                      try {
                        await _authService.signInWithGoogle();
                      } catch (e) {
                        setState(() {
                          _error = 'Sign in failed: $e';
                        });
                      } finally {
                        setState(() {
                          _loading = false;
                        });
                      }
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
