import 'package:get/get.dart';
import '../models/reporte.dart';
import '../services/servicio_reportes.dart';

class OperadorReportesController extends GetxController {
  final ServicioReportes _service = ServicioReportes();

  final RxList<ReporteResponse> reportes = <ReporteResponse>[].obs;
  final RxBool loading = false.obs;
  final RxnString error = RxnString();
  final RxInt currentPage = 0.obs;
  final RxInt totalPages = 0.obs;
  final RxnString filtroEstado = RxnString();

  Future<void> cargarReportes({int page = 0, String? estadoParam}) async {
    try {
      loading.value = true;
      error.value = null;
      final estado = estadoParam ?? filtroEstado.value;
      final pageData = await _service.obtenerTodosReportes(page: page, estado: estado);
      reportes.assignAll(pageData.content);
      currentPage.value = page;
      totalPages.value = pageData.totalPages;
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  Future<void> setFiltroEstado(String? estado) async {
    filtroEstado.value = estado;
    await cargarReportes(page: 0, estadoParam: estado);
  }

  Future<void> nextPage() async {
    if (currentPage.value < totalPages.value - 1 && !loading.value) {
      await cargarReportes(page: currentPage.value + 1);
    }
  }

  Future<void> prevPage() async {
    if (currentPage.value > 0 && !loading.value) {
      await cargarReportes(page: currentPage.value - 1);
    }
  }

  Future<void> cambiarEstadoARevision(int reporteId) async {
    try {
      loading.value = true;
      await _service.cambiarEstadoReporte(reporteId, 'REVISION');
      await cargarReportes(page: currentPage.value);
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  Future<void> rechazarReporte(int reporteId, String motivo) async {
    try {
      loading.value = true;
      await _service.rechazarReporteConMotivo(reporteId, motivo);
      await cargarReportes(page: currentPage.value);
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
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
    filtroEstado.value = null;
    error.value = null;
  }
}
