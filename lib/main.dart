import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'controllers/auth_controller.dart';
import 'controllers/reportes_controller.dart';
import 'controllers/operador_reportes_controller.dart';
import 'controllers/tecnicos_controller.dart';
import 'controllers/tecnico_reportes_controller.dart';
import 'data/local_store.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await initializeDateFormatting('es', null);

  // Siembra el almacen local desde los JSON (datos "quemados").
  await LocalStore.instance.seed();

  // Controladores globales (Ciudadano + Operador + Tecnico).
  Get.put(AuthController(), permanent: true);
  Get.put(ReportesController(), permanent: true);
  Get.put(OperadorReportesController(), permanent: true);
  Get.put(TecnicosController(), permanent: true);
  Get.put(TecnicoReportesController(), permanent: true);

  runApp(const ReportaYAApp());
}

class ReportaYAApp extends StatelessWidget {
  const ReportaYAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ReportaYA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFA27EFF)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
    );
  }
}
