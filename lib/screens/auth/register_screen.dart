import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/models.dart';
import '../../services/servicio_cuenta.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_toast.dart';
import '../../widgets/gradient_scaffold.dart';

/// Vista 07 Registro (CU-02). Solo CIUDADANO. Crea la cuenta en el almacen local.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _service = ServicioCuenta();
  final _c = <String, TextEditingController>{
    for (final k in ['nombres', 'apellidos', 'dni', 'telefono', 'correo', 'usuario', 'contrasena'])
      k: TextEditingController()
  };
  bool _loading = false;

  Future<void> _registrar() async {
    for (final e in _c.entries) {
      if (e.value.text.trim().isEmpty) {
        AppToast.error('Completa todos los campos');
        return;
      }
    }
    setState(() => _loading = true);
    try {
      await _service.crearCuenta(CrearCuentaRequest(
        usuario: _c['usuario']!.text.trim(),
        contrasena: _c['contrasena']!.text,
        nombres: _c['nombres']!.text.trim(),
        apellidos: _c['apellidos']!.text.trim(),
        dni: _c['dni']!.text.trim(),
        telefono: _c['telefono']!.text.trim(),
        correo: _c['correo']!.text.trim(),
      ));
      AppToast.success('Cuenta creada! Ya puedes iniciar sesion.');
      await Future.delayed(const Duration(milliseconds: 600));
      Get.back();
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
              Row(
                children: [
                  IconButton(onPressed: Get.back, icon: const Icon(Icons.arrow_back, color: Colors.white)),
                  const Text('Crear cuenta', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    _field('nombres', 'Nombres'),
                    _field('apellidos', 'Apellidos'),
                    _field('dni', 'DNI'),
                    _field('telefono', 'Telefono'),
                    _field('correo', 'Correo electronico'),
                    _field('usuario', 'Usuario'),
                    _field('contrasena', 'Contrasena', obscure: true),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _loading ? null : _registrar,
                        child: _loading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Registrarse', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
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

  Widget _field(String key, String label, {bool obscure = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: _c[key],
          obscureText: obscure,
          decoration: InputDecoration(
            labelText: label,
            filled: true, fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
      );
}
