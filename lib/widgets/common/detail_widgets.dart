import 'package:flutter/material.dart';
import '../app_colors.dart';

/// Fila clave-valor usada en los detalles (Detalle, Gestion, Informacion).
class KeyValue extends StatelessWidget {
  final String k;
  final String v;
  const KeyValue(this.k, this.v, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(k, style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280))),
            const SizedBox(height: 2),
            Text(v, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500)),
          ],
        ),
      );
}

/// Aviso/callout con barra lateral de color.
class InfoCallout extends StatelessWidget {
  final String text;
  final Color color;
  final Color? bg;
  final Color? fg;
  const InfoCallout(this.text, {super.key, this.color = AppColors.primary, this.bg, this.fg});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg ?? const Color(0xFFEFEAFF),
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Text(text, style: TextStyle(fontSize: 12.5, color: fg ?? const Color(0xFF4A3F7A))),
      );
}

/// Tarjeta blanca contenedora con padding estandar.
class WhiteCard extends StatelessWidget {
  final List<Widget> children;
  const WhiteCard(this.children, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );
}

/// Boton de ancho completo (relleno o contorno) reutilizable.
class WideButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool outline;
  const WideButton(this.text, this.color, this.onTap, {super.key, this.icon, this.outline = false});

  @override
  Widget build(BuildContext context) {
    final child = Text(text,
        style: TextStyle(
            color: outline ? color : Colors.white, fontWeight: FontWeight.bold, fontSize: 15));
    final style = outline
        ? OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))
        : ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)));
    return SizedBox(
      width: double.infinity,
      child: icon != null
          ? (outline
              ? OutlinedButton.icon(style: style, onPressed: onTap, icon: Icon(icon, size: 20), label: child)
              : ElevatedButton.icon(style: style, onPressed: onTap, icon: Icon(icon, color: Colors.white, size: 20), label: child))
          : (outline
              ? OutlinedButton(style: style, onPressed: onTap, child: child)
              : ElevatedButton(style: style, onPressed: onTap, child: child)),
    );
  }
}
