import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'log_in_controller.dart';

class LogInPage extends StatelessWidget {
  LogInController control = Get.put(LogInController());

  LogInPage({super.key});

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
      padding: EdgeInsets.symmetric(vertical: 20),
      width: double.infinity,
      child:
      Column(
        children: [
          _logo(context, colors, textTheme),

          SizedBox(height: 24),

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
            flex: 30,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.primary,
                    colors.secondary,
                  ],
                  //begin: Alignment.topLeft,
                  //end: Alignment.bottomRight
                ),
              ),
        )
      );
  }

  Widget _buildBody(BuildContext context, colors, textTheme) {
    return SafeArea(child:
      Stack(children: [
        Column(children: [
          _background(context, colors),
          ],
          ),

        _centerText(context, colors, textTheme),
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
