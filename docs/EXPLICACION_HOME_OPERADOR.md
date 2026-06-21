# 📱 Explicación: Home Screen Operador (Dart/Flutter)

> Para alguien que conoce React + TypeScript + Vite

---

## 🎯 ¿Qué es este archivo?

Es la **página principal del panel de operador municipal**. Muestra reportes ciudadanos para que el operador los valide y asigne a técnicos.

**Analogía React:** Es como un componente funcional de React que gestiona un dashboard de reportes.

---

## 🔄 Comparación: Dart vs React

### Estructura General

```dart
// DART - Componente con estado
class HomeScreenOperador extends StatefulWidget {
  @override
  State<HomeScreenOperador> createState() => _HomeScreenOperadorState();
}

class _HomeScreenOperadorState extends State<HomeScreenOperador> {
  // Lógica aquí
}
```

**Es equivalente a:**

```typescript
// REACT - Componente funcional con hooks
export function HomeScreenOperador() {
  // Lógica aquí
  return JSX
}
```

---

## 📊 Desglose del Código

### 1️⃣ **Importaciones**

```dart
import 'package:get/get.dart';  // ← Framework de estado (como Redux/Zustand)
import '../../controllers/auth_controller.dart';  // ← Control de autenticación
import '../../controllers/operador_reportes_controller.dart';  // ← Gestión de reportes
```

**En React sería:**
```typescript
import { useAuth } from '@hooks/useAuth'
import { useOperadorReportes } from '@hooks/useOperadorReportes'
```

---

### 2️⃣ **Inicialización del Estado**

```dart
final _auth = Get.find<AuthController>();  // Inyección de dependencias
final _ctrl = Get.find<OperadorReportesController>();
final RxString _filtro = ''.obs;  // Variable reactiva
```

**Equivalente React:**
```typescript
const auth = useAuth();  // Hook personalizado
const { ctrl } = useOperadorReportes();  // Hook personalizado
const [filtro, setFiltro] = useState('');  // Estado local
```

**🔑 Diferencia clave:**
- En Dart con GetX: `RxString` = variable observada reactiva
- En React: `useState` = estado que dispara re-renders

---

### 3️⃣ **Ciclo de Vida (initState)**

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.cargar());
}
```

**En React (equivalente):**
```typescript
useEffect(() => {
  ctrl.cargar();
}, []);  // Se ejecuta 1 sola vez cuando monta el componente
```

📌 **Qué hace:**
- Cuando el componente se carga, ejecuta `_ctrl.cargar()`
- Carga los reportes desde la API

---

### 4️⃣ **Build (Renderizado)**

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(  // ← "Estructura base" de la pantalla
    backgroundColor: const Color(0xFFF4F4F8),
    body: Column(  // ← Stack de componentes vertical
      children: [
        // Componentes aquí
      ],
    ),
  );
}
```

**En React sería:**
```typescript
return (
  <div style={{ backgroundColor: '#F4F4F8' }}>
    <div style={{ display: 'flex', flexDirection: 'column' }}>
      {/* Componentes aquí */}
    </div>
  </div>
)
```

---

## 🎨 Componentes Visuales

### 1. **Header Gradient**
```dart
GradientHeader(
  overline: 'Panel del',
  title: 'Operador Municipal',
  subtitle: 'Gestiona y valida reportes ciudadanos',
  gradient: AppColors.operadorGradient,
  onLogout: () { ... },
),
```

**Equivalente React:**
```typescript
<GradientHeader
  title="Operador Municipal"
  subtitle="Gestiona y valida reportes ciudadanos"
  onLogout={handleLogout}
/>
```

---

### 2. **Contadores (Obx = Observable)**

```dart
Obx(() => CountersRow(children: [
  CounterCard(label: 'Pendientes', value: _ctrl.pendientes, color: ...),
  CounterCard(label: 'En revision', value: _ctrl.enRevision, color: ...),
  CounterCard(label: 'Finalizados', value: _ctrl.finalizados, color: ...),
]))
```

**🔑 `Obx()` en Dart = "Mira estos datos y re-renderiza cuando cambien"**

**En React sería:**
```typescript
{/* Cuando _ctrl.pendientes cambia, se actualiza automáticamente */}
<CountersRow>
  <CounterCard label="Pendientes" value={ctrl.pendientes} />
  <CounterCard label="En revision" value={ctrl.enRevision} />
  <CounterCard label="Finalizados" value={ctrl.finalizados} />
</CountersRow>
```

---

### 3. **Chips de Filtro**

```dart
Obx(() => EstadoFilterChips(
  selected: _filtro.value,  // ← El estado del filtro
  onSelected: (c) => _filtro.value = c  // ← Actualizar filtro
))
```

**En React:**
```typescript
<EstadoFilterChips
  selected={filtro}
  onSelected={(c) => setFiltro(c)}
/>
```

---

