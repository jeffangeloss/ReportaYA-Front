import 'package:flutter/material.dart';

/// Tarjeta-contador usada en los paneles de Operador y Tecnico.
class CounterCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const CounterCard({super.key, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [BoxShadow(color: Color(0x11141028), blurRadius: 6, offset: Offset(0, 1))],
          ),
          child: Column(
            children: [
              Text('$value', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 2),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            ],
          ),
        ),
      );
}

/// Fila de contadores con separacion y un ligero solape sobre la cabecera.
class CountersRow extends StatelessWidget {
  final List<Widget> children;
  const CountersRow({super.key, required this.children});

  @override
  Widget build(BuildContext context) => Transform.translate(
        offset: const Offset(0, -14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                children[i],
              ]
            ],
          ),
        ),
      );
}
