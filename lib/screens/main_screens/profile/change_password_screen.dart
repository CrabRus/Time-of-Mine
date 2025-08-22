import 'package:flutter/material.dart';
import 'package:time_of_mine/services/auth_service.dart';
import 'package:time_of_mine/widgets/custom_forms.dart';
import 'package:time_of_mine/widgets/custom_snack_bar.dart';
import 'package:time_of_mine/widgets/simple_app_bar.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final oldPass = _oldPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (newPass != confirmPass) {
      CustomSnackBar.show(context, message: "Passwords do not match", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final error = await AuthService.updatePassword(
      oldPassword: oldPass,
      newPassword: newPass,
    );

    setState(() => _isLoading = false);

    if (error != null) {
      CustomSnackBar.show(context, message: error, isError: true);
    } else {
      CustomSnackBar.show(context, message: "Password updated successfully", isError: false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: const SimpleAppBar(title: "Change Password"),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  PasswordFormField(
                    controller: _oldPasswordController,
                    labelText: "Current Password",
                  ),
                  const SizedBox(height: 16),
                  PasswordFormField(
                    controller: _newPasswordController,
                    labelText: "New Password",
                  ),
                  const SizedBox(height: 16),
                  PasswordFormField(
                    controller: _confirmPasswordController,
                    labelText: "Confirm New Password",
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _changePassword,
                    child: const Text("Save"),
                  ),
                ],
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
