import 'package:get/get.dart';
import '../models/reporte.dart';
import '../services/servicio_reportes.dart';

class HistorialController extends GetxController {
  final ServicioReportes _service = ServicioReportes();

  final RxMap<int, List<HistorialEstado>> historial = <int, List<HistorialEstado>>{}.obs;
  final RxBool loading = false.obs;
  final RxnString error = RxnString();

  Future<void> cargarHistorial(int reporteId) async {
    try {
      loading.value = true;
      error.value = null;
      final data = await _service.obtenerHistorialEstados(reporteId);
      data.sort((a, b) =>
          DateTime.parse(b.fechaCambio).compareTo(DateTime.parse(a.fechaCambio)));
      historial[reporteId] = data;
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  void limpiarHistorial() {
    historial.clear();
    error.value = null;
  }
}
