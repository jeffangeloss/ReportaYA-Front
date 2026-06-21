import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../widgets/app_colors.dart';
import '../../../widgets/common/detail_widgets.dart';
import 'seccion_finalizado.dart';

/// Sección de acciones que cambia según el estado del reporte.
///
/// PENDIENTE  → botones Aceptar / Rechazar
/// REVISION   → callout + botón Asignar/Reasignar tecnico
/// FINALIZADO → [SeccionFinalizado]
/// RECHAZADO  → callout de rechazo
class AccionesGestion extends StatelessWidget {
  final ReporteResponse reporte;
  final List<Foto> fotosFinales;
  final Future<void> Function() onAceptar;
  final VoidCallback onRechazar;
  final VoidCallback onAsignar;

  const AccionesGestion({
    super.key,
    required this.reporte,
    required this.fotosFinales,
    required this.onAceptar,
    required this.onRechazar,
    required this.onAsignar,
  });

  @override
  Widget build(BuildContext context) {
    final r = reporte;

    if (r.estado == EstadoReporte.PENDIENTE) {
      return Column(
        children: [
          WideButton(
            'Aceptar reporte',
            AppColors.estadoFinalizado,
            onAceptar,
            icon: Icons.check,
          ),
          const SizedBox(height: 10),
          WideButton(
            'Rechazar reporte',
            AppColors.estadoRechazado,
            onRechazar,
            icon: Icons.close,
            outline: true,
          ),
        ],
      );
    }

    if (r.estado == EstadoReporte.REVISION) {
      return Column(
        children: [
          InfoCallout(
            r.tieneTecnico
                ? 'Reporte en Revision. Tecnico asignado: ${r.tecnicoNombre}.'
                : 'Reporte aceptado y en Revision. Falta asignar tecnico.',
          ),
          const SizedBox(height: 10),
          WideButton(
            r.tieneTecnico ? 'Reasignar Tecnico' : 'Asignar Tecnico',
            AppColors.estadoFinalizado,
            onAsignar,
            icon: Icons.person_add_alt,
          ),
        ],
      );
    }

    if (r.estado == EstadoReporte.FINALIZADO) {
      return SeccionFinalizado(reporte: r, fotosFinales: fotosFinales);
    }

    if (r.estado == EstadoReporte.RECHAZADO) {
      return InfoCallout(
        'Rechazado: ${r.comentarioResolucion ?? '-'}',
        color: AppColors.estadoRechazado,
        bg: const Color(0xFFF3F3F5),
        fg: const Color(0xFF555555),
      );
    }

    return const SizedBox.shrink();
  }
}
