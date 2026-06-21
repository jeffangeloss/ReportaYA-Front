// lib/screens/auth/recover_password_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_toast.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../routes/app_routes.dart';

class RecoverPasswordScreen extends StatefulWidget {
  const RecoverPasswordScreen({super.key});

  @override
  State<RecoverPasswordScreen> createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  final _auth = Get.find<AuthController>();
  final _correoCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _enviarSolicitud() async {
    final correo = _correoCtrl.text.trim();
    if (correo.isEmpty) {
      AppToast.error('Completa todos los campos');
      return;
    }

    setState(() => _loading = true);
    try {
      await _auth.solicitarRecuperacion(correo);
      
      // Popup para simular la llegada del correo. cambiar en entrega final
      Get.dialog(
        AlertDialog(
          title: const Text('Simulación de Correo'),
          content: Text('Se ha enviado un enlace de restablecimiento a $correo.'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // Cierra dialog
                // Redirigir a Reset Password pasando el correo
                Get.toNamed(AppRoutes.resetPassword, arguments: correo);
              },
              child: const Text('Abrir enlace'),
            )
          ],
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      AppToast.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      colors: AppColors.ciudadanoGradient,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(onPressed: Get.back, icon: const Icon(Icons.arrow_back, color: Colors.white)),
                  const Text('Recuperar contraseña', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    const Text(
                      'Ingresa el correo electrónico asociado a tu cuenta para restablecer tu contraseña.',
                      style: TextStyle(color: Color(0xFF6C757D), fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _correoCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _loading ? null : _enviarSolicitud,
                        child: _loading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Enviar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
