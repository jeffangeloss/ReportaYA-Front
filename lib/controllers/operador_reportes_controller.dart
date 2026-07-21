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

  Future<void> aceptarGestion() async {
    final id = reporteActual.value?.id;
    if (id == null) return;
    busy.value = true;
    try {
      reporteActual.value = await aceptar(id);
      AppToast.success('Reporte aceptado. Ahora en Revision.');
    } catch (e) {
      AppToast.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      busy.value = false;
    }
  }

  /// Devuelve true si el rechazo fue exitoso (la pantalla decide navegar).
  Future<bool> rechazarGestion(String motivo) async {
    final id = reporteActual.value?.id;
    if (id == null) return false;
    busy.value = true;
    try {
      await rechazar(id, motivo);
      AppToast.success('Reporte rechazado.');
      return true;
    } catch (e) {
      AppToast.error(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      busy.value = false;
    }
  }

  Future<void> asignarGestion(TecnicoResponse tecnico) async {
    final id = reporteActual.value?.id;
    if (id == null) return;
    busy.value = true;
    try {
      reporteActual.value = await asignar(id, tecnico);
      AppToast.success('Tecnico asignado: ${tecnico.nombreCompleto}');
    } catch (e) {
      AppToast.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      busy.value = false;
    }
  }
}
