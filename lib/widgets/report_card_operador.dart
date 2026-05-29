import 'package:flutter/material.dart';
import 'app_colors.dart';

class ReportCardOperador extends StatelessWidget {
  final String titulo;
  final String tipo;
  final String estado;
  final String fecha;
  final String ubicacion;
  final VoidCallback onCambiarEstado;
  final VoidCallback onAsignarTecnico;
  final VoidCallback? onAuditar;
  final VoidCallback? onRechazar;

  const ReportCardOperador({
    super.key,
    required this.titulo,
    required this.tipo,
    required this.estado,
    required this.fecha,
    required this.ubicacion,
    required this.onCambiarEstado,
    required this.onAsignarTecnico,
    this.onAuditar,
    this.onRechazar,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = AppColors.forEstado(estado);
    final estadoUpper = estado.toUpperCase();

    return Container(
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
          Text('Prioridad: $tipo', style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
          Text('Fecha: $fecha', style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
          Text('Ubicación: $ubicacion',
              style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: _buildActions(estadoUpper)),
        ],
      ),
    );
  }

  List<Widget> _buildActions(String estado) {
    final widgets = <Widget>[];
    if (estado == 'PENDIENTE') {
      widgets.add(_btn(Icons.remove_red_eye_outlined, 'Revisar', const Color(0xFFFFA500), onCambiarEstado));
      if (onRechazar != null) {
        widgets.add(_btn(Icons.cancel_outlined, 'Rechazar', const Color(0xFFF44336), onRechazar!));
      }
    } else if (estado == 'REVISION') {
      widgets.add(_btn(Icons.person_add_alt_1_outlined, 'Asignar', const Color(0xFF2196F3), onAsignarTecnico));
      if (onRechazar != null) {
        widgets.add(_btn(Icons.cancel_outlined, 'Rechazar', const Color(0xFFF44336), onRechazar!));
      }
    } else if (estado == 'RESUELTA' && onAuditar != null) {
      widgets.add(_btn(Icons.fact_check_outlined, 'Auditar', const Color(0xFFFF9800), onAuditar!));
    }
    return widgets;
  }

  Widget _btn(IconData icon, String label, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 16, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
    );
  }
}
