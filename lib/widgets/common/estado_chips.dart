import 'package:flutter/material.dart';
import '../../models/enums.dart';
import '../app_colors.dart';

/// Fila horizontal de chips para filtrar por estado.
/// '' representa "Todos". Por defecto incluye los 4 estados.
class EstadoFilterChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  final List<String> estados;

  const EstadoFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
    this.estados = const [
      '',
      EstadoReporte.PENDIENTE,
      EstadoReporte.REVISION,
      EstadoReporte.FINALIZADO,
      EstadoReporte.RECHAZADO,
    ],
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 46,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          children: estados.map((c) {
            final on = selected == c;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(c.isEmpty ? 'Todos' : AppColors.textoEstado(c)),
                selected: on,
                onSelected: (_) => onSelected(c),
                selectedColor: c.isEmpty ? AppColors.primary : AppColors.forEstado(c),
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                    color: on ? Colors.white : const Color(0xFF5B5F6B), fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
        ),
      );
}
