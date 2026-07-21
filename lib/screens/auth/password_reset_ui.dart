// lib/screens/auth/password_reset_ui.dart
// Paleta y widgets compartidos por el flujo de recuperacion de contrasena.
// Replica el diseno de la app ULIMA++ (card centrada, campos en caja, codigo
// en casillas y flujo por sub-pasos) adaptado a la identidad de ReportaYA:
// gradiente violeta -> lila, card blanca y color primario #A27EFF.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show
        FilteringTextInputFormatter,
        LengthLimitingTextInputFormatter,
        TextInputFormatter,
        TextEditingValue;

import '../../configs/colors.dart';

/// Longitud del codigo de verificacion (6 caracteres alfanumericos).
const int kResetCodeLength = 6;

/// Minimo de caracteres de la nueva contrasena (alineado al backend).
const int kMinPasswordLength = 6;

/// Fuerza el texto a mayusculas: el backend genera el codigo en mayusculas
/// (ej. "A3F9K2"), asi que lo normalizamos mientras el usuario escribe.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

/// Enmascara un correo para mostrarlo en la pantalla del codigo:
/// "jeff.angelo@gmail.com" -> "je******@gmail.com".
String maskEmail(String email) {
  final at = email.indexOf('@');
  if (at <= 0) return email;
  final user = email.substring(0, at);
  final domain = email.substring(at);
  if (user.length <= 2) return '${user[0]}***$domain';
  return '${user.substring(0, 2)}${'*' * (user.length - 2)}$domain';
}

/// Paleta del flujo, con soporte claro/oscuro. La app corre en claro, pero se
/// deja la variante oscura por robustez y para respetar el diseno original.
class PasswordResetPalette {
  const PasswordResetPalette({
    required this.backgroundGradient,
    required this.card,
    required this.cardBorder,
    required this.cardShadow,
    required this.fieldText,
    required this.fieldHint,
    required this.fieldFill,
    required this.focusedFieldLine,
    required this.cursor,
    required this.error,
    required this.buttonBackground,
    required this.buttonForeground,
    required this.disabledButtonBackground,
    required this.disabledButtonForeground,
    required this.backIcon,
  });

  factory PasswordResetPalette.from(BuildContext context) {
    final isDark = Theme.brightnessOf(context) == Brightness.dark;

    if (isDark) {
      return const PasswordResetPalette(
        backgroundGradient: [Color(0xFF2A2440), Color(0xFF1C1830)],
        card: Color(0xFF241F33),
        cardBorder: Color(0xFF362E4D),
        cardShadow: Color(0x99000000),
        fieldText: Color(0xFFF4F4F4),
        fieldHint: Color(0xFF9A93B0),
        fieldFill: Color(0xFF2E2842),
        focusedFieldLine: Color(0xFFC6A9FF),
        cursor: Color(0xFFC6A9FF),
        error: Color(0xFFFF6B6B),
        buttonBackground: AppColors.primary,
        buttonForeground: Colors.white,
        disabledButtonBackground: Color(0x66A27EFF),
        disabledButtonForeground: Color(0xFFCFCFCF),
        backIcon: Colors.white,
      );
    }

    return const PasswordResetPalette(
      // Mismo gradiente que la pantalla de login para unificar el modulo auth.
      backgroundGradient: [Color(0xFFA27EFF), Color(0xFFD4C4FF), Colors.white],
      card: Colors.white,
      cardBorder: Colors.transparent,
      cardShadow: Color(0x22000000),
      fieldText: AppColors.textPrimary,
      fieldHint: Color(0xFF9B9B9B),
      fieldFill: Color(0xFFF5F5F5),
      focusedFieldLine: AppColors.primary,
      cursor: AppColors.primary,
      error: AppColors.error,
      buttonBackground: AppColors.primary,
      buttonForeground: Colors.white,
      disabledButtonBackground: Color(0x99A27EFF),
      disabledButtonForeground: Colors.white,
      backIcon: Colors.white,
    );
  }

  final List<Color> backgroundGradient;
  final Color card;
  final Color cardBorder;
  final Color cardShadow;
  final Color fieldText;
  final Color fieldHint;
  final Color fieldFill;
  final Color focusedFieldLine;
  final Color cursor;
  final Color error;
  final Color buttonBackground;
  final Color buttonForeground;
  final Color disabledButtonBackground;
  final Color disabledButtonForeground;
  final Color backIcon;
}

/// Scaffold comun del flujo: fondo con gradiente, flecha de retorno y card
/// centrada con sombra.
class PasswordResetScaffold extends StatelessWidget {
  const PasswordResetScaffold({
    super.key,
    required this.palette,
    required this.child,
    this.onBack,
  });

  final PasswordResetPalette palette;
  final Widget child;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: palette.backgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: palette.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: palette.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: palette.cardShadow,
                            blurRadius: 32,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 34, 28, 30),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                left: 4,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: palette.backIcon),
                  tooltip: 'Volver',
                  onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Titulo grande centrado dentro de la card.
class PasswordResetTitle extends StatelessWidget {
  const PasswordResetTitle({
    super.key,
    required this.palette,
    required this.text,
  });

