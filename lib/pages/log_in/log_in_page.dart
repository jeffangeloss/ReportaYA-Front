import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'log_in_controller.dart';

class LogInPage extends StatelessWidget {
  LogInController control = Get.put(LogInController());

  LogInPage({super.key});

  Widget _buildBody(BuildContext context) {
    return SafeArea(child: Text('LogIn Page'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: null,
        body: _buildBody(context),
      );
  }
}
