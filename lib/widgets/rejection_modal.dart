import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RejectionModal {
  static Future<String?> show() async {
    final ctrl = TextEditingController();
    return Get.dialog<String>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Rechazar Reporte',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Ingrese el motivo del rechazo:',
                    style: TextStyle(fontSize: 16, color: Color(0xFF666666))),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: ctrl,
                maxLines: 3,
                minLines: 3,
                decoration: InputDecoration(
                  hintText: 'Motivo...',
                  filled: true,
                  fillColor: const Color(0xFFF9F9F9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF0F0F0),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Get.back(result: null),
                      child: const Text('Cancelar', style: TextStyle(color: Color(0xFF666666), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B6B),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        final motivo = ctrl.text.trim();
                        if (motivo.isNotEmpty) Get.back(result: motivo);
                      },
                      child: const Text('Rechazar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
