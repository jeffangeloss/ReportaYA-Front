import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'report_screen.dart';

class MainTabs extends StatefulWidget {
  const MainTabs({super.key});

  static MainTabsState? of(BuildContext context) => context.findAncestorStateOfType<MainTabsState>();

  @override
  State<MainTabs> createState() => MainTabsState();
}

class MainTabsState extends State<MainTabs> {
  int _index = 0;
  final GlobalKey<MapScreenState> _mapKey = GlobalKey<MapScreenState>();
  late final List<Widget> _pages = [const HomeScreen(), MapScreen(key: _mapKey), const ReportScreen()];

  void goTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        selectedItemColor: const Color(0xFFA27EFF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          setState(() => _index = i);
          if (i == 1) _mapKey.currentState?.reload();
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Mis Reportes'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 28), label: 'Crear Reporte'),
        ],
      ),
    );
  }
}
