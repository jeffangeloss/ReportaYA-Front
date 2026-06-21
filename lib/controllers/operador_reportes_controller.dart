import 'package:get/get.dart';
import '../models/models.dart';
import '../services/servicio_reportes.dart';
import '../widgets/custom_toast.dart';

/// Estado de la cola del operador (vistas 01 Cola y 02 Gestion).
class OperadorReportesController extends GetxController {
  final ServicioReportes _service = ServicioReportes();

  final RxList<ReporteResponse> reportes = <ReporteResponse>[].obs;
  final RxBool loading = false.obs;
  final RxnString error = RxnString();

  // --- Estado de la pantalla Gestion (Vista 02) ---
  final Rx<ReporteResponse?> reporteActual = Rx(null);
  final RxList<Foto> fotosIniciales = <Foto>[].obs;
  final RxList<Foto> fotosFinales = <Foto>[].obs;
  final RxBool busy = false.obs;

  int get pendientes =>
      reportes.where((r) => r.estado == EstadoReporte.PENDIENTE).length;
  int get enRevision =>
      reportes.where((r) => r.estado == EstadoReporte.REVISION).length;
  int get finalizados =>
      reportes.where((r) => r.estado == EstadoReporte.FINALIZADO).length;

  Future<void> cargar() async {
    // llama al servicio para obtener la lista de reportes y actualiza el estado
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

  // --- Acciones de la pantalla Gestion ---

  Future<void> iniciarGestion(int id) async {
    reporteActual.value = reportes.firstWhere((x) => x.id == id);
    busy.value = true;
    final ini = await _service.obtenerFotos(id, tipo: TipoFoto.INICIAL);
    final fin = await _service.obtenerFotos(id, tipo: TipoFoto.FINAL);
    fotosIniciales.assignAll(ini);
    fotosFinales.assignAll(fin);
    busy.value = false;
  }

  Future<void> aceptarGestion() async {
    final id = reporteActual.value?.id;
    if (id == null) return;
    busy.value = true;
    final upd = await aceptar(id);
    reporteActual.value = upd;
    busy.value = false;
    AppToast.success('Reporte aceptado. Ahora en Revision.');
  }

  Future<void> rechazarGestion(String motivo) async {
    final id = reporteActual.value?.id;
    if (id == null) return;
    busy.value = true;
    await rechazar(id, motivo);
    busy.value = false;
    AppToast.success('Reporte rechazado.');
  }

  Future<void> asignarGestion(TecnicoResponse tecnico) async {
    final id = reporteActual.value?.id;
    if (id == null) return;
    busy.value = true;
    final upd = await asignar(id, tecnico);
    reporteActual.value = upd;
    busy.value = false;
    AppToast.success('Tecnico asignado: ${tecnico.nombreCompleto}');
  }
}
