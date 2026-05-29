import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFA27EFF);
  static const Color secondary = Color(0xFF6A9FFF);
  static const Color tecnicoPrimary = Color(0xFF4CAF50);
  static const Color tecnicoSecondary = Color(0xFF45A049);

  static const List<Color> ciudadanoGradient = [primary, secondary];
  static const List<Color> tecnicoGradient = [tecnicoPrimary, tecnicoSecondary];

  // Estados
  static const Color estadoPendiente = Color(0xFFFF6B6B);
  static const Color estadoRevision = Color(0xFFFFA500);
  static const Color estadoProceso = Color(0xFF2196F3);
  static const Color estadoResuelta = Color(0xFF4CAF50);
  static const Color estadoCerrada = Color(0xFF607D8B);
  static const Color estadoRechazado = Color(0xFFF44336);
  static const Color estadoRechazadoAudito = Color(0xFFD32F2F);

  static Color forEstado(String estado) {
    switch (estado.toUpperCase()) {
      case 'PENDIENTE':
        return estadoPendiente;
      case 'REVISION':
        return estadoRevision;
      case 'PROCESO':
        return estadoProceso;
      case 'RESUELTA':
      case 'FINALIZADO':
        return estadoResuelta;
      case 'CERRADA':
        return estadoCerrada;
      case 'RECHAZADO':
        return estadoRechazado;
      case 'RECHAZADO_AUDITO':
        return estadoRechazadoAudito;
      default:
        return Colors.grey;
    }
  }

  static String textoEstado(String estado) {
    switch (estado.toUpperCase()) {
      case 'PENDIENTE':
        return 'Pendiente';
      case 'REVISION':
        return 'En Revisión';
      case 'PROCESO':
        return 'En Proceso';
      case 'RESUELTA':
        return 'Resuelta';
      case 'CERRADA':
        return 'Cerrada';
      case 'RECHAZADO':
        return 'Rechazado';
      case 'RECHAZADO_AUDITO':
        return 'Rechazado Auditoría';
      default:
        return estado;
    }
  }

  static Color forPrioridad(String prioridad) {
    switch (prioridad.toUpperCase()) {
      case 'BAJA':
        return const Color(0xFF4CAF50);
      case 'MEDIA':
        return const Color(0xFFFFA500);
      case 'ALTA':
        return const Color(0xFFFF6B6B);
      default:
        return Colors.grey;
    }
  }
}
