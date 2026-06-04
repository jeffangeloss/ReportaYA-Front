import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reportaya/configs/generic_response.dart';
import 'package:reportaya/models/account.dart';
import 'package:reportaya/services/account_services.dart';

class LogInController extends GetxController {
  final loginFormKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordHidden = true;

  AccountService accountService = AccountService();

  void togglePasswordVisibility() {
    isPasswordHidden = !isPasswordHidden;
  }

  void login(BuildContext context) async {
    if (loginFormKey.currentState!.validate()) {
      Account account = Account.login(
        username: usernameController.text,
        passwordHash: passwordController.text,
      );
      GenericResponse<Account> response = await accountService.login(account);

      if (!context.mounted) return;

      if (response.success) {
        Navigator.pushReplacementNamed(context, '/start');
      } else {
        _showError(context, response.message);
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
