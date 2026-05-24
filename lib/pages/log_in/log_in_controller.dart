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

  void login() async {
    if (!usernameController.text.isEmpty || !passwordController.text.isEmpty){
      Account account = Account.login(username: usernameController.text, passwordHash: passwordController.text);
      GenericResponse response = await accountService.login(account);
      print("Con datos");
    }
    else{
      print("Sin datos");
      Get.snackbar(
        'Error',
        'Todos los campos son obligatorios',
      );
    }

      return;
    
  }


  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

}
