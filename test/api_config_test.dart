import 'package:flutter_test/flutter_test.dart';
import 'package:reportaya/configs/api_config.dart';

void main() {
  group('ApiConfig.normalizar', () {
    test('agrega esquema y sufijo /api', () {
      expect(ApiConfig.normalizar('192.168.18.8:8081'), 'http://192.168.18.8:8081/api');
    });
    test('respeta https y quita barras finales', () {
      expect(ApiConfig.normalizar('https://reportaya-backend.onrender.com/'),
          'https://reportaya-backend.onrender.com/api');
    });
    test('no duplica /api', () {
      expect(ApiConfig.normalizar('http://10.0.2.2:8081/api/'), 'http://10.0.2.2:8081/api');
    });
  });

  group('ApiConfig.resolverUrlFoto', () {
    test('URL absoluta queda igual', () {
      const u = 'https://firebasestorage.googleapis.com/v0/b/x/o/f.png?alt=media';
      expect(ApiConfig.resolverUrlFoto(u), u);
    });
    test('asset de demo queda igual', () {
      expect(ApiConfig.resolverUrlFoto('assets/img/sample/hueco_1.png'),
          'assets/img/sample/hueco_1.png');
    });
    test('ruta del backend se resuelve contra el servidor actual', () {
      final r = ApiConfig.resolverUrlFoto('/media/fotos/abc');
      expect(r.endsWith('/media/fotos/abc'), isTrue);
      expect(r.contains('/api/media'), isFalse);
    });
  });
}
