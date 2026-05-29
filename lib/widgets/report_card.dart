import 'package:flutter/material.dart';
import 'app_colors.dart';

class ReportCard extends StatelessWidget {
  final String titulo;
  final String tipo;
  final String estado;
  final String fecha;
  final String ubicacion;
  final VoidCallback? onPress;
  final VoidCallback? onAtender;

  const ReportCard({
    super.key,
    required this.titulo,
    required this.tipo,
    required this.estado,
    required this.fecha,
    required this.ubicacion,
    this.onPress,
    this.onAtender,
  });

  @override
  Widget build(BuildContext context) {
    final mostrarAtender =
        ['PROCESO', 'RECHAZADO_AUDITO'].contains(estado.toUpperCase()) && onAtender != null;
    final borderColor = AppColors.forEstado(estado);

    final content = Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: borderColor, width: 6)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                const SizedBox(height: 6),
                Row(children: [
                  const Text('Estado: ', style: TextStyle(fontSize: 13, color: Color(0xFF666666))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: borderColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(AppColors.textoEstado(estado),
                        style: TextStyle(color: borderColor, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ]),
                const SizedBox(height: 4),
                Text('Fecha: $fecha', style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
                Text('Ubicación: $ubicacion',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (mostrarAtender) const SizedBox(width: 8),
          if (mostrarAtender)
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
              label: const Text('Atender', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tecnicoPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: onAtender,
            ),
        ],
      ),
    );

    if (onPress != null) {
      return InkWell(onTap: onPress, borderRadius: BorderRadius.circular(12), child: content);
    }
    return content;
  }
}
