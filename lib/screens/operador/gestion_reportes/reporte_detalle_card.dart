import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../utils/fechas.dart';
import '../../../widgets/app_colors.dart';
import '../../../widgets/estado_pill.dart';
import '../../../widgets/common/detail_widgets.dart';

/// Tarjeta con el detalle informativo del reporte (estado, titulo, key-values).
class ReporteDetalleCard extends StatelessWidget {
  final ReporteResponse reporte;
  const ReporteDetalleCard({super.key, required this.reporte});

  @override
  Widget build(BuildContext context) {
    final r = reporte;
    return WhiteCard([
      Row(
        children: [
          EstadoPill(r.estado),
          const Spacer(),
          Text(
            '#${r.id}',
            style: const TextStyle(color: Color(0xFF9AA0AB)),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Icon(
            AppColors.iconoTipo(r.tipoProblema),
            color: AppColors.forEstado(r.estado),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              r.titulo,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Text(r.descripcion, style: const TextStyle(fontSize: 13.5)),
      const Divider(height: 24),
      KeyValue('Tipo', TipoProblema.label(r.tipoProblema)),
      KeyValue('Direccion', r.ubicacion.direccion ?? '-'),
      KeyValue('Reportado por', r.nombreCiudadano ?? '-'),
      KeyValue('Ultima actualizacion', fmtFechaHora(r.fechaActualizacion)),
      KeyValue(
        'Tecnico asignado',
        r.tieneTecnico ? r.tecnicoNombre! : 'Sin tecnico asignado',
      ),
    ]);
  }
}
