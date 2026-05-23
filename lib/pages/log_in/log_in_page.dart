import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'log_in_controller.dart';

class LogInPage extends StatefulWidget {
  LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  LogInController control = Get.put(LogInController());


  Widget _form(BuildContext context, colors, textTheme){
    return Expanded(
      flex: 5,
      child:
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(36),
            topRight: Radius.circular(36),
          ),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Iniciar Sesión',
              style: textTheme.headlineSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 22.0,
            ),
          ),

          Text('Ingresa con tu cuenta para continuar',
              style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 16.0,
            ),
          ),

        SizedBox(height: 20),

        //User
        TextField(
          controller: control.usernameController,
          decoration: InputDecoration(
            labelText: "Usuario",
            labelStyle: TextStyle(
              color: colors.onSurface
            ),
            hintText: 'Tu usuario',
            border: OutlineInputBorder(),
          ),
        ),

        SizedBox(height: 10),

        //Password
        TextField(
          controller: control.passwordController,
          obscureText: control.isPasswordHidden,
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
            )
          ),
        ),

        ],),
      ),
    );
  }

  Widget _logo(BuildContext context, colors, textTheme){
    // REEMPLAZAR POR ASSET DE LOGO, ESTO ESTA XD
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
        color: Colors.white24,
        ),
        ),
      
      child: const Center(
        child: Text(
          'RY',
          style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _centerText(BuildContext context, colors, textTheme){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 60),
      width: double.infinity,
      child:
      Column(
        children: [
          _logo(context, colors, textTheme),

          SizedBox(height: 14),

          Text("ReportaYA",
          style: textTheme.headlineLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 48.0,
            ),
          ),

          Text("Tu ciudad, tus reportes",
          style: textTheme.headlineLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16.0,
            ),
          ),
        ],
      )
    );
  }

  Widget _background(BuildContext context, colors){
    return Expanded(
            //flex: 30,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
              ),
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
        )
      );
  }

  Widget _buildBody(BuildContext context, colors, textTheme) {
    return SafeArea(child:
      Stack(children: [
        _background(context, colors),

        Column(children: [
          _centerText(context, colors, textTheme),
          _form(context, colors, textTheme),
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
      //backgroundColor: colors.primary,
        resizeToAvoidBottomInset: false,
        appBar: null,
        body: _buildBody(context, colors, textTheme),
      );
  }
}
