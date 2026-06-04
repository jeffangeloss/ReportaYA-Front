# Análisis de arquitectura y flujo — ReportaYA-Front

> Entrega 2 · Todo corre en local (sin backend REST). El LocalStore actúa como base de datos en memoria sembrada desde JSON.

---

## 1. Visión general de capas

```
┌────────────────────────────────────────────────────────────────────┐
│  SCREENS  (UI + lógica de presentación)                            │
│  Auth:     SplashScreen → LoginScreen / RegisterScreen             │
│  Ciudadano: MainTabs → InicioScreen | MapScreen | ReportScreen     │
│                         MisReportesScreen → DetalleScreen          │
│  Operador: HomeScreenOperador → GestionReportesScreen              │
│  Técnico:  HomeScreenTecnico  → EjecutarReporteScreen              │
├────────────────────────────────────────────────────────────────────┤
│  CONTROLLERS  (estado reactivo con GetX)                           │
│  AuthController · ReportesController · OperadorReportesController  │
│  TecnicosController · TecnicoReportesController · TabsController   │
├────────────────────────────────────────────────────────────────────┤
│  SERVICES  (lógica de negocio y acceso a datos)                    │
│  ServicioAuth · ServicioCuenta · ServicioReportes                  │
│  ServicioTecnicos · ServicioGeocoding                              │
├────────────────────────────────────────────────────────────────────┤
│  DATA  (almacén singleton en memoria)                              │
│  LocalStore  ←  assets/data/{cuentas,reportes,historial,fotos}.json│
├────────────────────────────────────────────────────────────────────┤
│  MODELS  (contratos de datos)                                      │
│  enums · auth · cuenta · reporte · tecnico · foto · ubicacion      │
└────────────────────────────────────────────────────────────────────┘
```

El flujo general es siempre **Screen → Controller → Service → LocalStore**. Ninguna pantalla llama directamente al LocalStore; pasan obligatoriamente por un servicio.

---

## 2. Capa DATA — `LocalStore`

**Archivo:** `lib/data/local_store.dart`

Singleton que se inicializa una sola vez en `main()` con `await LocalStore.instance.seed()`. Carga los cuatro JSON de `assets/data/` y los mantiene en listas en memoria:

| Lista | JSON fuente | Crece en runtime? |
|---|---|---|
| `cuentas` | `cuentas.json` | Sí (CU-02 registro) |
| `reportes` | `reportes.json` | Sí (CU-04 crear) |
| `historial` | `historial.json` | Sí (cada cambio de estado) |
| `fotos` | `fotos.json` | Sí (al crear / finalizar) |
| `tecnicos` | *derivado de cuentas* | No (solo activos con rol TECNICO) |

Los IDs se autoincrementan con contadores internos (`_reporteSeq`, etc.) que arrancan en el máximo del JSON semilla + 1.

**Helpers clave:**
- `indexReporte(id)` → índice en la lista para mutación.
- `fotosDe(reporteId, {tipo})` → fotos filtradas por tipo (`INICIAL` / `FINAL`).
- `historialDe(reporteId)` → historial ordenado por fecha.
- `registrarCambioEstado(...)` → inserta en `historial` automáticamente.

> **Limitación:** Al reiniciar la app, `LocalStore` se re-siembra desde los JSON. Los datos creados en sesión (cuentas nuevas, reportes nuevos) se pierden.

---

## 3. Capa MODELS

### `enums.dart`
Define las constantes de dominio como clases con `static const String`:

| Clase | Valores |
|---|---|
| `EstadoReporte` | `PENDIENTE` · `REVISION` · `FINALIZADO` · `RECHAZADO` |
| `TipoProblema` | `INFRAESTRUCTURA` · `RESIDUOS` · `SEGURIDAD` · `ALUMBRADO` · `OTRO` |
| `TipoFoto` | `INICIAL` (ciudadano) · `FINAL` (técnico) |
| `TipoCuenta` | `CIUDADANO` · `TECNICO` · `OPERADOR_MUNICIPAL` |

### `auth.dart`
- `AuthLoginRequest` — credenciales enviadas por el cliente.
- `AuthLoginResponse` — respuesta del login con `cuentaId`, `tipoCuenta`, `token`.
- `UsuarioAutenticado` — objeto en memoria de la sesión activa; incluye `loginTime` para el TTL de 24h; se serializa a/desde `GetStorage`.

