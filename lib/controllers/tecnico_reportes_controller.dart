import 'package:get/get.dart';
import '../models/models.dart';
import '../services/servicio_reportes.dart';
import '../widgets/custom_toast.dart';

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

  // --- Estado de la pantalla Ejecutar (Vistas 02/03) ---
  final Rx<ReporteResponse?> reporteActual = Rx(null);
  final RxList<Foto> fotosIniciales = <Foto>[].obs;
  final RxList<Foto> fotosFinales = <Foto>[].obs;
  final RxBool busy = false.obs;

  Future<void> cargar(int tecnicoId) async {
    _tecnicoId = tecnicoId;
    loading.value = true;
    final list = await _service.obtenerAsignadosATecnico(tecnicoId);
    asignaciones.assignAll(list);
    loading.value = false;
  }

  Future<ReporteResponse> finalizar(int id, String comentario, List<String> fotosBase64) async {
    final r = await _service.finalizarReporte(id, comentario, fotosBase64);
    await cargar(_tecnicoId);
    return r;
  }

  // --- Acciones de la pantalla Ejecutar ---

  Future<void> iniciarEjecucion(int id) async {
    reporteActual.value = asignaciones.firstWhere((x) => x.id == id);
    // Limpia fotos de un reporte previo para no mostrar datos obsoletos.
    fotosIniciales.clear();
    fotosFinales.clear();
    busy.value = true;
    try {
      fotosIniciales.assignAll(await _service.obtenerFotos(id, tipo: TipoFoto.INICIAL));
      fotosFinales.assignAll(await _service.obtenerFotos(id, tipo: TipoFoto.FINAL));
    } catch (_) {
      // Si fallan las fotos, se muestran vacias; nunca se congela la pantalla.
    } finally {
      busy.value = false; // siempre se libera, incluso ante un error
    }
  }

  /// Devuelve true si la finalizacion fue exitosa (la pantalla decide navegar).
  Future<bool> finalizarGestion(String comentario, List<String> fotosBase64) async {
    final id = reporteActual.value?.id;
    if (id == null) return false;
    busy.value = true;
    try {
      reporteActual.value = await finalizar(id, comentario, fotosBase64);
      AppToast.success('Reporte finalizado!');
      return true;
    } catch (e) {
      AppToast.error(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      busy.value = false;
    }
  }
}
