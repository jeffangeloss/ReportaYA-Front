import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/reporte.dart';
import '../routes/app_routes.dart';
import 'app_colors.dart';
import 'location_thumbnail.dart';

class ReportDetailModal {
  static Future<void> show(ReporteResponse reporte) {
    return Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: Get.height * 0.85),
          child: _DetailContent(reporte: reporte),
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final ReporteResponse reporte;
  const _DetailContent({required this.reporte});

  @override
  Widget build(BuildContext context) {
    final borderColor = AppColors.forEstado(reporte.estado);
    final ubicacionTexto = reporte.ubicacion.direccion ??
        '${reporte.ubicacion.latitud.toStringAsFixed(6)}, ${reporte.ubicacion.longitud.toStringAsFixed(6)}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
          child: Row(
            children: [
              const Expanded(
                child: Text('Detalles del Reporte',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
              ),
              IconButton(icon: const Icon(Icons.close, size: 28), onPressed: () => Get.back()),
            ],
          ),
        ),
        const Divider(height: 1),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _section('Información General', [
                  _row('Título:', reporte.titulo),
                  _badgeRow('Estado:', AppColors.textoEstado(reporte.estado), borderColor),
                  _badgeRow('Prioridad:', reporte.prioridad, AppColors.forPrioridad(reporte.prioridad)),
                  if (reporte.tipoProblema != null) _row('Tipo:', reporte.tipoProblema!),
                ]),
                _section('Descripción', [
                  Text(reporte.descripcion,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF555555), height: 1.4)),
                ]),
                _section('Ubicación', [
                  LocationThumbnail(
                    lat: reporte.ubicacion.latitud,
                    lng: reporte.ubicacion.longitud,
                    direccion: reporte.ubicacion.direccion,
                  ),
                ]),
                if (reporte.nombreCiudadano != null)
                  _section('Ciudadano', [_row('Nombre:', reporte.nombreCiudadano!)]),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA27EFF),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size.fromHeight(40),
                  ),
                  icon: const Icon(Icons.history, color: Colors.white),
                  label: const Text('Ver Historial de Cambios',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Get.back();
                    Get.toNamed(AppRoutes.historial, arguments: reporte.id);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF888888), fontWeight: FontWeight.w600))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF333333)))),
        ],
      ),
    );
  }

  Widget _badgeRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF888888), fontWeight: FontWeight.w600))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Text(value, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
