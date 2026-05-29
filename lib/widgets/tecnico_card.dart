import 'package:flutter/material.dart';

class TecnicoCard extends StatelessWidget {
  final String nombre;
  final String especialidad;
  final VoidCallback onAsignar;
  final bool asignando;

  const TecnicoCard({
    super.key,
    required this.nombre,
    required this.especialidad,
    required this.onAsignar,
    required this.asignando,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.account_circle_outlined, size: 40, color: Color(0xFF2196F3)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                Text(especialidad,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: asignando ? null : onAsignar,
            child: asignando
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text('Asignar', style: TextStyle(color: Colors.white)),
                  ]),
          ),
        ],
      ),
    );
  }
}