### 4. **Lista de Reportes (Condicional)**

```dart
Expanded(
  child: Obx(() {
    if (_ctrl.loading.value) return const Center(child: CircularProgressIndicator());
    
    final list = _ctrl.filtrar(_filtro.value);  // Filtrar reportes
    
    if (list.isEmpty) {
      return const Center(child: Text('No hay reportes en este estado.'));
    }
    
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      children: list
          .map((r) => ReportCard(
                reporte: r,
                mostrarTecnico: r.estado == EstadoReporte.REVISION,
                usarFechaActualizacion: true,
                onTap: () => Get.to(() => GestionReportesScreen(reporteId: r.id)),
              ))
          .toList(),
    );
  }),
)
```

**Desglose:**

| Línea | Qué hace |
|-------|----------|
| `if (_ctrl.loading.value)` | Mostrar spinner mientras carga |
| `_ctrl.filtrar(_filtro.value)` | Filtrar reportes por estado |
| `list.map()` | Convertir cada reporte en un `ReportCard` |
| `onTap: () => Get.to(...)` | Navegar a pantalla de gestión |

**En React:**
```typescript
{loading ? (
  <Spinner />
) : list.length === 0 ? (
  <p>No hay reportes...</p>
) : (
  <ul>
    {list.map((r) => (
      <ReportCard
        key={r.id}
        report={r}
        onClick={() => navigate(`/gestion/${r.id}`)}
      />
    ))}
  </ul>
)}
```

---

## 🧭 Flujo de Datos

```
┌─────────────────────────────────────────┐
│ HomeScreenOperador (StatefulWidget)     │
├─────────────────────────────────────────┤
│ 1. initState() → carga reportes         │
│ 2. OperadorReportesController carga API │
│ 3. Obx() observa cambios                │
│ 4. Usuario selecciona filtro            │
│ 5. filtro.value actualiza               │
│ 6. Obx() detecta cambio y re-renderiza  │
│ 7. Se muestran reportes filtrados       │
└─────────────────────────────────────────┘
```

---

## 📚 Vocabulario Dart → React

| Dart | React | Descripción |
|------|-------|-------------|
| `StatefulWidget` | Componente funcional + hooks | Widget con estado |
| `State<>` | Dentro del componente | Clase que gestiona el estado |
| `initState()` | `useEffect(() => {}, [])` | Se ejecuta al montar |
| `RxString` | `useState<string>` | Variable observable reactiva |
| `Obx()` | Renderizado condicional | "Vigila estos datos y re-renderiza" |
| `@override` | (no existe en JS) | Sobrescribir método |
| `.obs` | (no existe en JS) | Hacer una variable observable |
| `Get.find()` | `useContext()` o custom hook | Inyección de dependencias |
| `Get.to()` | `navigate()` | Cambiar pantalla |
| `const Color(0xFFF4F4F8)` | `'#F4F4F8'` | Color en hex |
| `.value` | acceso directo | Acceder al valor de una variable Rx |

---

## 🔧 GetX (Framework usado)

**GetX es como una combinación de:**
- Redux (gestión de estado)
- React Router (navegación)
- Dependency Injection

```dart
// GetX inyecta controladores
final _ctrl = Get.find<OperadorReportesController>();

// GetX navega entre pantallas
Get.to(() => GestionReportesScreen(reporteId: r.id));

// GetX observa cambios
Obx(() => /*renderizar*/)
```

---

## 📱 Resumen Visual

```
┌──────────────────────────────────┐
│  🎯 Header "Operador Municipal"  │
├──────────────────────────────────┤
│  📊 Contadores                   │
│  ├─ Pendientes: 5                │
│  ├─ En revision: 3               │
│  └─ Finalizados: 12              │
├──────────────────────────────────┤
│  🏷️ COLA DE REPORTES             │
│  🔽 [Todos] [Pendientes] [...]   │
├──────────────────────────────────┤
│  📋 Lista de Reportes            │
│  ├─ [Reporte 1] → Tap = Detalles │
│  ├─ [Reporte 2] → Tap = Detalles │
│  └─ [Reporte N] → ...            │
└──────────────────────────────────┘
```

---

## 🎓 Puntos Clave

✅ **GetX maneja el estado reactivo** - Similar a Zustand/Redux  
✅ **Obx() es la clave de reactividad** - Como conectar Redux a un componente  
✅ **Get.to() navega** - Como useNavigate de React Router  
✅ **initState() es useEffect([])** - Carga inicial de datos  
✅ **StatefulWidget es una clase** - Dart usa clases, React usa funciones  
✅ **No hay JSX** - Dart usa constructores de widgets directamente  

---

## 📌 Siguiente Paso

Para entender mejor, explora:
- `OperadorReportesController` - La lógica de negocio (¡como un hook!)
- `ReportCard` - Componente reutilizable (como un componente React)
- `GradientHeader` - Widget personalizado (como un componente React)
