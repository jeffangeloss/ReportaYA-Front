import '../models/models.dart';
import 'api_client.dart';

/// Listado de tecnicos disponibles (CU-07) contra el backend real.
class ServicioTecnicos {
  final ApiClient _api = ApiClient.instance;

  Future<List<TecnicoResponse>> obtenerDisponibles() async {
    final items = await _api.fetchAllPages('/api/tecnicos');
    // TecnicoDTO trae {id, usuario, nombres, apellidos, correo} pero NO dni ni
    // telefono; se construye a mano con esos campos vacios para no romper el
    // modelo (activo se asume true: los tecnicos listados estan activos).
    return items
        .map((j) => TecnicoResponse(
              id: j['id'] as int,
              usuario: (j['usuario'] as String?) ?? '',
              nombres: (j['nombres'] as String?) ?? '',
              apellidos: (j['apellidos'] as String?) ?? '',
              dni: (j['dni'] as String?) ?? '',
              telefono: (j['telefono'] as String?) ?? '',
              correo: (j['correo'] as String?) ?? '',
              activo: (j['activo'] as bool?) ?? true,
            ))
        .toList();
  }
}
