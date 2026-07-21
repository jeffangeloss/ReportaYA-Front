// lib/screens/auth/recover_password_screen.dart
// Paso 1 de la recuperacion de contrasena: solicitar el codigo de
// verificacion por correo. Diseno de card centrada replicado de ULIMA++
// con la paleta de ReportaYA.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_toast.dart';
import 'password_reset_ui.dart';

class RecoverPasswordScreen extends StatefulWidget {
  const RecoverPasswordScreen({super.key});

  @override
  State<RecoverPasswordScreen> createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  final _auth = Get.find<AuthController>();
  final _correoCtrl = TextEditingController();

  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _correoCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviarSolicitud() async {
    if (_loading) return;

    final correo = _correoCtrl.text.trim();
    if (correo.isEmpty) {
      setState(() => _error = 'Ingresa tu correo electronico.');
      return;
    }
    if (!GetUtils.isEmail(correo)) {
      setState(() => _error = 'Ingresa un correo electronico valido.');
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      await _auth.solicitarRecuperacion(correo);
      AppToast.success('Te enviamos un codigo a tu correo');
      Get.toNamed(AppRoutes.resetPassword, arguments: correo);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = PasswordResetPalette.from(context);

    return PasswordResetScaffold(
      palette: palette,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PasswordResetTitle(
            palette: palette,
            text: '¿Olvidaste tu contrasena?',
          ),
          const SizedBox(height: 10),
          PasswordResetSubtitle(
            palette: palette,
            text: 'Ingresa el correo electronico asociado a tu cuenta y te '
                'enviaremos un codigo de verificacion.',
          ),
          const SizedBox(height: 26),
          PasswordResetFieldLabel(
            palette: palette,
            text: 'Correo electronico',
          ),
          const SizedBox(height: 8),
          PasswordResetField(
            controller: _correoCtrl,
            palette: palette,
            hint: 'ejemplo@correo.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _enviarSolicitud(),
          ),
          PasswordResetErrorMessage(palette: palette, message: _error),
          const SizedBox(height: 28),
          PasswordResetPrimaryButton(
            palette: palette,
            label: 'Enviar codigo',
            loading: _loading,
            onPressed: _enviarSolicitud,
          ),
        ],
      ),
    );
  }
}
