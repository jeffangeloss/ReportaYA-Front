import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../models/enums.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_toast.dart';
import '../../widgets/gradient_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usuarioCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _handleLogin() async {
    final usuario = _usuarioCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (usuario.isEmpty || password.isEmpty) {
      AppToast.error('Todos los campos son obligatorios');
      return;
    }
    setState(() => _loading = true);
    try {
      final auth = Get.find<AuthController>();
      final response = await auth.login(usuario, password);
      AppToast.success(response.message.isNotEmpty ? response.message : '¡Inicio de sesión exitoso!');
      await Future.delayed(const Duration(milliseconds: 500));
      switch (response.tipoCuenta) {
        case TipoCuenta.OPERADOR_MUNICIPAL:
          Get.offAllNamed(AppRoutes.homeOperador);
          break;
        case TipoCuenta.TECNICO:
          Get.offAllNamed(AppRoutes.homeTecnico);
          break;
        default:
          Get.offAllNamed(AppRoutes.mainTabs);
      }
    } catch (e) {
      AppToast.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
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
              const SizedBox(height: 30),
              const Text('ReportaYA',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text('Iniciar Sesión',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFA27EFF))),
                        GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.register),
                          child: const Text('Registrarse',
                              style: TextStyle(fontSize: 18, color: Color(0xFF999999))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const _Label('Usuario:'),
                    _input(_usuarioCtrl, 'Ingresa tu usuario'),
                    const SizedBox(height: 12),
                    const _Label('Contraseña:'),
                    _input(_passwordCtrl, 'Ingresa tu contraseña', obscure: true),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA27EFF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _loading ? null : _handleLogin,
                      child: _loading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Iniciar Sesión',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.recoverPassword),
                      child: const Text('¿Olvidaste tu contraseña?',
                          style: TextStyle(color: Color(0xFFA27EFF))),
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

  Widget _input(TextEditingController ctrl, String hint, {bool obscure = false}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      autocorrect: false,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF555555))),
      );
}
