import 'package:get/get.dart';
import '../models/reporte.dart';
import '../services/servicio_tecnicos.dart';
import 'auth_controller.dart';

class TecnicoReportesController extends GetxController {
  final ServicioTecnicos _service = ServicioTecnicos();

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
      final auth = Get.find<AuthController>();
      final usuario = auth.usuario.value;
      if (usuario == null) {
        throw Exception('Usuario no autenticado');
      }
      final estado = estadoParam ?? filtroEstado.value;
      final pageData = await _service.obtenerReportesAsignados(
        usuario.id,
        estado: estado,
        page: page,
      );
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

  void limpiarReportes() {
    reportes.clear();
    currentPage.value = 0;
    totalPages.value = 0;
    filtroEstado.value = null;
    error.value = null;
  }
}
