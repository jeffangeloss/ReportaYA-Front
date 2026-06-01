import 'package:flutter/material.dart';
import '../app_colors.dart';

/// Cabecera con degradado reutilizable por todas las vistas.
/// Cubre tanto barras simples (solo titulo) como cabeceras de panel
/// (overline + titulo + subtitulo + boton de logout).
class GradientHeader extends StatelessWidget {
  final String title;
  final String? overline;
  final String? subtitle;
  final List<Color> gradient;
  final VoidCallback? onLogout;
  final bool compact;

  const GradientHeader({
    super.key,
    required this.title,
    this.overline,
    this.subtitle,
    this.gradient = AppColors.ciudadanoGradient,
    this.onLogout,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: compact
          ? const EdgeInsets.fromLTRB(16, 52, 16, 14)
          : const EdgeInsets.fromLTRB(20, 52, 20, 22),
      decoration: BoxDecoration(gradient: LinearGradient(colors: gradient)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (overline != null)
                  Text(overline!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                Text(title,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 18 : 22,
                        fontWeight: FontWeight.bold)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ],
            ),
          ),
          if (onLogout != null)
            IconButton(onPressed: onLogout, icon: const Icon(Icons.logout, color: Colors.white)),
        ],
      ),
    );
  }
}

/// Etiqueta de seccion (p. ej. "RECIENTES", "COLA DE REPORTES").
class SectionLabel extends StatelessWidget {
  final String text;
  final Color color;
  const SectionLabel(this.text, {super.key, this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Text(text,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color, letterSpacing: 1)),
      );
}
