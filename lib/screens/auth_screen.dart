import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:to_do_flutter/services/auth_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isSignUp = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isSignUp) {
        await _authService.signUp(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await _authService.signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('An unexpected error occurred.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Image.asset(
                    'assets/velo_logo.png',
                    height: 80,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _isSignUp ? 'Create an Account' : 'Welcome Back',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSignUp
                        ? 'Velo: Accelerate your productivity with AI.'
                        : 'Sign in to jump right back in',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFB3B3B3),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    cursorColor: const Color(0xFF00F2FF),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Color(0xFFB3B3B3)),
                      prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFB3B3B3)),
                      filled: true,
                      fillColor: const Color(0xFF161616),
                      border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(14)),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(14)),
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF00F2FF), width: 1.5), borderRadius: BorderRadius.circular(14)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    cursorColor: const Color(0xFF00F2FF),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Color(0xFFB3B3B3)),
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFB3B3B3)),
                      filled: true,
                      fillColor: const Color(0xFF161616),
                      border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(14)),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(14)),
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF00F2FF), width: 1.5), borderRadius: BorderRadius.circular(14)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  if (_isSignUp) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      cursorColor: const Color(0xFF00F2FF),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: const TextStyle(color: Color(0xFFB3B3B3)),
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFB3B3B3)),
                        filled: true,
                        fillColor: const Color(0xFF161616),
                        border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(14)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(14)),
                        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF00F2FF), width: 1.5), borderRadius: BorderRadius.circular(14)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isLoading ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF00F2FF),
                      foregroundColor: const Color(0xFF000000),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 4,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Text(_isSignUp ? 'Sign Up' : 'Sign In'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _toggleMode,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFB3B3B3),
                    ),
                    child: Text(
                      _isSignUp
                          ? 'Already have an account? Sign In'
                          : 'Don\'t have an account? Sign Up',
                    ),
                  ),
                ].animate(interval: 100.ms).fade(duration: 400.ms).slideY(begin: 0.2, end: 0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
