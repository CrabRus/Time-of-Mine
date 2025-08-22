import 'package:flutter/material.dart';
import 'package:time_of_mine/services/auth_service.dart';
import 'package:time_of_mine/widgets/custom_snack_bar.dart';
import 'package:time_of_mine/widgets/simple_app_bar.dart';
import 'package:time_of_mine/widgets/custom_forms.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    String? error;
    if (_isLogin) {
      error = await AuthService.signIn(email, password);
    } else {
      error = await AuthService.signUp(
        isGuest: false,
        email: email,
        password: password,
        name: name,
      );
    }

    setState(() => _isLoading = false);

    if (error != null) {
      CustomSnackBar.show(context, message: error, isError: true);
    } else {
      CustomSnackBar.show(
        context,
        message: _isLogin ? "Welcome back!" : "Account created successfully",
        isError: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Scaffold(
          appBar: SimpleAppBar(title: _isLogin ? 'Sign In' : 'Sign Up'),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Icon(Icons.lock, size: 100, color: theme.iconTheme.color),
                    const SizedBox(height: 16),
                    if (!_isLogin) ...[
                      NameFormField(controller: _nameController),
                      const SizedBox(height: 16),
                    ],
                    EmailFormField(controller: _emailController),
                    const SizedBox(height: 16),
                    PasswordFormField(controller: _passwordController),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isLoading ? null : _submit,
                      child: Text(_isLogin ? 'Sign In' : 'Sign Up'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => setState(() => _isLogin = !_isLogin),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: theme.primaryColor),
                          children: [
                            TextSpan(
                              text: _isLogin
                                  ? "Don’t have an account? "
                                  : "Already have an account? ",
                            ),
                            TextSpan(
                              text: _isLogin ? "Sign Up" : "Sign In",
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              setState(() => _isLoading = true);
                              String? error = await AuthService.signUp(
                                isGuest: true,
                              );
                              setState(() => _isLoading = false);

                              if (error != null) {
                                CustomSnackBar.show(
                                  context,
                                  message: error,
                                  isError: true,
                                );
                              }
                            },
                      child: const Text("Sign In as guest"),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
