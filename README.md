# ReportaYA

## Contenido

- [1. Descripcion del proyecto](#1-descripcion-del-proyecto)
- [2. Integrantes](#2-integrantes)
- [3. Entorno de desarrollo](#3-entorno-de-desarrollo)
  - [3.1 Entorno configurado en macOS](#31-entorno-configurado-en-macos)
  - [3.2 Configuracion de Flutter SDK y PATH](#32-configuracion-de-flutter-sdk-y-path)
  - [3.3 Configuracion para iOS con Xcode](#33-configuracion-para-ios-con-xcode)
  - [3.4 Configuracion para Android con Android Studio](#34-configuracion-para-android-con-android-studio)
  - [3.5 Herramientas complementarias](#35-herramientas-complementarias)
  - [3.6 Verificacion general en macOS](#36-verificacion-general-en-macos)
  - [3.7 Configuracion del entorno en Windows](#37-configuracion-del-entorno-en-windows)
  - [3.8 Ejecucion y validacion del proyecto](#38-ejecucion-y-validacion-del-proyecto)
- [4. Tecnologias utilizadas](#4-tecnologias-utilizadas)
- [5. Requisitos funcionales](#5-requisitos-funcionales)
- [6. Requisitos no funcionales](#6-requisitos-no-funcionales)
- [7. Diagrama de casos de uso](#7-diagrama-de-casos-de-uso)
- [8. Descripcion de casos de uso](#8-descripcion-de-casos-de-uso)
- [9. Mockups](#9-mockups)
- [10. Diagrama de despliegue](#10-diagrama-de-despliegue)
- [11. Instalacion y ejecucion del proyecto](#11-instalacion-y-ejecucion-del-proyecto)
- [12. Estructura base del proyecto](#12-estructura-base-del-proyecto)
- [13. Pendientes](#13-pendientes)

## 1. Descripcion del proyecto
> Completar por el equipo.

## 2. Integrantes
> Completar nombres, codigos y responsabilidades.

## 3. Entorno de desarrollo

Esta seccion describe la configuracion del entorno necesaria para desarrollar y ejecutar el proyecto Flutter **ReportaYA**. El objetivo es que cualquier integrante del equipo pueda preparar su equipo, validar las herramientas instaladas y ejecutar el proyecto en Android o iOS.

La preparacion se realizo tomando como referencia la documentacion oficial de Flutter:

- [Comenzar: Instalar en macOS - Flutter](https://flutter-website-staging.firebaseapp.com/setup-macos/).
- `Add Flutter to your PATH.pdf`.
- `Configurar el desarrollo de Windows.pdf`.

Flutter requiere tres bloques principales de configuracion:

1. **Flutter SDK y variable PATH**, para ejecutar comandos como `flutter` y `dart` desde la terminal.
2. **Herramientas de plataforma**, como Xcode para iOS y Android Studio con Android SDK para Android.
3. **Verificacion del entorno**, usando comandos como `flutter doctor -v`, `flutter devices`, `flutter pub get` y `flutter run`.

### 3.1 Entorno configurado en macOS

En macOS se preparo el entorno principal para desarrollo Android e iOS.

Herramientas utilizadas:

- Sistema operativo: macOS 26.4.1.
- Xcode: 26.4, build 17E192.
- Android Studio: utilizado para gestionar Android SDK y emuladores.
- Android SDK: 36.1.0.
- Java JDK: OpenJDK 17.0.18.
- CocoaPods: 1.16.2.
- Flutter SDK: 3.41.6, canal stable.
- Dart SDK: 3.11.4, incluido con Flutter.
- IDE recomendado: Visual Studio Code o Android Studio con los plugins de Flutter y Dart.

### 3.2 Configuracion de Flutter SDK y PATH

Para poder usar Flutter desde cualquier terminal, el directorio `bin` del SDK debe estar agregado a la variable de entorno `PATH`. Esto aplica tanto para macOS como para Windows.

En macOS, la ruta del SDK utilizada fue:

```text
/Users/jjjangelosss/develop/flutter
```

Por lo tanto, el directorio que debe estar disponible en el `PATH` es:

```text
/Users/jjjangelosss/develop/flutter/bin
```

En equipos macOS con Zsh, la configuracion puede agregarse en `~/.zprofile`:

```bash
export PATH="$HOME/develop/flutter/bin:$PATH"
```

Luego se debe cerrar y volver a abrir la terminal, o recargar la configuracion del shell. La verificacion se realiza con:

```bash
flutter --version
dart --version
```

**Version de Flutter en macOS**

<img src="./docs/images/flutter-version-macos-compact.png" alt="Flutter version en macOS" width="700">

La captura evidencia que Flutter esta instalado en el canal `stable`, version `3.41.6`. Tambien confirma Dart `3.11.4` y DevTools `2.54.2`. Dart no requiere instalacion separada, ya que viene incluido con Flutter.

### 3.3 Configuracion para iOS con Xcode

Para desarrollar y ejecutar aplicaciones Flutter en iOS, macOS requiere Xcode. Esta herramienta permite compilar el proyecto para dispositivos iOS o simuladores, y tambien provee herramientas de linea de comandos necesarias para Flutter.

Comandos de verificacion utilizados:

```bash
xcodebuild -version
xcode-select -p
```

**Version de Xcode**

<img src="./docs/images/xcode-version-macos-compact.png" alt="Version de Xcode en macOS" width="700">

La captura confirma la instalacion de Xcode `26.4`, build `17E192`.

**Xcode instalado**

<img src="./docs/images/xcode-app-macos-compact.png" alt="Xcode instalado en macOS" width="700">

La captura muestra la ventana "About Xcode", donde se valida visualmente la version instalada.

**Herramientas de linea de comandos de Xcode**

<img src="./docs/images/xcode-select-macos-compact.png" alt="Xcode command line tools en macOS" width="700">

El comando `xcode-select -p` devuelve `/Applications/Xcode.app/Contents/Developer`, lo que confirma que macOS utiliza Xcode como ruta activa de desarrollo para compilar proyectos iOS.

### 3.4 Configuracion para Android con Android Studio

Para ejecutar ReportaYA en Android se utilizo Android Studio, ya que permite instalar y administrar el Android SDK, las herramientas de compilacion y los emuladores.

Componentes necesarios:

- Android SDK.
- Android SDK Platform-Tools.
- Android SDK Build-Tools.
- Android Emulator.
- Android SDK Command-line Tools.

**Android SDK Manager**

<img src="./docs/images/android-sdk-manager-macos-compact.png" alt="Android SDK Manager en macOS" width="700">

La captura evidencia la ruta local del SDK Android y las herramientas instaladas desde Android Studio, necesarias para compilar y ejecutar el proyecto en Android.

**Seleccion del dispositivo virtual**

<img src="./docs/images/android-add-device-macos-compact.png" alt="Add Device en Android Studio" width="700">

La captura muestra la ventana Add Device durante la creacion de un dispositivo virtual Android. Desde esta seccion se selecciona el perfil de telefono que se utilizara para simular y probar la aplicacion.

**Emulador creado en Device Manager**

<img src="./docs/images/android-device-manager-macos-compact.png" alt="Android Device Manager en macOS" width="700">

La captura muestra el Device Manager luego de crear el emulador. Se observa el dispositivo virtual Pixel 6 disponible para ejecutar y probar el aplicativo.

### 3.5 Herramientas complementarias

Ademas de Flutter, Xcode y Android Studio, se verificaron herramientas necesarias para compilar correctamente en Android e iOS.

Comandos utilizados:

```bash
java -version
pod --version
```

**Version de Java**

<img src="./docs/images/java-version-macos-compact.png" alt="Java version en macOS" width="700">

La captura confirma el uso de OpenJDK `17.0.18`, instalado mediante Homebrew. Java es requerido por las herramientas de Android para compilar y ejecutar la aplicacion en emuladores o dispositivos Android.

**Version de CocoaPods**

<img src="./docs/images/pod-version-macos-compact.png" alt="CocoaPods version en macOS" width="700">

La captura confirma que CocoaPods esta instalado en la version `1.16.2`. CocoaPods se utiliza para gestionar dependencias nativas de iOS cuando el proyecto Flutter incorpora paquetes con integracion para el ecosistema Apple.

### 3.6 Verificacion general en macOS

Una vez configuradas las herramientas, se ejecuto el diagnostico general de Flutter:

```bash
flutter doctor -v
```

**Diagnostico del entorno con Flutter Doctor**

<img src="./docs/images/flutter-doctor-macos.png" alt="Flutter doctor en macOS" width="700">

La captura de `flutter doctor -v` muestra que Flutter reconoce correctamente las herramientas instaladas previamente: Android toolchain, Xcode, Chrome, dispositivos conectados y recursos de red. El diagnostico final indica `No issues found`, por lo que el entorno queda validado para ejecutar el proyecto en las plataformas disponibles.

### 3.7 Configuracion del entorno en Windows

En Windows, la configuracion se orienta principalmente al desarrollo y ejecucion del proyecto en Android. La preparacion sigue el mismo criterio general: instalar Flutter SDK, configurar `PATH`, instalar Android Studio, configurar Android SDK y validar con `flutter doctor`.

Pasos considerados:

1. Descargar y extraer Flutter SDK en una ruta local, por ejemplo:

```text
%USERPROFILE%\develop\flutter
```

2. Agregar el directorio `bin` de Flutter a la variable de entorno `Path`:

```text
%USERPROFILE%\develop\flutter\bin
```

3. Cerrar y abrir nuevamente la terminal para aplicar los cambios.

4. Validar que Flutter y Dart puedan ejecutarse desde terminal:

```bash
flutter --version
dart --version
```

5. Instalar Android Studio y completar el asistente inicial de configuracion.

6. Desde Android Studio, instalar o verificar:

- Android SDK.
- Android SDK Platform-Tools.
- Android SDK Build-Tools.
- Android Emulator.
- Android SDK Command-line Tools.

7. Crear un emulador Android desde Device Manager o conectar un dispositivo fisico con depuracion USB habilitada.

8. Verificar la configuracion general:

```bash
flutter doctor -v
flutter devices
```

Nota: el documento **Configurar el desarrollo de Windows** tambien menciona Visual Studio con la carga de trabajo **Desarrollo de escritorio con C++**. Esta configuracion es necesaria si se desea compilar aplicaciones Flutter para escritorio Windows. Para el alcance movil de ReportaYA, Android Studio y Android SDK son los componentes principales en Windows.

> Completar por el equipo con versiones y capturas del entorno Windows.

### 3.8 Ejecucion y validacion del proyecto

El proyecto Flutter **ReportaYA-Front** fue creado inicialmente con el comando:

```bash
flutter create ReportaYA-Front
```

Este comando genera la estructura base de Flutter, incluyendo archivos como `pubspec.yaml`, `lib/main.dart`, `android/`, `ios/`, `test/` y configuraciones iniciales para ejecutar el proyecto.

En macOS se recomienda trabajar el proyecto desde una ruta neutral como `~/Projects`, en lugar de mantenerlo dentro de `Desktop`. Durante la preparacion del entorno se identifico que trabajar desde Desktop puede generar metadatos o atributos extendidos de macOS que afectan la compilacion para macOS, por ejemplo errores de firma relacionados con:

```text
resource fork, Finder information, or similar detritus not allowed
```

Por ello, la ruta recomendada para clonar o mover el proyecto es:

```text
~/Projects/ReportaYA-Front
```

Comandos recomendados para ubicar el proyecto en esa ruta:

```bash
mkdir -p ~/Projects
cd ~/Projects
git clone https://github.com/jeffangeloss/ReportaYA-Front.git
cd ~/Projects/ReportaYA-Front
```

Si el proyecto ya existe en otra ubicacion, se puede mover a `~/Projects` y limpiar atributos extendidos:

```bash
mkdir -p ~/Projects
mv ~/Desktop/ReportaYA-Front ~/Projects/ReportaYA-Front
cd ~/Projects/ReportaYA-Front
xattr -cr .
```

Luego de ubicarse en la raiz del proyecto, donde se encuentra `pubspec.yaml`, ejecutar:

```bash
flutter pub get
flutter run
```

Para revisar el estado del codigo:

```bash
flutter analyze
flutter test
```

## 4. Tecnologias utilizadas

- Framework: Flutter.
- Lenguaje: Dart.
- Plataformas objetivo: Android e iOS.
- Gestion de dependencias: `pubspec.yaml`.

El archivo `pubspec.yaml` centraliza la configuracion principal del proyecto Flutter: nombre del proyecto, version, SDK de Dart, dependencias, dependencias de desarrollo y recursos declarados.

Dependencias configuradas actualmente:

```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.5
```

Luego de modificar este archivo, se debe ejecutar:

```bash
flutter pub get
```

Este comando descarga o actualiza las dependencias y regenera `pubspec.lock`, que registra las versiones resueltas para mantener consistencia entre los integrantes del equipo.

- Dependencias principales:
  - `flutter`: SDK principal para el desarrollo de la aplicacion.
  - `get: ^4.6.5`: paquete agregado para facilitar gestion de estado, rutas o inyeccion de dependencias en futuras iteraciones del proyecto.
- Dependencias de desarrollo:
  - `flutter_test`: pruebas automatizadas de widgets.
  - `flutter_lints: ^6.0.0`: reglas recomendadas de analisis estatico para mantener buenas practicas en Dart/Flutter.

## 5. Requisitos funcionales
> Completar por el equipo.

## 6. Requisitos no funcionales
> Completar por el equipo.

## 7. Diagrama de casos de uso
> Insertar imagen o enlace cuando este listo.

## 8. Descripcion de casos de uso
> Completar con tablas o formato acordado.

## 9. Mockups
> Insertar imagenes o enlaces.

## 10. Diagrama de despliegue
> Insertar imagen o enlace cuando este listo.

## 11. Instalacion y ejecucion del proyecto

Ejecutar los siguientes comandos desde la raiz del proyecto:

```bash
flutter pub get
flutter run
```

Para verificar el estado del codigo:

```bash
flutter analyze
flutter test
```

## 12. Estructura base del proyecto

```text
lib/
  main.dart
  app.dart
  core/
    constants/
    theme/
    utils/
  features/
    auth/
      presentation/
    home/
      presentation/
    reports/
      data/
      domain/
      presentation/
    map/
      presentation/
    profile/
      presentation/
  shared/
    widgets/
```

## 13. Pendientes
> Completar por el equipo con tareas futuras, acuerdos y observaciones.
