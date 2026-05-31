import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/historial_controller.dart';
import '../models/reporte.dart';
import '../widgets/app_colors.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  late final int reporteId;
  final HistorialController ctrl = Get.find();

  @override
  void initState() {
    super.initState();
    reporteId = Get.arguments as int;
    WidgetsBinding.instance.addPostFrameCallback((_) => ctrl.cargarHistorial(reporteId));
  }

  Color _statusColor(String estado) {
    switch (estado) {
      case 'PENDIENTE':
        return const Color(0xFFFFC107);
      case 'REVISION':
        return const Color(0xFF2196F3);
      case 'PROCESO':
        return const Color(0xFF9C27B0);
      case 'RESUELTA':
        return const Color(0xFF4CAF50);
      case 'CERRADA':
        return const Color(0xFF607D8B);
      case 'RECHAZADO':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: AppColors.ciudadanoGradient, begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 12, 10),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Get.back()),
                  const Expanded(
                    child: Text('Historial de Cambios',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                ),
                padding: const EdgeInsets.all(20),
                child: Obx(() {
                  final list = ctrl.historial[reporteId] ?? <HistorialEstado>[];
                  if (ctrl.loading.value && list.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFA27EFF)));
                  }
                  if (ctrl.error.value != null && list.isEmpty) {
                    return Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(ctrl.error.value!, style: const TextStyle(color: Color(0xFFFF6B6B))),
                        TextButton(
                          onPressed: () => ctrl.cargarHistorial(reporteId),
                          child: const Text('Reintentar', style: TextStyle(color: Color(0xFFA27EFF))),
                        ),
                      ]),
                    );
                  }
                  if (list.isEmpty) {
                    return const Center(child: Text('No hay historial disponible', style: TextStyle(color: Color(0xFF999999))));
                  }
                  return RefreshIndicator(
                    color: const Color(0xFFA27EFF),
                    onRefresh: () => ctrl.cargarHistorial(reporteId),
                    child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final item = list[i];
                        final isLast = i == list.length - 1;
                        final isCreation =
                            item.estadoAnterior == null && item.estadoNuevo == 'PENDIENTE';
                        final color = _statusColor(item.estadoNuevo);
                        final fecha = DateTime.tryParse(item.fechaCambio);
                        final fechaStr = fecha != null
                            ? '${DateFormat('dd/MM/yyyy HH:mm:ss').format(fecha)}'
                            : item.fechaCambio;
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    margin: const EdgeInsets.only(top: 12),
                                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                  ),
                                  if (!isLast)
                                    Expanded(child: Container(width: 2, color: const Color(0xFFE0E0E0))),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9F9F9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(fechaStr,
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
                                      const SizedBox(height: 4),
                                      isCreation
                                          ? Text('Reporte Creado',
                                              style: TextStyle(fontWeight: FontWeight.bold, color: color))
                                          : RichText(
                                              text: TextSpan(
                                                style: const TextStyle(color: Color(0xFF333333), fontSize: 14),
                                                children: [
                                                  const TextSpan(text: 'Cambio a '),
                                                  TextSpan(
                                                    text: item.estadoNuevo,
                                                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                      if (item.estadoAnterior != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text('Anterior: ${item.estadoAnterior}',
                                              style: const TextStyle(fontSize: 12, color: Color(0xFF666666), fontStyle: FontStyle.italic)),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
