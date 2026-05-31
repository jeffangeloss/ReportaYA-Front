import 'package:get/get.dart';
import '../models/models.dart';
import '../services/servicio_reportes.dart';

/// Estado de los reportes del ciudadano (vistas 02 Inicio y 03 Mis reportes).
class ReportesController extends GetxController {
  final ServicioReportes _service = ServicioReportes();

  final RxList<ReporteResponse> reportes = <ReporteResponse>[].obs;
  final RxBool loading = false.obs;
  final RxnString error = RxnString();

  Future<void> cargarReportes(int cuentaId) async {
    try {
      loading.value = true;
      error.value = null;
      final list = await _service.obtenerReportesPorCuenta(cuentaId);
      reportes.assignAll(list);
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading.value = false;
    }
  }

  List<ReporteResponse> get recientes => reportes.take(5).toList();

  List<ReporteResponse> filtrar({String? estado, String? busqueda}) {
    return reportes.where((r) {
      final okEstado = estado == null || estado.isEmpty || r.estado == estado;
      final okBusqueda = busqueda == null ||
          busqueda.isEmpty ||
          r.titulo.toLowerCase().contains(busqueda.toLowerCase());
      return okEstado && okBusqueda;
    }).toList();
  }

  void limpiar() {
    reportes.clear();
    error.value = null;
  }
}
