import 'package:get/get.dart';
import '../models/reporte.dart';
import '../services/servicio_reportes.dart';

class ReportesController extends GetxController {
  final ServicioReportes _service = ServicioReportes();

  final RxList<ReporteResponse> reportes = <ReporteResponse>[].obs;
  final RxBool loading = false.obs;
  final RxnString error = RxnString();
  final RxInt currentPage = 0.obs;
  final RxInt totalPages = 0.obs;

  Future<void> cargarReportes(int cuentaId, {int page = 0}) async {
    try {
      loading.value = true;
      error.value = null;
      final pageData = await _service.obtenerReportesPorCuenta(cuentaId, page: page);
      reportes.assignAll(pageData.content);
      currentPage.value = page;
      totalPages.value = pageData.totalPages;
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  Future<void> nextPage(int cuentaId) async {
    if (currentPage.value < totalPages.value - 1 && !loading.value) {
      await cargarReportes(cuentaId, page: currentPage.value + 1);
    }
  }

  Future<void> prevPage(int cuentaId) async {
    if (currentPage.value > 0 && !loading.value) {
      await cargarReportes(cuentaId, page: currentPage.value - 1);
    }
  }

  Future<void> reloadCurrentPage(int cuentaId) async {
    await cargarReportes(cuentaId, page: currentPage.value);
  }

  Future<void> agregarReporte(ReporteResponse reporte, int cuentaId) async {
    await cargarReportes(cuentaId, page: 0);
  }

  void actualizarEstadoReporte(int reporteId, String nuevoEstado) {
    final idx = reportes.indexWhere((r) => r.id == reporteId);
    if (idx >= 0) {
      reportes[idx] = reportes[idx].copyWith(estado: nuevoEstado);
    }
  }

  void limpiarReportes() {
    reportes.clear();
    currentPage.value = 0;
    totalPages.value = 0;
    error.value = null;
  }
}
