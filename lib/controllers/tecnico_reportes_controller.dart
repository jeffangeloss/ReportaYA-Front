import 'package:get/get.dart';
import '../models/models.dart';
import '../services/servicio_reportes.dart';

/// Estado de las asignaciones del tecnico (vistas 01/02/03, CU-08).
class TecnicoReportesController extends GetxController {
  final ServicioReportes _service = ServicioReportes();

  final RxList<ReporteResponse> asignaciones = <ReporteResponse>[].obs;
  final RxBool loading = false.obs;
  int _tecnicoId = 0;

  int get porAtender => asignaciones.where((r) => r.estado == EstadoReporte.REVISION).length;
  int get resueltos => asignaciones.where((r) => r.estado == EstadoReporte.FINALIZADO).length;

  List<ReporteResponse> get pendientes =>
      asignaciones.where((r) => r.estado == EstadoReporte.REVISION).toList();

  List<ReporteResponse> get completados =>
      asignaciones.where((r) => r.estado == EstadoReporte.FINALIZADO).toList();

  Future<void> cargar(int tecnicoId) async {
    _tecnicoId = tecnicoId;
    loading.value = true;
    final list = await _service.obtenerAsignadosATecnico(tecnicoId);
    asignaciones.assignAll(list);
    loading.value = false;
  }

  Future<ReporteResponse> finalizar(int id, String comentario, List<String> urlsFotos) async {
    final r = await _service.finalizarReporte(id, comentario, urlsFotos);
    await cargar(_tecnicoId);
    return r;
  }
}
