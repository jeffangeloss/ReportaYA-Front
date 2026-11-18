import '../models/models.dart';
import 'api_client.dart';

/// Listado de técnicos disponibles (CU-07).
class ServicioTecnicos {
  final ApiClient _client = ApiClient.instance;

  Future<List<TecnicoResponse>> obtenerDisponibles() async {
    final content = await _client.getTodasLasPaginas('/tecnicos');
    return content
        .map((json) => TecnicoResponse.fromJson(json))
        .where((t) => t.activo)
        .toList();
  }
}
