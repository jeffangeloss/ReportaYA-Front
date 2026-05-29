import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../models/cuenta.dart';
import '../../routes/app_routes.dart';
import '../../services/servicio_cuenta.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_toast.dart';
import '../../widgets/gradient_scaffold.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usuario = TextEditingController();
  final _nombres = TextEditingController();
  final _apellidos = TextEditingController();
  final _dni = TextEditingController();
  final _telefono = TextEditingController();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  final _repeticion = TextEditingController();
  bool _loading = false;

  bool _validar() {
    if ([_usuario, _nombres, _apellidos, _dni, _telefono, _correo, _contrasena, _repeticion]
        .any((c) => c.text.trim().isEmpty)) {
      AppToast.error('Todos los campos son obligatorios');
      return false;
    }
    if (_contrasena.text != _repeticion.text) {
      AppToast.error('Las contraseñas no coinciden');
      return false;
    }
    if (_contrasena.text.length < 6) {
      AppToast.error('La contraseña debe tener al menos 6 caracteres');
      return false;
    }
    if (_dni.text.length != 8) {
      AppToast.error('El DNI debe tener 8 dígitos');
      return false;
    }
    if (_telefono.text.length < 9) {
      AppToast.error('El teléfono debe tener al menos 9 dígitos');
      return false;
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(_correo.text.trim())) {
      AppToast.error('Ingresa un correo electrónico válido');
      return false;
    }
    return true;
  }

  Future<void> _handleRegister() async {
    if (!_validar()) return;
    setState(() => _loading = true);
    try {
      final cuenta = CrearCuentaRequest(
        tipoCuenta: 'CIUDADANO',
        usuario: _usuario.text.trim(),
        contrasena: _contrasena.text,
        nombres: _nombres.text.trim(),
        apellidos: _apellidos.text.trim(),
        dni: _dni.text.trim(),
        telefono: _telefono.text.trim(),
        correo: _correo.text.trim(),
        activo: true,
      );
      await ServicioCuenta().crearCuenta(cuenta);
      AppToast.success('¡Registro exitoso! Iniciando sesión...');
      await Future.delayed(const Duration(seconds: 1));
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      final msg = e.toString().toLowerCase();
      String txt = 'No se pudo completar el registro.';
      if (msg.contains('usuario')) {
        txt = 'El nombre de usuario ya está en uso.';
      } else if (msg.contains('correo')) {
        txt = 'El correo electrónico ya está registrado.';
      } else if (msg.contains('dni')) {
        txt = 'El DNI ya está registrado.';
      } else if (msg.contains('telefono')) {
        txt = 'El número de teléfono ya está registrado.';
      }
      AppToast.error(txt);
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
              const SizedBox(height: 20),
              const Text('ReportaYA',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
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
                        GestureDetector(
                          onTap: () => Get.offNamed(AppRoutes.login),
                          child: const Text('Iniciar Sesión',
                              style: TextStyle(fontSize: 18, color: Color(0xFF999999))),
                        ),
                        const Text('Registrarse',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFA27EFF))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _field('Usuario:', _usuario, 'Nombre de usuario único'),
                    _field('Nombres:', _nombres, 'Tus nombres'),
                    _field('Apellidos:', _apellidos, 'Tus apellidos'),
                    _field('DNI:', _dni, '12345678', keyboard: TextInputType.number, maxLen: 8),
                    _field('Teléfono:', _telefono, '987654321', keyboard: TextInputType.phone),
                    _field('Correo Electrónico:', _correo, 'tu@email.com', keyboard: TextInputType.emailAddress),
                    _field('Contraseña:', _contrasena, 'Mínimo 6 caracteres', obscure: true),
                    _field('Repite tu contraseña:', _repeticion, 'Repite tu contraseña', obscure: true),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA27EFF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _loading ? null : _handleRegister,
                      child: _loading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Registrarse',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _field(String label, TextEditingController ctrl, String hint,
      {bool obscure = false, TextInputType? keyboard, int? maxLen}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF555555))),
          ),
          TextField(
            controller: ctrl,
            obscureText: obscure,
            keyboardType: keyboard,
            autocorrect: false,
            maxLength: maxLen,
            inputFormatters: keyboard == TextInputType.number
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            decoration: InputDecoration(
              counterText: '',
              hintText: hint,
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
