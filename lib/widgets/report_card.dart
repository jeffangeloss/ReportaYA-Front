import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/fechas.dart';
import 'app_colors.dart';
import 'estado_pill.dart';

/// Tarjeta de reporte reutilizable (listados de ciudadano, operador y tecnico).
class ReportCard extends StatelessWidget {
  final ReporteResponse reporte;
  final VoidCallback? onTap;
  final bool mostrarTecnico;

  const ReportCard({
    super.key,
    required this.reporte,
    this.onTap,
    this.mostrarTecnico = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forEstado(reporte.estado);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Color(0x11141028), blurRadius: 6, offset: Offset(0, 1)),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
              )),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(AppColors.iconoTipo(reporte.tipoProblema), size: 18, color: color),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(reporte.titulo,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined, size: 14, color: Color(0xFF9AA0AB)),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(reporte.ubicacion.direccion ?? 'Sin direccion',
                                style: const TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      if (mostrarTecnico)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            reporte.tieneTecnico ? 'Tecnico: ${reporte.tecnicoNombre}' : 'Sin tecnico asignado',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                          ),
                        ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          EstadoPill(reporte.estado),
                          const Spacer(),
                          Text(fmtFecha(reporte.fechaCreacion),
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFF9AA0AB))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