### `cuenta.dart`
- `CrearCuentaRequest` — payload de registro (solo `CIUDADANO`).
- `CuentaResponse` — registro completo de cuenta, con `contrasena` solo para uso interno del JSON semilla.

### `reporte.dart`
- `ReporteResponse` — objeto principal de la app. Contiene todos los campos que cambian durante el ciclo de vida: `estado`, `tecnicoAsignadoId`, `comentarioResolucion`, `fechaCierre`. Incluye `copyWith` para mutaciones inmutables.
- `CrearReporteRequest` — payload de alta de reporte.
- `FiltrosReporte` — filtros opcionales de estado, tipo y búsqueda (uso interno).
- `HistorialEstado` — una entrada del timeline de cambios de estado.

### `foto.dart`
- `Foto` — una foto asociada a un reporte, con `tipo` (`INICIAL`/`FINAL`), `url` y `fechaCarga`.

### `tecnico.dart`
- `TecnicoResponse` — datos del técnico (derivado de `CuentaResponse`).
- `FotoRequest` / `CompletarReporteRequest` / `CompletarReporteResponse` — contratos preparados para la API REST futura, actualmente sin uso en la UI.

### `ubicacion.dart`
- `Ubicacion` — coordenadas + dirección textual.
- `CrearUbicacionRequest` — payload de alta de ubicación.

---

## 4. Capa SERVICES

Cada servicio recibe datos de la pantalla/controller, opera sobre `LocalStore` y devuelve objetos de modelo. En la entrega 3/4 solo cambia la implementación interna (LocalStore → HTTP), no las firmas públicas.

### `ServicioAuth` — `CU-01`
- `login(usuario, password)` → busca en `LocalStore.cuentas` por usuario (case-insensitive), valida contraseña, retorna `AuthLoginResponse` con un token simulado `'local-token-XXX'`.
- No implementa refresh de token ni logout en el servidor (solo limpia en cliente).

### `ServicioCuenta` — `CU-02`
- `crearCuenta(req)` → valida unicidad de `usuario` y `correo`, asigna un nuevo ID y agrega a `LocalStore.cuentas`.
- Solo crea cuentas de tipo `CIUDADANO`.

### `ServicioReportes` — `CU-04 / CU-05 / CU-06 / CU-07 / CU-08`
Es el servicio más completo. Todas sus operaciones simulan latencia con `Future.delayed`.

| Método | Descripción |
|---|---|
| `obtenerReportesPorCuenta(cuentaId)` | Reportes del ciudadano actual, orden desc por creación |
| `obtenerRecientes(cuentaId)` | Primeros 5 del ciudadano |
| `obtenerTodos({estado})` | Todos los reportes (operador), orden desc por actualización |
| `obtenerParaMapa()` | Todos los reportes sin filtro de cuenta (mapa ciudadano) |
| `obtenerAsignadosATecnico(tecnicoId)` | Reportes donde `tecnicoAsignadoId == tecnicoId` |
| `obtenerDetalle(id)` | Reporte por ID |
| `obtenerHistorialEstados(reporteId)` | Historial ordenado |
| `obtenerFotos(reporteId, {tipo})` | Fotos filtradas por tipo (`INICIAL` / `FINAL` / todas) |
| `contarPorEstado()` | Mapa `estado → count` (operador) |
| `contarPorEstadoTecnico(tecnicoId)` | Conteos REVISION/FINALIZADO del técnico |
| `crearReporte(req, urlsFotos)` | Alta del reporte + fotos INICIAL + historial |
| `aceptarReporte(id)` | PENDIENTE → REVISION |
| `rechazarReporte(id, motivo)` | PENDIENTE → RECHAZADO + `comentarioResolucion` |
| `asignarTecnico(id, tecnico)` | Vincula técnico, mantiene estado REVISION |
| `finalizarReporte(id, comentario, fotos)` | REVISION → FINALIZADO + fotos FINAL |

### `ServicioTecnicos` — `CU-07`
- `obtenerDisponibles()` → todos los técnicos activos de `LocalStore.tecnicos`.
- No implementa disponibilidad real (carga de trabajo, estado libre/ocupado).

### `ServicioGeocoding` — `CU-04`
- `obtenerDireccion(lat, lng)` → devuelve una `DireccionCompleta` con valores hardcoded de Lima.
- En entrega 3/4 se conectará a Nominatim/Google Maps Geocoding API.

---

## 5. Capa CONTROLLERS

