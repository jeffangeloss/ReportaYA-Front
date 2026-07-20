// lib/screens/auth/reset_password_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_toast.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../routes/app_routes.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _auth = Get.find<AuthController>();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  String? _token;
  String? _correo;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // 1. Extrae el token desde los query parameters (?token=...) o arguments
    _token = Get.parameters['token'] ?? 
        (Get.arguments is Map && (Get.arguments as Map).containsKey('token') 
            ? (Get.arguments as Map)['token'] 
            : null);
            
    // 2. Extrae el correo si se navega de forma interna
    _correo = Get.parameters['correo'] ?? 
        (Get.arguments is Map && (Get.arguments as Map).containsKey('correo') 
            ? (Get.arguments as Map)['correo'] 
            : (Get.arguments is String ? Get.arguments as String : null));
  }

  Future<void> _restablecer() async {
    final nuevaPass = _passCtrl.text;
    final confirmacion = _confirmPassCtrl.text;

    if (_token == null || _token!.isEmpty) {
      AppToast.error('Token de recuperación no válido o ausente');
      return;
    }

    if (nuevaPass.isEmpty || confirmacion.isEmpty) {
      AppToast.error('Completa todos los campos');
      return;
    }

    setState(() => _loading = true);
    try {
      await _auth.restablecerContrasena(_token!, nuevaPass, confirmacion);
      AppToast.success('Contraseña restablecida con éxito');
      await Future.delayed(const Duration(milliseconds: 600));
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      AppToast.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_token == null || _token!.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Enlace de restablecimiento inválido, incompleto o expirado.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    return GradientScaffold(
      colors: AppColors.ciudadanoGradient,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Row(
                children: [
                  Text('Establecer nueva contraseña', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    if (_correo != null && _correo!.isNotEmpty) ...[
                      Text(
                        'Restableciendo contraseña para: $_correo',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const SizedBox(height: 20),
                    ],
                    TextField(
                      controller: _passCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Nueva contraseña',
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _confirmPassCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirmar nueva contraseña',
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
                        onPressed: _loading ? null : _restablecer,
                        child: _loading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Restablecer contraseña', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
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
