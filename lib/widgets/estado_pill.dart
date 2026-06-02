import 'package:flutter/material.dart';
import 'app_colors.dart';

class EstadoPill extends StatelessWidget {
  final String estado;
  const EstadoPill(this.estado, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.forEstado(estado),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        AppColors.textoEstado(estado).toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