Todos registrados como permanentes en `main()` via `Get.put(..., permanent: true)`. Usan `RxList` / `RxBool` para reactividad automática en `Obx()`.

### `AuthController`
- Maneja el ciclo de sesión completo: `verificarAutenticacionInicial()` lee `GetStorage` al arrancar; `login()` escribe; `logout()` limpia.
- Expone `isCiudadano`, `isTecnico`, `isOperador`, `cuentaId` para que las pantallas no toquen el modelo directamente.
- Estado: enum `AuthState` (`checking` / `authenticated` / `unauthenticated`).

### `ReportesController`
- Gestiona la lista de reportes **del ciudadano activo**.
- `cargarReportes(cuentaId)` rellena `reportes` (RxList).
- `filtrar({estado, busqueda})` filtra en memoria para `MisReportesScreen`.
- `recientes` → slice de los 5 más recientes para `InicioScreen`.

### `OperadorReportesController`
- Gestiona todos los reportes para el operador.
- `cargar()` → `obtenerTodos()` sin filtro.
- `aceptar()`, `rechazar()`, `asignar()` llaman al servicio **y luego llaman a `cargar()`** para refrescar la lista reactiva automáticamente.
- `filtrar(estado)` filtra en memoria la `RxList` para los chips de `HomeScreenOperador`.
- Counters reactivos: `pendientes`, `enRevision`, `finalizados`.

### `TecnicosController`
- Carga la lista de técnicos disponibles (para el bottom sheet de asignación).
- Se llama con `await tc.cargar()` justo antes de abrir el modal.

### `TecnicoReportesController`
- Gestiona las asignaciones del técnico activo.
- `cargar(tecnicoId)` → `obtenerAsignadosATecnico(tecnicoId)`.
- `finalizar()` llama al servicio y luego recarga.
- Getters reactivos: `pendientes` (REVISION), `completados` (FINALIZADO), `porAtender`, `resueltos`.

### `TabsController`
- Definido dentro de `main_tabs.dart` (no en un archivo propio).
- Controla el índice activo del `IndexedStack` del ciudadano.
- `go(int i)` cambia la pestaña activa. `MapScreen` escucha este observable mediante un `Worker` para recargarse automáticamente.

---

## 6. Capa SCREENS

### Flujo Autenticación

| Pantalla | Rol | Descripción |
|---|---|---|
| `SplashScreen` | Todos | Lee el `AuthState` y redirige según rol. Muestra spinner mientras verifica. |
| `LoginScreen` | Todos | Formulario usuario + contraseña. Redirige a `mainTabs`, `homeOperador` o `homeTecnico` según `tipoCuenta`. |
| `RegisterScreen` | Ciudadano | 7 campos. Llama directamente a `ServicioCuenta` (sin controller). Tras éxito usa `Get.offAllNamed(AppRoutes.login)` para garantizar navegación limpia al login. |

### Flujo Ciudadano (`MainTabs`)

Usa `IndexedStack` — las 4 pestañas se mantienen vivas en memoria:

| Pestaña | Pantalla | CU | Qué hace |
|---|---|---|---|
| 0 Inicio | `InicioScreen` | CU-05 | Saludo, 2 accesos rápidos (Reportar / Mis reportes), últimos 5 reportes del ciudadano. |
| 1 Mapa | `MapScreen` | CU-05 | Lista de todos los reportes con leyenda de colores por estado. **Se recarga automáticamente cada vez que el usuario activa este tab** (Worker sobre `TabsController.index`). Toca → `DetalleScreen`. |
| 2 Reportar | `ReportScreen` | CU-04 | Formulario de alta: título, tipo, descripción, ubicación (hardcoded), fotos (contador). Tras envío recarga `ReportesController` y redirige a pestaña Mis reportes. |
| 3 Mis reportes | `MisReportesScreen` | CU-05 | Lista propia del ciudadano con chips de estado + buscador por título. Toca → `DetalleScreen`. |

**`DetalleScreen`** — CU-05: vista de solo lectura del reporte. Carga todas las fotos del reporte (INICIAL y FINAL) + historial de estados. Muestra contenido extra según estado:
- `PENDIENTE` → callout informativo.
- `REVISION` → nombre del técnico asignado (o "Sin asignar").
- `FINALIZADO` → técnico asignado, comentario de resolución, `FotosStrip` de fotos FINAL.
- `RECHAZADO` → motivo del rechazo.

### Flujo Operador

