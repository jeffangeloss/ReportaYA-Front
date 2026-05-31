import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/app_colors.dart';
import 'inicio_screen.dart';
import 'map_screen.dart';
import 'report_screen.dart';
import 'mis_reportes_screen.dart';

/// Controla la pestana activa del Ciudadano (Inicio / Mapa / Reportar / Mis reportes).
class TabsController extends GetxController {
  final RxInt index = 0.obs;
  void go(int i) => index.value = i;
}

class MainTabs extends StatelessWidget {
  const MainTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(TabsController());
    const pages = [InicioScreen(), MapScreen(), ReportScreen(), MisReportesScreen()];
    return Obx(() => Scaffold(
          body: IndexedStack(index: c.index.value, children: pages),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: c.index.value,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            onTap: c.go,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Inicio'),
              BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Mapa'),
              BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline, size: 28), label: 'Reportar'),
              BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: 'Mis reportes'),
            ],
          ),
        ));
  }
}
