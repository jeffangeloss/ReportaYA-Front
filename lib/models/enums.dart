class EstadoReporte {
  static const String PENDIENTE = 'PENDIENTE';
  static const String REVISION = 'REVISION';
  static const String PROCESO = 'PROCESO';
  static const String RESUELTA = 'RESUELTA';
  static const String CERRADA = 'CERRADA';
  static const String RECHAZADO = 'RECHAZADO';
  static const String RECHAZADO_AUDITO = 'RECHAZADO_AUDITO';

  static const List<String> values = [
    PENDIENTE, REVISION, PROCESO, RESUELTA, CERRADA, RECHAZADO, RECHAZADO_AUDITO,
  ];
}

class Prioridad {
  static const String BAJA = 'BAJA';
  static const String MEDIA = 'MEDIA';
  static const String ALTA = 'ALTA';

  static const List<String> values = [BAJA, MEDIA, ALTA];
}

class TipoFoto {
  static const String INICIAL = 'INICIAL';
  static const String PROCESO = 'PROCESO';
  static const String FINAL = 'FINAL';
}

class TipoProblema {
  static const String INFRAESTRUCTURA = 'INFRAESTRUCTURA';
  static const String RESIDUOS = 'RESIDUOS';
  static const String OTROS = 'OTROS';

  static const List<String> values = [INFRAESTRUCTURA, RESIDUOS, OTROS];
}

class TipoCuenta {
  static const String CIUDADANO = 'CIUDADANO';
  static const String TECNICO = 'TECNICO';
  static const String OPERADOR_MUNICIPAL = 'OPERADOR_MUNICIPAL';
}