| Pantalla | CU | Qué hace |
|---|---|---|
| `HomeScreenOperador` | CU-06/07 | Cola de todos los reportes con chips de filtro por estado y 3 contadores (Pendiente / En revisión / Finalizado). Toca → `GestionReportesScreen`. |
| `GestionReportesScreen` | CU-06/07/08 | Carga fotos `INICIAL` y `FINAL` del reporte al entrar. Muestra el detalle completo. Acciones condicionales por estado: **PENDIENTE** → botones Aceptar / Rechazar; **REVISION** → botón Asignar/Reasignar Técnico (bottom sheet); **FINALIZADO** → callout verde + comentario del técnico + `FotosStrip` de fotos FINAL; **RECHAZADO** → callout con motivo. Rechazar navega de vuelta a la cola con `Get.until`. |

### Flujo Técnico

| Pantalla | CU | Qué hace |
|---|---|---|
| `HomeScreenTecnico` | CU-08 | Asignaciones del técnico divididas en 2 secciones: **MIS ASIGNACIONES** (reportes en REVISION) y **RESUELTOS** (reportes FINALIZADO). Ambas secciones navegan a `EjecutarReporteScreen`. |
| `EjecutarReporteScreen` | CU-08 | 2 pestañas con comportamiento diferente según `r.estado`: |

**Pestaña Información (`EjecutarReporteScreen`):**
- Muestra estado, datos del reporte, mapa placeholder.
- Si `REVISION`: botón "Iniciar trabajo de campo" que lleva al tab Evidencia.
- Si `FINALIZADO`: callout informativo en lugar del botón (el proceso no se puede reiniciar).

**Pestaña Evidencia (`EjecutarReporteScreen`):**
- Siempre muestra las fotos `INICIAL` del ciudadano arriba (`FotosStrip`).
- Si `REVISION`: formulario editable (comentario de resolución + selector de fotos + botón "Finalizar reporte").
- Si `FINALIZADO`: vista de solo lectura con el comentario guardado y las fotos `FINAL` de resolución. Sin botones de acción.

---

## 7. Capa WIDGETS

| Widget | Dónde se usa | Qué hace |
|---|---|---|
| `ReportCard` | `InicioScreen`, `MisReportesScreen`, `HomeScreenOperador`, `HomeScreenTecnico` | Tarjeta reutilizable con barra de color por estado, ícono de tipo, dirección, fecha y `EstadoPill`. Acepta flags `mostrarTecnico` y `usarFechaActualizacion`. |
| `EstadoPill` | `ReportCard`, `DetalleScreen`, `GestionReportesScreen`, `EjecutarReporteScreen` | Chip con fondo del color del estado y texto en mayúsculas. |
| `FotosStrip` | `DetalleScreen`, `GestionReportesScreen`, `EjecutarReporteScreen` | Tira horizontal de `FotoThumb`. Muestra un placeholder si la lista está vacía. |
| `FotoThumb` | Dentro de `FotosStrip` | Miniatura que abre visor fullscreen (`InteractiveViewer`) al tocar. |
| `AppColors` | Toda la app | Fuente única de colores, gradientes, mapeo `estado → Color` y `tipo → IconData`. |
| `AppToast` | Toda la app | Snackbars con GetX en 3 variantes: `success`, `error`, `info`. |
| `GradientScaffold` | `LoginScreen`, `RegisterScreen`, `SplashScreen` | Scaffold con fondo degradado configurable. |
| `GradientHeader` | Pantallas principales | Cabecera con gradiente, título, subtítulo y botón de logout opcional. |
| `WhiteCard` | Vistas de detalle | Contenedor blanco con `borderRadius` y padding estándar para agrupar campos. |
| `KeyValue` | Vistas de detalle | Fila de etiqueta + valor con estilos consistentes. |
| `InfoCallout` | `EjecutarReporteScreen`, `GestionReportesScreen`, `DetalleScreen` | Caja informativa con fondo y texto de color configurable. |
| `WideButton` | Vistas de acción | Botón ancho con ícono, color y estado deshabilitado. |
| `CounterCard` / `CountersRow` | `HomeScreenTecnico`, `HomeScreenOperador` | Tarjetas de contador con color por estado. |
| `SectionLabel` | Varias | Texto de sección en mayúsculas con color. |

**Utilidades:**
- `fechas.dart`: `fmtFecha(iso)` y `fmtFechaHora(iso)` usando `intl` con locale `es`.

