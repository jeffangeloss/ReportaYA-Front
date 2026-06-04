import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reportaya/configs/generic_response.dart';
import 'package:reportaya/models/account.dart';
import 'package:reportaya/services/account_services.dart';

class RegisterController extends GetxController {
  final registerFormKey = GlobalKey<FormState>();

  final nombresController = TextEditingController();
  final apellidosController = TextEditingController();
  final dniController = TextEditingController();
  final telefonoController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordHidden = true;

  AccountService accountService = AccountService();

  void togglePasswordVisibility() {
    isPasswordHidden = !isPasswordHidden;
    update();
  }

  void register(BuildContext context) async {
    if (registerFormKey.currentState!.validate()) {
      Account account = Account(
        id: 0,
        username: usernameController.text,
        passwordHash: passwordController.text,
        active: true,
      );

      GenericResponse<Account> response = await accountService.register(account);

      if (!context.mounted) return;

      if (response.success) {
        _showSuccess(context, 'Cuenta creada exitosamente');
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacementNamed(context, '/log-in');
        });
      } else {
        _showError(context, response.message);
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.red,
    ));
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.green,
    ));
  }

  @override
  void onClose() {
    nombresController.dispose();
    apellidosController.dispose();
    dniController.dispose();
    telefonoController.dispose();
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
