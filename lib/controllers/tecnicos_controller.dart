import 'package:get/get.dart';
import '../models/models.dart';
import '../services/servicio_tecnicos.dart';

/// Lista de tecnicos disponibles para asignacion (CU-07).
class TecnicosController extends GetxController {
  final ServicioTecnicos _service = ServicioTecnicos();

  final RxList<TecnicoResponse> tecnicos = <TecnicoResponse>[].obs;
  final RxBool loading = false.obs;

  Future<void> cargar() async {
    loading.value = true;
    tecnicos.assignAll(await _service.obtenerDisponibles());
    loading.value = false;
  }
}
