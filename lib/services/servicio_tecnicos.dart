import '../data/local_store.dart';
import '../models/models.dart';

/// Listado de tecnicos disponibles (CU-07). Fuente local.
class ServicioTecnicos {
  final LocalStore _store = LocalStore.instance;

  Future<List<TecnicoResponse>> obtenerDisponibles() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _store.tecnicos.where((t) => t.activo).toList();
  }
}
