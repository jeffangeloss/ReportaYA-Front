import 'package:get/get.dart';

/// Controla la pestana activa del flujo Ciudadano.
class TabsController extends GetxController {
  final RxInt index = 0.obs;
  void go(int i) => index.value = i;
}
