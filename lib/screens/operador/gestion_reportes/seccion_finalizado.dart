import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../widgets/app_colors.dart';
import '../../../widgets/foto_view.dart';
import '../../../widgets/common/detail_widgets.dart';

/// Sección de detalle cuando el reporte fue finalizado:
/// callout de cierre, comentario del tecnico y fotos de resolucion.
class SeccionFinalizado extends StatelessWidget {
  final ReporteResponse reporte;
  final List<Foto> fotosFinales;
  const SeccionFinalizado({
    super.key,
    required this.reporte,
    required this.fotosFinales,
  });

  @override
  Widget build(BuildContext context) {
    final r = reporte;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoCallout(
          'Reporte finalizado por ${r.tecnicoNombre ?? 'el tecnico'}.',
          color: AppColors.estadoFinalizado,
          bg: const Color(0xFFEAFAF0),
          fg: const Color(0xFF2C7A4F),
        ),
        if (r.comentarioResolucion != null &&
            r.comentarioResolucion!.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Comentario del tecnico',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF444444),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              r.comentarioResolucion!,
              style: const TextStyle(fontSize: 13.5),
            ),
          ),
        ],
        if (fotosFinales.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Fotos de la solucion',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF444444),
            ),
          ),
          const SizedBox(height: 6),
          FotosStrip(
            fotos: fotosFinales,
            vacioTexto: 'Sin fotos de resolucion',
            height: 96,
          ),
        ],
      ],
    );
  }
}
