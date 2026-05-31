/// Catalogos del dominio ReportaYA, alineados a los CU refinados.
/// Solo 4 estados, sin prioridad y sin paso de auditoria.

class EstadoReporte {
  static const String PENDIENTE = 'PENDIENTE';
  static const String REVISION = 'REVISION';
  static const String FINALIZADO = 'FINALIZADO';
  static const String RECHAZADO = 'RECHAZADO';

  static const List<String> values = [PENDIENTE, REVISION, FINALIZADO, RECHAZADO];
}

class TipoProblema {
  static const String INFRAESTRUCTURA = 'INFRAESTRUCTURA';
  static const String RESIDUOS = 'RESIDUOS';
  static const String SEGURIDAD = 'SEGURIDAD';
  static const String ALUMBRADO = 'ALUMBRADO';
  static const String OTRO = 'OTRO';

  static const List<String> values = [
    INFRAESTRUCTURA, RESIDUOS, SEGURIDAD, ALUMBRADO, OTRO,
  ];

  static String label(String? tipo) {
    switch (tipo) {
      case INFRAESTRUCTURA: return 'Infraestructura';
      case RESIDUOS: return 'Residuos';
      case SEGURIDAD: return 'Seguridad';
      case ALUMBRADO: return 'Alumbrado';
      case OTRO: return 'Otro';
      default: return 'Otro';
    }
  }
}

class TipoFoto {
  static const String INICIAL = 'INICIAL'; // foto del incidente (ciudadano)
  static const String FINAL = 'FINAL';     // foto de la solucion (tecnico)
}

class TipoCuenta {
  static const String CIUDADANO = 'CIUDADANO';
  static const String TECNICO = 'TECNICO';
  static const String OPERADOR_MUNICIPAL = 'OPERADOR_MUNICIPAL';
}
