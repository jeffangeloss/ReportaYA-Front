# Auditoría de dependencias — ReportaYA-Front

**Fecha:** 2026-05-29
**Toolchain:** Flutter 3.44.0 (stable) · Dart 3.12.0 · Android SDK 36.1.0 · AGP 8.11.1 · Kotlin 2.2.20 · Gradle 8.14 · JDK 17

Auditoría de las 12 dependencias directas tras el reporte de "21 paquetes desactualizados" de hace ~1 mes. Resultado: el `pubspec.lock` ya se había re-resuelto, así que casi todas las directas estaban al tope de su constraint `^`. Solo había upgrades **major** disponibles.

---

## ✅ Aplicado esta sesión (upgrades seguros, sin tocar código)

Subida de `intl` a su nuevo major (bajo riesgo: la app solo usa `DateFormat(patrón, locale).format()` + `initializeDateFormatting`, ambos estables en 0.20) más las transitivas que `flutter pub upgrade` movió dentro de constraints.

| Paquete | Antes | Después | Tipo |
|---|---|---|---|
| **intl** (directa) | 0.19.0 | **0.20.2** | major 0.x — `pubspec.yaml` `^0.19.0` → `^0.20.0` |
| code_assets | 1.0.0 | 1.2.0 | transitiva |
| hooks | 1.0.3 | 2.0.0 | transitiva |
| objective_c | 9.3.0 | 9.4.1 | transitiva |
| vector_graphics_compiler | 1.2.3 | 1.2.4 | transitiva |
| vm_service | 15.1.0 | 15.2.0 | transitiva |

Eliminadas del árbol (ya no se dependen): `file 7.0.1`, `glob 2.1.3`, `native_toolchain_c 0.17.6`.

**Validación:** `flutter build apk --debug` → OK (`app-debug.apk` generado). `flutter analyze` → 36 issues, **idénticas al baseline previo, 0 nuevas**. Las subidas no rompieron nada.

---

## ⏸️ Majors diferidos (requieren leer changelog + posibles cambios de código/nativo)

No se aplicaron. Cada uno necesita su propia sesión con pruebas.

| Paquete | Actual | Latest | Por qué se difiere | Changelog |
|---|---|---|---|---|
| firebase_core | 3.15.2 | 4.9.0 | Va en lockstep con firebase_messaging (BoM Firebase). Sube mínimos de plataforma; revisar deploy target iOS y config nativa Android. | https://pub.dev/packages/firebase_core/changelog |
| firebase_messaging | 15.2.10 | 16.2.2 | Atado a firebase_core 4.x. Posibles cambios en `onBackgroundMessage` / APNs iOS. | https://pub.dev/packages/firebase_messaging/changelog |
| geolocator | 13.0.4 | 14.0.2 | Cambios en `LocationSettings` y manejo de permisos Android. | https://pub.dev/packages/geolocator/changelog |
| permission_handler | 11.4.0 | 12.0.1 | Permiso de fotos parciales Android 14/15, requisitos AGP/compileSdk, cambios de manifest. | https://pub.dev/packages/permission_handler/changelog |

**Orden sugerido:** primero firebase_core + firebase_messaging juntos (mayor riesgo nativo), luego geolocator y permission_handler (acoplados a permisos/manifest Android). **No usar `flutter pub upgrade --major-versions`** a ciegas.

---

## ❌ Warning KGP / Built-in Kotlin — SIGUE VIGENTE

Contrario a lo esperado por la config Android moderna, `flutter build apk --debug` con Flutter 3.44 **sí emite el warning KGP**. Son dos cosas distintas:

1. **La app aplica el Kotlin Gradle Plugin explícitamente.** `android/settings.gradle.kts` declara `org.jetbrains.kotlin.android`, `android/app/build.gradle.kts` aplica `kotlin-android`, y `android/gradle.properties` tiene `android.builtInKotlin=false`. Flutter pide migrar a **Built-in Kotlin**.
   → Guía: https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers
   → Acción: poner `android.builtInKotlin=true` y quitar el plugin Kotlin explícito. **Es cambio de Gradle, no de dep** → requiere build de prueba (puede romper). Fuera de alcance de "solo upgrades de deps".

2. **Plugins que aún aplican KGP:** `image_picker_android` (0.8.13+17) y `webview_flutter_android` (4.12.0). Son transitivos de `image_picker` (1.2.2) y `webview_flutter` (4.13.1), **ambos ya en su última versión** dentro de los constraints actuales — no hay versión más nueva a la que mover hoy. Depende de que los autores de esos plugins migren a Built-in Kotlin.

**Mensaje exacto del build:**
> Future versions of Flutter will fail to build if your app uses plugins that apply KGP: `image_picker_android`, `webview_flutter_android`.

Hoy es solo warning (el build pasa). Pendiente real para una sesión futura.

---

## 📝 Deuda separada — issues de `flutter analyze` (baseline, NO relacionada con deps)

36 issues pre-existentes, sin cambios tras los upgrades:

- **1 error:** `test/widget_test.dart:16` referencia `MyApp` (clase inexistente — test boilerplate roto). Arreglo trivial: actualizar el test al widget raíz real.
- **2 warnings:** import sin uso (`lib/screens/map_screen.dart:4` `package:get/get.dart`), variable sin uso (`lib/widgets/report_detail_modal.dart:30` `ubicacionTexto`).
- **~32 info:** `avoid_print` (x3), `constant_identifier_names` (~20 en `lib/models/enums.dart`, constantes UPPERCASE), `deprecated_member_use` (`withOpacity` → `withValues()`, ~8), `unnecessary_underscores`, `unnecessary_string_interpolations`.

---

## Notas de entorno

- `pubspec.lock` tenía **drift sin commitear** previo a esta sesión: el lock committeado en HEAD es muy viejo (era de Flutter ~3.19, `flutter: ">=3.18.0-18.0.pre.54"`). Al commitear, el diff vs HEAD se verá enorme — no es solo de esta sesión.
- `flutter pub get` en Windows imprime *"Building with plugins requires symlink support — enable Developer Mode"*. Es benigno (el APK compiló igual); para silenciarlo, activar **Developer Mode** en Windows (`start ms-settings:developers`).