---

## 8. Routing

| Ruta | Pantalla | Quién navega allí |
|---|---|---|
| `/` | `SplashScreen` | App start |
| `/login` | `LoginScreen` | Splash, logout, registro exitoso |
| `/register` | `RegisterScreen` | LoginScreen |
| `/main` | `MainTabs` | Login (ciudadano) |
| `/operador` | `HomeScreenOperador` | Login (operador), `Get.until` tras rechazar reporte |
| `/tecnico` | `HomeScreenTecnico` | Login (técnico) |

`GestionReportesScreen`, `EjecutarReporteScreen` y `DetalleScreen` se navegan con `Get.to()` sin nombre de ruta (rutas anónimas en el stack).

---

## 9. Inicialización en `main()`

```
main()
 ├─ GetStorage.init()            ← persistencia de sesión
 ├─ initializeDateFormatting()   ← locale 'es' para intl
 ├─ LocalStore.instance.seed()   ← carga JSON assets en memoria
 └─ Get.put() × 5 controllers    ← AuthController (permanent)
                                    ReportesController (permanent)
                                    OperadorReportesController (permanent)
                                    TecnicosController (permanent)
                                    TecnicoReportesController (permanent)
```

`TabsController` se registra más tarde con `Get.put` dentro de `MainTabs.build()`. Eso es seguro porque solo el ciudadano llega a `MainTabs`.

---

## 10. Estado de implementación por Caso de Uso

### CU-01 — Iniciar sesión ✅ Implementado

| Punto del flujo | Estado |
|---|---|
| Formulario usuario / contraseña | ✅ |
| Validación de credenciales contra LocalStore | ✅ |
| Redirección por rol (Ciudadano / Operador / Técnico) | ✅ |
| Token simulado en memoria | ✅ (cadena literal, sin JWT real) |
| Mensaje de error por credenciales incorrectas | ✅ |

---

### CU-02 — Registrarse ✅ Implementado

| Punto del flujo | Estado |
|---|---|
| Formulario 7 campos (nombres, apellidos, DNI, teléfono, correo, usuario, contraseña) | ✅ |
| Validación de campos no vacíos | ✅ |
| Validación de unicidad de usuario y correo | ✅ |
| Creación de cuenta CIUDADANO en LocalStore | ✅ |
| Redirección a Login tras registro exitoso (pila limpia) | ✅ |
| Validación de formato/longitud de campos | ✅ Validación de campos vacios, DNI, teléfono, correo y contrseña |

---

### CU-03 — Recuperar contraseña ❌ No implementado

- El botón "¿Olvidaste tu contraseña?" en `LoginScreen` llama a `AppToast.info('Función no implementada aún')`.
- Faltan las vistas **08 Recuperar contraseña** y **09 Restablecer contraseña**.
- Requiere backend o Firebase Auth para el envío de correo.

---

### CU-04 — Reportar incidencia ⚠️ Parcialmente implementado

| Punto del flujo | Estado |
|---|---|
| Formulario título / tipo / descripción | ✅ |
| Reporte creado en PENDIENTE con fotos INICIAL | ✅ |
| Redirección a Mis reportes tras envío | ✅ |
| Selección de ubicación en mapa interactivo | ❌ Hardcoded a `(-12.08530, -77.03760)` |
| Adjuntar fotos reales (cámara / galería) | ❌ `_fotos` es un contador entero; se guardan paths de assets de muestra |
| Upload de fotos a Firebase Storage | ❌ Sin integración |
| Validación de longitud/formato de campos | ❌ Solo valida "no vacío" |

---

### CU-05 — Consultar reportes ⚠️ Parcialmente implementado

| Punto del flujo | Estado |
|---|---|
| Listado de reportes recientes en Inicio | ✅ |
| Vista Detalle con estado condicional (pendiente / revisión / finalizado / rechazado) | ✅ |
| Fotos INICIAL del ciudadano en Detalle | ✅ |
| Fotos FINAL del técnico en Detalle (cuando FINALIZADO) | ✅ |
| Cronología de cambios de estado | ✅ |
| Mis reportes con filtro por estado y buscador | ✅ |
| Vista Mapa con lista de reportes y leyenda de colores | ✅ |
| Mapa se recarga automáticamente al navegar al tab | ✅ (Worker sobre TabsController.index) |
| Mapa interactivo real con marcadores por lat/lng | ❌ Es una lista de tiles, no un mapa real |
| Notificaciones push de cambio de estado | ❌ Sin FCM |
| Mapa en `DetalleScreen` | ❌ Placeholder de ícono estático |

