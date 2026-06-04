import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reportaya/configs/dimensions.dart';
import 'log_in_controller.dart';

class LogInPage extends StatefulWidget {
  LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  LogInController control = Get.put(LogInController());

  Widget _loginButton(BuildContext context, colors, textTheme){
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (){
          //go to Start page
          control.login(context);
        },
        child: Text('Iniciar Sesión')),
    );
  }

  Widget _recoverPassword(BuildContext context, colors, textTheme){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: (){
            //control.goToRecoverPassword(context);
          },
          child: Text('¿Olvidaste tu contraseña?',
            style: TextStyle(
              color: colors.onSurface,
            ),
          ),
        )
      ],
    );
  }

  Widget _form(BuildContext context, colors, textTheme){
    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppDimensions.paddingXL),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(36),
            topRight: Radius.circular(36),
          ),
        ),

        child: Form(
          key: control.loginFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text('Iniciar Sesión',
              style: textTheme.headlineMedium?.copyWith(
              color: colors.primary,
            ),
          ),

          SizedBox(height: 8),

          Text('Ingresa con tu cuenta para continuar',
              style: textTheme.bodyMedium,
          ),

          SizedBox(height: 32),
          
          //User
          TextFormField(
            controller: control.usernameController,
            validator: (value) => (value == null || value.trim().isEmpty) ? 'Ingresa tu usuario' : null,
            decoration: InputDecoration(
              labelText: "Usuario",
              labelStyle: TextStyle(
                color: colors.onSurface
              ),
            hintText: 'Tu usuario',
            border: OutlineInputBorder(),
          ),
          ),

          SizedBox(height: 20),

          //Password
          TextFormField(
            controller: control.passwordController,
            obscureText: control.isPasswordHidden,
            validator: (value) => (value == null || value.isEmpty) ? 'Ingresa tu contraseña' : null,
            decoration: InputDecoration(
              labelText: "Contraseña",
              labelStyle: TextStyle(
                color: colors.onSurface
              ),
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  control.isPasswordHidden ? Icons.visibility : Icons.visibility_off,
                ),

                onPressed: () {
                  setState(() {
                    control.togglePasswordVisibility();
                    });
                },
              ),
            ),
          ),

        SizedBox(height: 16),

        _recoverPassword(context, colors, textTheme),

        SizedBox(height: 28),

        _loginButton(context, colors, textTheme),

        SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('¿No tienes cuenta? ', style: TextStyle(color: colors.onSurface)),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text('Regístrate aquí', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),

        ],),
        ),
    );
  }

  Widget _logo(BuildContext context, colors, textTheme){
    // REEMPLAZAR POR ASSET DE LOGO, ESTO ESTA XD
    return Center(
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

  Widget _centerText(BuildContext context, colors, textTheme){
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

      SizedBox(height: 24),

      Text("ReportaYA",
          style: textTheme.headlineLarge?.copyWith(
            color: Colors.white,
          ),
        ),

      SizedBox(height: 8),

      Text("Tu ciudad, tus reportes",
          style: textTheme.bodyLarge?.copyWith(
            color: Colors.white70,
            ),
          ),

      ],
    );
  }

  Widget _background(BuildContext context, colors){
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
    return SafeArea(child:
      Stack(children: [
        _background(context, colors),

        Column(children: [
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(top: 60),
              child: _centerText(context, colors, textTheme)),
          ),

          Expanded(
            flex: 4,
            child: _form(context, colors, textTheme),
            ),
          
        ],),

        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: null,
        body: _buildBody(context, colors, textTheme),
      );
  }
}