  final PasswordResetPalette palette;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: palette.fieldText,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

/// Subtitulo/explicacion bajo el titulo.
class PasswordResetSubtitle extends StatelessWidget {
  const PasswordResetSubtitle({
    super.key,
    required this.palette,
    required this.text,
  });

  final PasswordResetPalette palette;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: palette.fieldHint,
        fontSize: 12.5,
        height: 1.5,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// Etiqueta de un grupo label + campo (a 8px de su campo, por proximidad).
class PasswordResetFieldLabel extends StatelessWidget {
  const PasswordResetFieldLabel({
    super.key,
    required this.palette,
    required this.text,
  });

  final PasswordResetPalette palette;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: palette.fieldText,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    );
  }
}

/// Campo de texto en caja (filled, 12px de radio, borde violeta al enfocar).
class PasswordResetField extends StatelessWidget {
  const PasswordResetField({
    super.key,
    required this.controller,
    required this.palette,
    required this.hint,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.obscureText = false,
    this.onSubmitted,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final PasswordResetPalette palette;
  final String hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      onSubmitted: onSubmitted,
      autocorrect: false,
      enableSuggestions: false,
      cursorColor: palette.cursor,
      style: TextStyle(
        color: palette.fieldText,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: palette.fieldHint,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: palette.fieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.focusedFieldLine, width: 2),
        ),
      ),
    );
  }
}

/// Codigo de verificacion en casillas individuales. Un TextField invisible
/// extendido sobre las casillas conserva el teclado, el pegado y el
/// TextEditingController; las casillas solo pintan los caracteres actuales.
/// A diferencia de un OTP numerico, acepta 6 caracteres ALFANUMERICOS en
/// mayusculas (formato del codigo de ReportaYA, ej. "A3F9K2").
class PasswordResetCodeField extends StatefulWidget {
  const PasswordResetCodeField({
    super.key,
    required this.controller,
    required this.palette,
    this.length = kResetCodeLength,
    this.onCompleted,
  });

  final TextEditingController controller;
  final PasswordResetPalette palette;
  final int length;
  final ValueChanged<String>? onCompleted;

  @override
  State<PasswordResetCodeField> createState() => _PasswordResetCodeFieldState();
}

class _PasswordResetCodeFieldState extends State<PasswordResetCodeField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleValueChanged);
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(covariant PasswordResetCodeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleValueChanged);
      widget.controller.addListener(_handleValueChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleValueChanged);
    _focusNode.dispose();
    super.dispose();
  }

  /// Mantiene el cursor al final para que escribir agregue el siguiente
  /// caracter (auto-avance) y retroceso borre el ultimo.
  void _handleValueChanged() {
    final endSelection = TextSelection.collapsed(
      offset: widget.controller.text.length,
    );
    if (widget.controller.selection != endSelection) {
      widget.controller.selection = endSelection;
    }
    if (widget.controller.text.length == widget.length) {
      widget.onCompleted?.call(widget.controller.text);
    }
    if (mounted) setState(() {});
  }

  void _handleFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text;
    final activeIndex =
        text.length < widget.length ? text.length : widget.length - 1;

    return Stack(
      children: [
        Row(
          children: [
            for (var i = 0; i < widget.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: _CodeBox(
                  palette: widget.palette,
                  char: i < text.length ? text[i] : '',
                  active: _focusNode.hasFocus && i == activeIndex,
                ),
              ),
            ],
          ],
        ),
        Positioned.fill(
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
              UpperCaseTextFormatter(),
              LengthLimitingTextInputFormatter(widget.length),
            ],
            showCursor: false,
            cursorWidth: 0,
            style: const TextStyle(color: Colors.transparent, fontSize: 1),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox({
    required this.palette,
    required this.char,
    required this.active,
  });

  final PasswordResetPalette palette;
  final String char;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: palette.fieldFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active ? palette.focusedFieldLine : Colors.transparent,
          width: 2,
        ),
      ),
      child: Text(
        char,
        style: TextStyle(
          color: palette.fieldText,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Boton principal del flujo, con spinner mientras se envia la solicitud.
class PasswordResetPrimaryButton extends StatelessWidget {
  const PasswordResetPrimaryButton({
    super.key,
    required this.palette,
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final PasswordResetPalette palette;
  final String label;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.buttonBackground,
          foregroundColor: palette.buttonForeground,
          disabledBackgroundColor: palette.disabledButtonBackground,
          disabledForegroundColor: palette.disabledButtonForeground,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: loading
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: palette.buttonForeground,
                  strokeWidth: 2.2,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}

/// Mensaje de error centrado bajo los campos.
class PasswordResetErrorMessage extends StatelessWidget {
  const PasswordResetErrorMessage({
    super.key,
    required this.palette,
    required this.message,
  });

  final PasswordResetPalette palette;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final msg = message;
    if (msg == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: palette.error,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Toggle de mostrar/ocultar contrasena para el suffix de un campo.
class PasswordVisibilityToggle extends StatelessWidget {
  const PasswordVisibilityToggle({
    super.key,
    required this.palette,
    required this.visible,
    required this.onPressed,
  });

  final PasswordResetPalette palette;
  final bool visible;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 20,
        color: palette.fieldHint,
      ),
      onPressed: onPressed,
      splashRadius: 18,
    );
  }
}
