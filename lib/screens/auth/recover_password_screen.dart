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
  bool _enviado = false;
  String _correoIngresado = '';

  Future<void> _enviarSolicitud() async {
    final correo = _correoCtrl.text.trim();
    if (correo.isEmpty) {
      AppToast.error('Completa todos los campos');
      return;
    }

    setState(() => _loading = true);
    try {
      await _auth.solicitarRecuperacion(correo);
      setState(() {
        _enviado = true;
        _correoIngresado = correo;
      });
      AppToast.success('Correo enviado con éxito');
    } catch (e) {
      AppToast.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _reenviarCorreo() async {
    if (_correoIngresado.isEmpty) return;
    setState(() => _loading = true);
    try {
      await _auth.solicitarRecuperacion(_correoIngresado);
      AppToast.success('Correo reenviado con éxito');
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
                  IconButton(
                    onPressed: () {
                      if (_enviado) {
                        setState(() {
                          _enviado = false;
                        });
                      } else {
                        Get.back();
                      }
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Text(
                    _enviado ? 'Verifica tu bandeja' : 'Recuperar contraseña',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: _enviado ? _buildSuccessView() : _buildRequestForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildRequestForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ingresa el correo electrónico asociado a tu cuenta para recibir un enlace de restablecimiento.',
          style: TextStyle(color: Color(0xFF6C757D), fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _correoCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Correo electrónico',
            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _loading ? null : _enviarSolicitud,
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'Enviar enlace',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
        ),
      ],
    );
  }
  Widget _buildSuccessView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: Color(0xFF2E7D32),
            size: 48,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '¡Correo enviado con éxito!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212529),
          ),
        ),
        const SizedBox(height: 12),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(color: Color(0xFF6C757D), fontSize: 14, height: 1.5),
            children: [
              const TextSpan(text: 'Hemos enviado las instrucciones para restablecer tu contraseña al correo '),
              TextSpan(
                text: _correoIngresado,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const TextSpan(text: '. Revisa tu bandeja de entrada.'),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Get.offAllNamed(AppRoutes.login),
            child: const Text(
              'Volver al inicio de sesión',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: _loading ? null : _reenviarCorreo,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                )
              : const Text(
                  '¿No recibiste el correo? Reenviar correo',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
        ),
      ],
    );
  }
}
