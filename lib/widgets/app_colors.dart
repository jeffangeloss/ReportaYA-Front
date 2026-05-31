import 'package:flutter/material.dart';
import '../models/enums.dart';

class AppColors {
  static const Color primary = Color(0xFFA27EFF);
  static const Color secondary = Color(0xFF6A9FFF);
  static const Color tecnicoPrimary = Color(0xFF4CAF50);
  static const Color tecnicoSecondary = Color(0xFF45A049);

  static const List<Color> ciudadanoGradient = [primary, secondary];
  static const List<Color> operadorGradient = [primary, secondary];
  static const List<Color> tecnicoGradient = [tecnicoPrimary, tecnicoSecondary];

  // Estados (4, alineados a los CU)
  static const Color estadoPendiente = Color(0xFFFF6B6B);
  static const Color estadoRevision = Color(0xFFFFA500);
  static const Color estadoFinalizado = Color(0xFF4CAF50);
  static const Color estadoRechazado = Color(0xFF9E9E9E);

  static Color forEstado(String estado) {
    switch (estado.toUpperCase()) {
      case EstadoReporte.PENDIENTE:
        return estadoPendiente;
      case EstadoReporte.REVISION:
        return estadoRevision;
      case EstadoReporte.FINALIZADO:
        return estadoFinalizado;
      case EstadoReporte.RECHAZADO:
        return estadoRechazado;
      default:
        return Colors.grey;
    }
  }

  static String textoEstado(String estado) {
    switch (estado.toUpperCase()) {
      case EstadoReporte.PENDIENTE:
        return 'Pendiente';
      case EstadoReporte.REVISION:
        return 'En Revision';
      case EstadoReporte.FINALIZADO:
        return 'Finalizado';
      case EstadoReporte.RECHAZADO:
        return 'Rechazado';
      default:
        return estado;
    }
  }

  static IconData iconoTipo(String? tipo) {
    switch (tipo) {
      case TipoProblema.INFRAESTRUCTURA:
        return Icons.construction;
      case TipoProblema.RESIDUOS:
        return Icons.delete_outline;
      case TipoProblema.SEGURIDAD:
        return Icons.shield_outlined;
      case TipoProblema.ALUMBRADO:
        return Icons.lightbulb_outline;
      default:
        return Icons.report_problem_outlined;
    }
  }
}
