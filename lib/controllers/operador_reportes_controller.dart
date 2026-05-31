import 'package:get/get.dart';
import '../models/models.dart';
import '../services/servicio_reportes.dart';

/// Estado de la cola del operador (vistas 01 Cola y 02 Gestion).
class OperadorReportesController extends GetxController {
  final ServicioReportes _service = ServicioReportes();

  final RxList<ReporteResponse> reportes = <ReporteResponse>[].obs;
  final RxBool loading = false.obs;
  final RxnString error = RxnString();

  int get pendientes => reportes.where((r) => r.estado == EstadoReporte.PENDIENTE).length;
  int get enRevision => reportes.where((r) => r.estado == EstadoReporte.REVISION).length;
  int get finalizados => reportes.where((r) => r.estado == EstadoReporte.FINALIZADO).length;

  Future<void> cargar() async {
    try {
      loading.value = true;
      error.value = null;
      final list = await _service.obtenerTodos();
      reportes.assignAll(list);
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading.value = false;
    }
  }

  List<ReporteResponse> filtrar(String estado) {
    if (estado.isEmpty) return reportes.toList();
    return reportes.where((r) => r.estado == estado).toList();
  }

  Future<ReporteResponse> aceptar(int id) async {
    final r = await _service.aceptarReporte(id);
    await cargar();
    return r;
  }

  Future<ReporteResponse> rechazar(int id, String motivo) async {
    final r = await _service.rechazarReporte(id, motivo);
    await cargar();
    return r;
  }

  Future<ReporteResponse> asignar(int id, TecnicoResponse tecnico) async {
    final r = await _service.asignarTecnico(id, tecnico);
    await cargar();
    return r;
  }
}
