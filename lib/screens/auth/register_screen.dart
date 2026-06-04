import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/models.dart';
import '../../routes/app_routes.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _service = ServicioCuenta();
  final _c = <String, TextEditingController>{
    for (final k in ['nombres', 'apellidos', 'dni', 'telefono', 'correo', 'usuario', 'contrasena'])
      k: TextEditingController()
  };
  bool _loading = false;

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

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
      Get.offAllNamed(AppRoutes.login);
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _field('nombres', 'Nombres', validator: (v) => v!.trim().isEmpty ? 'Requerido' : null),
                      _field('apellidos', 'Apellidos', validator: (v) => v!.trim().isEmpty ? 'Requerido' : null),
                      _field('dni', 'DNI', keyboardType: TextInputType.number, validator: (v) {
                        if (v!.trim().isEmpty) return 'Requerido';
                        if (v.trim().length != 8 || int.tryParse(v.trim()) == null) return 'Debe tener 8 dígitos numéricos';
                        return null;
                      }),
                      _field('telefono', 'Teléfono', keyboardType: TextInputType.phone, validator: (v) {
                        if (v!.trim().isEmpty) return 'Requerido';
                        if (v.trim().length != 9 || int.tryParse(v.trim()) == null) return 'Debe tener 9 dígitos numéricos';
                        return null;
                      }),
                      _field('correo', 'Correo electrónico', keyboardType: TextInputType.emailAddress, validator: (v) {
                        if (v!.trim().isEmpty) return 'Requerido';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) return 'Correo inválido';
                        return null;
                      }),
                      _field('usuario', 'Usuario', validator: (v) => v!.trim().isEmpty ? 'Requerido' : null),
                      _field('contrasena', 'Contraseña', obscure: true, validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String key, String label, {bool obscure = false, String? Function(String?)? validator, TextInputType? keyboardType}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: _c[key],
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            filled: true, fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
      );
}
