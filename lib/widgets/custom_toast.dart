import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppToast {
  static void show(String message, {String type = 'info'}) {
    Color bg;
    IconData icon;
    switch (type) {
      case 'success':
        bg = const Color(0xFF4CAF50);
        icon = Icons.check_circle;
        break;
      case 'error':
        bg = const Color(0xFFF44336);
        icon = Icons.error;
        break;
      default:
        bg = const Color(0xFF2196F3);
        icon = Icons.info;
    }

    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      backgroundColor: bg,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  static void success(String message) => show(message, type: 'success');
  static void error(String message) => show(message, type: 'error');
  static void info(String message) => show(message, type: 'info');
}
