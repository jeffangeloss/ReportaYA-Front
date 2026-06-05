import 'package:flutter/material.dart';
import 'app_colors.dart';

class GradientScaffold extends StatelessWidget {
  final Widget body;
  final List<Color>? colors;
  final bool useSafeArea;

  const GradientScaffold({
    super.key,
    required this.body,
    this.colors,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = colors ?? AppColors.ciudadanoGradient;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: useSafeArea ? SafeArea(child: body) : body,
      ),
    );
  }
}