---

### CU-06 — Validar reportes ⚠️ Parcialmente implementado

| Punto del flujo | Estado |
|---|---|
| Cola de reportes con filtros y contadores | ✅ |
| Vista Gestión con fotos INICIAL del ciudadano | ✅ |
| Aceptar reporte (PENDIENTE → REVISION) | ✅ |
| Rechazar reporte con motivo | ✅ |
| Redirigir a Cola tras rechazar | ✅ |
| Ver fotos FINAL y comentario del técnico cuando FINALIZADO | ✅ |
| Mapa de ubicación en vista Gestión | ❌ Placeholder estático |
| Notificación al ciudadano (aceptado/rechazado) | ❌ Sin FCM |

---

### CU-07 — Asignar técnicos ⚠️ Parcialmente implementado

| Punto del flujo | Estado |
|---|---|
| Bottom sheet con lista de técnicos activos | ✅ |
| Asignar técnico sin cambiar estado | ✅ |
| Reasignar técnico ya asignado | ✅ |
| Disponibilidad real del técnico (carga de trabajo) | ❌ Se muestran todos los activos sin filtro |
| Notificación al ciudadano y al técnico | ❌ Sin FCM |

---

### CU-08 — Atender reportes ⚠️ Parcialmente implementado

| Punto del flujo | Estado |
|---|---|
| Lista de asignaciones con sección **Por atender** (REVISION) | ✅ |
| Lista de asignaciones con sección **Resueltos** (FINALIZADO) | ✅ |
| Tab Información con datos del reporte | ✅ |
| Botón "Iniciar trabajo de campo" visible solo si estado es REVISION | ✅ |
| Tab Evidencia con fotos INICIAL del ciudadano visibles | ✅ |
| Formulario de resolución (comentario + fotos) solo en REVISION | ✅ |
| Vista de solo lectura (comentario + fotos FINAL) cuando FINALIZADO | ✅ |
| Finalizar reporte (REVISION → FINALIZADO) | ✅ |
| Adjuntar fotos de solución reales | ❌ Contador entero, paths de assets de muestra |
| Mapa de ubicación en EjecutarReporteScreen | ❌ Placeholder estático |
| Notificación al ciudadano | ❌ Sin FCM |

---

## 11. Pendientes transversales (todos los CU)

| Pendiente | Descripción |
|---|---|
| **Backend REST** | Todos los servicios usan `LocalStore`. En entrega 3/4 se reemplazan por llamadas HTTP (Dio/http). Los modelos y firmas de servicio ya están diseñados para eso. |
| **Persistencia entre sesiones** | `LocalStore` se re-siembra en cada arranque. Los datos creados en sesión se pierden al cerrar la app. |
| **Picker de imágenes real** | `image_picker` no está integrado. Las fotos son assets de muestra con un contador entero. |
| **Mapa real** | Sin `google_maps_flutter` / `flutter_map`. La vista de mapa es una lista y los mapas en pantallas de detalle son placeholders. |
| **GPS / geolocalización** | Sin `geolocator`. La coordenada es hardcoded. |
| **Geocoding real** | `ServicioGeocoding` devuelve dirección hardcoded. En entrega 3/4 conectar a Nominatim o Google Geocoding. |
| **Notificaciones push** | Ningún flujo notifica al ciudadano ni al técnico. Requiere Firebase Messaging (FCM). |
| **Validación de formularios** | Solo valida "no vacío". Faltan: formato email, longitud DNI, longitud mínima de contraseña, longitud máxima de descripción. |
| **Manejo de errores de red** | Los servicios locales no fallan (excepto por excepción lógica). Con backend real habrá que manejar timeouts, 401, 500. |
| **Seguridad del token** | El token es la cadena literal `'local-token-XXX'`. En entrega 3/4 debe ser un JWT real con validación. |
| **Contraseña en texto plano en JSON** | `cuentas.json` tiene contraseñas en claro. En producción deben almacenarse con hash. |
| **Disponibilidad de técnicos** | `ServicioTecnicos.obtenerDisponibles()` devuelve todos los activos sin considerar carga de trabajo. |
| **CU-03 — Recuperar contraseña** | Vistas 08 y 09 no implementadas. Botón en login muestra toast de "no implementado". |
