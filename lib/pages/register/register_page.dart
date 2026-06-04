import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reportaya/configs/dimensions.dart';
import 'register_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final RegisterController control = Get.put(RegisterController());

  Widget _registerButton(BuildContext context, colors, textTheme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          control.register(context);
        },
        child: const Text('Crear cuenta'),
      ),
    );
  }

  Widget _form(BuildContext context, colors, textTheme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.paddingXL),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
      ),
      child: Form(
        key: control.registerFormKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registrarse',
                style: textTheme.headlineMedium?.copyWith(
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Crea una cuenta para reportar incidencias',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),

              // Nombres
              TextFormField(
                controller: control.nombresController,
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Ingresa tus nombres' : null,
                decoration: InputDecoration(
                  labelText: "Nombres",
                  labelStyle: TextStyle(color: colors.onSurface),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Apellidos
              TextFormField(
                controller: control.apellidosController,
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Ingresa tus apellidos' : null,
                decoration: InputDecoration(
                  labelText: "Apellidos",
                  labelStyle: TextStyle(color: colors.onSurface),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // DNI
              TextFormField(
                controller: control.dniController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Ingresa tu DNI';
                  if (value.trim().length != 8 || int.tryParse(value.trim()) == null) {
                    return 'El DNI debe tener 8 dígitos';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "DNI",
                  labelStyle: TextStyle(color: colors.onSurface),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Teléfono
              TextFormField(
                controller: control.telefonoController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Ingresa tu teléfono';
                  if (value.trim().length != 9 || int.tryParse(value.trim()) == null) {
                    return 'El teléfono debe tener 9 dígitos';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Teléfono",
                  labelStyle: TextStyle(color: colors.onSurface),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Correo
              TextFormField(
                controller: control.emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Ingresa tu correo';
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Correo Electrónico",
                  labelStyle: TextStyle(color: colors.onSurface),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Usuario
              TextFormField(
                controller: control.usernameController,
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Ingresa un usuario' : null,
                decoration: InputDecoration(
                  labelText: "Usuario",
                  labelStyle: TextStyle(color: colors.onSurface),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              GetBuilder<RegisterController>(
                builder: (_) => TextFormField(
                  controller: control.passwordController,
                  obscureText: control.isPasswordHidden,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
                    if (value.length < 6) return 'Debe tener al menos 6 caracteres';
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    labelStyle: TextStyle(color: colors.onSurface),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        control.isPasswordHidden ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        control.togglePasswordVisibility();
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              _registerButton(context, colors, textTheme),
              
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('¿Ya tienes cuenta? ', style: TextStyle(color: colors.onSurface)),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/log-in');
                    },
                    child: Text('Inicia sesión aquí', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logo(BuildContext context, colors, textTheme) {
    return const Center(
      child: Text(
        'RY',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _centerText(BuildContext context, colors, textTheme) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(22),
          ),
          child: _logo(context, colors, textTheme),
        ),
      ],
    );
  }

  Widget _background(BuildContext context, colors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.primary,
            colors.secondary,
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, colors, textTheme) {
    return SafeArea(
      child: Stack(
        children: [
          _background(context, colors),
          Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(top: 20),
                  child: _centerText(context, colors, textTheme),
                ),
              ),
              Expanded(
                flex: 5,
                child: _form(context, colors, textTheme),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: null,
      body: _buildBody(context, colors, textTheme),
    );
  }
}
