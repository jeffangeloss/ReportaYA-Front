import '../models/models.dart';
import 'api_client.dart';

/// Listado de tecnicos disponibles (CU-07).
class ServicioTecnicos {
  final ApiClient _client = ApiClient.instance;

  Future<List<TecnicoResponse>> obtenerDisponibles() async {
    final res = await _client.get('/tecnicos?page=0');
    if (res != null && res['content'] != null) {
      final List content = res['content'];
      return content.map((json) => TecnicoResponse.fromJson(json)).toList();
    }
    return [];
  }
}
