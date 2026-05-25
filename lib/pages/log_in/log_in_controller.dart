import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reportaya/configs/generic_response.dart';
import 'package:reportaya/models/account.dart';
import 'package:reportaya/services/account_services.dart';

class LogInController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordHidden = true;

  AccountService accountService = AccountService();

  void togglePasswordVisibility() {
    isPasswordHidden = !isPasswordHidden;
  }

  void login(BuildContext context) async {
    if (usernameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
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
    } else {
      _showError(context, 'Todos los campos son obligatorios');
    }

    return;
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
