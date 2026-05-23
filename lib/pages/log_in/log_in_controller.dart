import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LogInController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordHidden = true;

  void togglePasswordVisibility(){
    isPasswordHidden = !isPasswordHidden;
  }

  void dispose(){
    usernameController.dispose();
    passwordController.dispose();
  }

}
