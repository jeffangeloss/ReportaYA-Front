// lib/screens/auth/reset_password_screen.dart
// Paso 2 de la recuperacion de contrasena, en dos sub-pasos para enfocar una
// tarea por pantalla: (1) codigo de verificacion, (2) nueva contrasena.
// Diseno replicado de ULIMA++ con la paleta de ReportaYA. El codigo de
// ReportaYA es alfanumerico de 6 caracteres en mayusculas (ej. "A3F9K2").

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_toast.dart';
import 'password_reset_ui.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  static const int _resendCooldownSeconds = 60;

  final _auth = Get.find<AuthController>();
  final _codigoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  late final String _correo;

  /// Sub-paso visible: 0 = codigo, 1 = nueva contrasena.
  int _step = 0;

  String? _error;
  bool _loading = false;
  bool _resending = false;
  bool _passwordVisible = false;
  bool _confirmVisible = false;

  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _correo = (Get.arguments is String) ? Get.arguments as String : '';
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _codigoCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  // --- Sub-paso 1 -> 2: valida el codigo localmente y avanza. ---
  void _continuarAPassword() {
    final codigo = _codigoCtrl.text.trim();
    if (codigo.length < kResetCodeLength) {
      setState(() => _error =
          'El codigo debe tener $kResetCodeLength caracteres.');
      return;
    }
    setState(() {
      _error = null;
      _step = 1;
    });
  }

  // --- Sub-paso 2 -> 1 (flecha atras o codigo rechazado por el backend). ---
  void _volverACodigo() {
    setState(() {
      _error = null;
      _step = 0;
    });
  }

  Future<void> _restablecer() async {
    if (_loading) return;

    final codigo = _codigoCtrl.text.trim();
    final nuevaPass = _passCtrl.text;
    final confirmacion = _confirmPassCtrl.text;

    if (nuevaPass.length < kMinPasswordLength) {
      setState(() => _error =
          'La contrasena debe tener al menos $kMinPasswordLength caracteres.');
      return;
    }
    if (nuevaPass != confirmacion) {
      setState(() => _error = 'Las contrasenas no coinciden.');
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      await _auth.restablecerContrasena(codigo, nuevaPass, confirmacion);
      AppToast.success('Contrasena restablecida con exito');
      await Future.delayed(const Duration(milliseconds: 600));
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _error = msg;
        // Si el backend rechaza el codigo, regresar al sub-paso del codigo
        // para corregirlo o reenviarlo, con el error visible ahi.
        if (_esErrorDeCodigo(msg)) _step = 0;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _esErrorDeCodigo(String msg) {
    final m = msg.toLowerCase();
    return m.contains('codigo') ||
        m.contains('token') ||
        m.contains('expir') ||
        m.contains('invalid') ||
        m.contains('valid');
  }

  Future<void> _reenviarCodigo() async {
    if (_resendCooldown > 0 || _resending || _loading) return;
    if (_correo.isEmpty) {
      setState(() => _error = 'No se pudo reenviar el codigo. Vuelve a empezar.');
      return;
    }

    setState(() {
      _error = null;
      _resending = true;
    });

    try {
      await _auth.solicitarRecuperacion(_correo);
      _iniciarCooldown();
      AppToast.success('Codigo reenviado a tu correo');
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  void _iniciarCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _resendCooldown = _resendCooldownSeconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendCooldown <= 1) {
          _resendCooldown = 0;
          timer.cancel();
        } else {
          _resendCooldown--;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = PasswordResetPalette.from(context);

    if (_correo.isEmpty) {
      return PasswordResetScaffold(
        palette: palette,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PasswordResetTitle(palette: palette, text: 'Acceso invalido'),
            const SizedBox(height: 10),
            PasswordResetSubtitle(
              palette: palette,
              text: 'Vuelve a solicitar el codigo de recuperacion.',
            ),
            const SizedBox(height: 24),
            PasswordResetPrimaryButton(
              palette: palette,
              label: 'Volver',
              loading: false,
              onPressed: () => Get.offAllNamed(AppRoutes.recoverPassword),
            ),
          ],
        ),
      );
    }

    return PasswordResetScaffold(
      palette: palette,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: _step == 0
            ? _buildCodigoStep(palette, key: const ValueKey('code-step'))
            : _buildPasswordStep(palette, key: const ValueKey('password-step')),
      ),
    );
  }

  // --- Sub-paso 1: codigo de verificacion (+ reenviar). ---
  Widget _buildCodigoStep(PasswordResetPalette palette, {required Key key}) {
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PasswordResetTitle(palette: palette, text: 'Verifica tu correo'),
        const SizedBox(height: 10),
        PasswordResetSubtitle(
          palette: palette,
          text: 'Ingresa el codigo de $kResetCodeLength caracteres que '
              'enviamos a ${maskEmail(_correo)}.',
        ),
        const SizedBox(height: 26),
        PasswordResetFieldLabel(
          palette: palette,
          text: 'Codigo de verificacion',
        ),
        const SizedBox(height: 8),
        PasswordResetCodeField(
          controller: _codigoCtrl,
          palette: palette,
          onCompleted: (_) => setState(() {}),
        ),
        PasswordResetErrorMessage(palette: palette, message: _error),
        const SizedBox(height: 28),
        PasswordResetPrimaryButton(
          palette: palette,
          label: 'Continuar',
          loading: false,
          onPressed: _continuarAPassword,
        ),
        const SizedBox(height: 8),
        _buildReenviarLink(palette),
      ],
    );
  }

  Widget _buildReenviarLink(PasswordResetPalette palette) {
    final enabled = _resendCooldown == 0 && !_resending;
    final label = _resending
        ? 'Reenviando...'
        : _resendCooldown > 0
            ? 'Reenviar codigo (${_resendCooldown}s)'
            : 'Reenviar codigo';

    return Center(
      child: TextButton(
        onPressed: enabled ? _reenviarCodigo : null,
        style: TextButton.styleFrom(
          foregroundColor: palette.focusedFieldLine,
          disabledForegroundColor: palette.fieldHint,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // --- Sub-paso 2: nueva contrasena y confirmacion. ---
  Widget _buildPasswordStep(PasswordResetPalette palette, {required Key key}) {
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: _volverACodigo,
              icon: Icon(Icons.arrow_back, size: 20, color: palette.fieldHint),
              splashRadius: 18,
              tooltip: 'Cambiar codigo',
            ),
            Expanded(
              child: PasswordResetTitle(
                palette: palette,
                text: 'Crea tu nueva contrasena',
              ),
            ),
            // Equilibra el ancho del IconButton para centrar el titulo.
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 10),
        PasswordResetSubtitle(
          palette: palette,
          text: 'Usa al menos $kMinPasswordLength caracteres.',
        ),
        const SizedBox(height: 26),
        PasswordResetFieldLabel(palette: palette, text: 'Nueva contrasena'),
        const SizedBox(height: 8),
        PasswordResetField(
          controller: _passCtrl,
          palette: palette,
          hint: 'Minimo $kMinPasswordLength caracteres',
          obscureText: !_passwordVisible,
          textInputAction: TextInputAction.next,
          suffixIcon: PasswordVisibilityToggle(
            palette: palette,
            visible: _passwordVisible,
            onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
          ),
        ),
        const SizedBox(height: 18),
        PasswordResetFieldLabel(palette: palette, text: 'Confirmar contrasena'),
        const SizedBox(height: 8),
        PasswordResetField(
          controller: _confirmPassCtrl,
          palette: palette,
          hint: 'Repite la nueva contrasena',
          obscureText: !_confirmVisible,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _restablecer(),
          suffixIcon: PasswordVisibilityToggle(
            palette: palette,
            visible: _confirmVisible,
            onPressed: () => setState(() => _confirmVisible = !_confirmVisible),
          ),
        ),
        PasswordResetErrorMessage(palette: palette, message: _error),
        const SizedBox(height: 28),
        PasswordResetPrimaryButton(
          palette: palette,
          label: 'Confirmar',
          loading: _loading,
          onPressed: _restablecer,
        ),
      ],
    );
  }
}
