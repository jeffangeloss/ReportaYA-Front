import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../models/models.dart';
import 'api_client.dart';

/// Lógica de reportes contra la API REST.
class ServicioReportes {
  final ApiClient _client = ApiClient.instance;

  int _getLoggedUserId() {
    try {
      if (Get.isRegistered<AuthController>()) {
        return Get.find<AuthController>().cuentaId;
      }
    } catch (_) {}
    return 0;
  }

  // ---------------- Lectura ----------------

  Future<List<ReporteResponse>> obtenerReportesPorCuenta(int cuentaId) async {
    final res = await _client.get('/reportes/cuenta/$cuentaId');
    if (res != null && res['content'] != null) {
      final List content = res['content'];
      return content.map((json) => ReporteResponse.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<ReporteResponse>> obtenerTodos({String? estado}) async {
    final String path = estado != null && estado.isNotEmpty
        ? '/reportes?estado=$estado'
        : '/reportes';
    final res = await _client.get(path);
    if (res != null && res['content'] != null) {
      final List content = res['content'];
      return content.map((json) => ReporteResponse.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<ReporteResponse>> obtenerParaMapa({String? estado, String? tipo}) async {
    final queryParams = <String>[];
    if (estado != null && estado.isNotEmpty) queryParams.add('estado=$estado');
    if (tipo != null && tipo.isNotEmpty) queryParams.add('tipo=$tipo');

    final String path = '/reportes/mapa${queryParams.isNotEmpty ? '?${queryParams.join('&')}' : ''}';
    final List? res = await _client.get(path) as List?;
    if (res != null) {
      return res.map((json) {
        // Adaptar ReporteMapaDTO a ReporteResponse
        return ReporteResponse(
          id: (json['id'] as num?)?.toInt() ?? 0,
          titulo: json['titulo'] as String? ?? '',
          descripcion: '',
          cuentaId: 0,
          estado: json['estado'] as String? ?? EstadoReporte.PENDIENTE,
          tipoProblema: json['tipoProblema'] as String?,
          ubicacion: json['ubicacion'] != null 
              ? Ubicacion.fromJson(json['ubicacion'] as Map<String, dynamic>)
              : Ubicacion(id: 0, latitud: 0, longitud: 0, direccion: ''),
          fechaCreacion: '',
          fechaActualizacion: '',
        );
      }).toList();
    }
    return [];
  }

  Future<List<ReporteResponse>> obtenerAsignadosATecnico(int tecnicoId) async {
    final res = await _client.get('/tecnicos/$tecnicoId/reportes?estado=REVISION');
    if (res != null && res['content'] != null) {
      final List content = res['content'];
      return content.map((json) => ReporteResponse.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<HistorialEstado>> obtenerHistorialEstados(int reporteId) async {
    final List? res = await _client.get('/historial-estados/reporte/$reporteId') as List?;
    if (res != null) {
      return res.map((json) => HistorialEstado.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<Foto>> obtenerFotos(int reporteId, {String? tipo}) async {
    final String path = tipo != null && tipo.isNotEmpty
        ? '/reportes/$reporteId/fotos?tipo=$tipo'
        : '/reportes/$reporteId/fotos';
    final List? res = await _client.get(path) as List?;
    if (res != null) {
      return res.map((json) {
        return Foto(
          id: (json['id'] as num?)?.toInt() ?? 0,
          reporteId: (json['reporteId'] as num?)?.toInt() ?? 0,
          url: json['url'] as String? ?? '',
          tipo: json['tipo'] as String? ?? 'INICIAL',
          descripcion: json['descripcion'] as String? ?? '',
          fechaCarga: json['fechaCarga']?.toString() ?? '',
        );
      }).toList();
    }
    return [];
  }

  // ---------------- Escritura ----------------

  Future<ReporteResponse> crearReporte(
    CrearReporteRequest req, {
    String? nombreCiudadano,
    List<String> urlsFotos = const [],
  }) async {
    // 1. Crear el reporte base
    final res = await _client.post('/reportes', req.toJson());
    final reporte = ReporteResponse.fromJson(res);

    // 2. Subir fotos asociadas si las hay
    for (final url in urlsFotos) {
      String base64Str = url;
      // Validar si es una cadena base64 real
      if (!base64Str.startsWith('data:image') && !base64Str.contains('/') && base64Str.length > 50) {
        // Es base64
      } else {
        // Enviar imagen transparente dummy de 1x1 si viene una ruta de asset local
        base64Str = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=';
      }

      await _client.post('/reportes/${reporte.id}/fotos', {
        'archivoBase64': base64Str,
        'tipo': 'INICIAL',
        'descripcion': 'Foto del incidente',
      });
    }

    return reporte;
  }

  Future<ReporteResponse> aceptarReporte(int id) async {
    final int operadorId = _getLoggedUserId();
    final res = await _client.post('/operador/reportes/$id/aceptar', {
      'operadorId': operadorId,
    });
    return ReporteResponse.fromJson(res);
  }

  Future<ReporteResponse> rechazarReporte(int id, String motivo) async {
    final int operadorId = _getLoggedUserId();
    final res = await _client.post('/operador/reportes/$id/rechazar', {
      'operadorId': operadorId,
      'motivo': motivo,
    });
    return ReporteResponse.fromJson(res);
  }

  Future<ReporteResponse> asignarTecnico(int id, TecnicoResponse tecnico) async {
    final int operadorId = _getLoggedUserId();
    await _client.post('/asignaciones', {
      'reporteId': id,
      'operadorId': operadorId,
      'tecnicoId': tecnico.id,
    });
    // Obtener el reporte actualizado
    final res = await _client.get('/reportes/$id');
    return ReporteResponse.fromJson(res);
  }

  Future<ReporteResponse> finalizarReporte(
    int id,
    String comentarioResolucion,
    List<String> urlsFotos,
  ) async {
    final int tecnicoId = _getLoggedUserId();

    final List<Map<String, dynamic>> fotosJson = urlsFotos.map((url) {
      String base64Str = url;
      if (!base64Str.startsWith('data:image') && !base64Str.contains('/') && base64Str.length > 50) {
        // Es base64
      } else {
        base64Str = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=';
      }
      return {
        'archivoBase64': base64Str,
        'tipo': 'FINAL',
        'descripcion': 'Foto de finalizacion de incidencia',
      };
    }).toList();

    final body = {
      'comentarioResolucion': comentarioResolucion,
      'fotos': fotosJson,
    };

    final res = await _client.patch('/tecnicos/$tecnicoId/reportes/$id/completar', body);
    return ReporteResponse.fromJson(res['reporte']);
  }
}
