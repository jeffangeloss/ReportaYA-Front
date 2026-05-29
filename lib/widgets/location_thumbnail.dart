import 'package:flutter/material.dart';

class LocationThumbnail extends StatelessWidget {
  final double lat;
  final double lng;
  final String? direccion;
  final bool editable;

  const LocationThumbnail({
    super.key,
    required this.lat,
    required this.lng,
    this.direccion,
    this.editable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7FF),
        border: Border.all(color: const Color(0xFFA27EFF), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E0FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Stack(
                  alignment: Alignment.center,
                  children: [
                    Text('🗺️', style: TextStyle(fontSize: 40)),
                    Positioned(top: 20, child: Text('📍', style: TextStyle(fontSize: 24))),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(direccion ?? 'Ubicación del reporte',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                    const SizedBox(height: 4),
                    Text('${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF666666), fontFamily: 'monospace')),
                  ],
                ),
              ),
            ],
          ),
          if (editable) ...[
            const SizedBox(height: 8),
            const Text('Toca para cambiar ubicación',
                style: TextStyle(fontSize: 12, color: Color(0xFFA27EFF), fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }
}
