import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../metrics/app_metrics.dart';

/// Tela de loading exibida por cima do conteúdo durante a consulta externa.
class AppLoading extends StatelessWidget {
  final String message;

  const AppLoading({super.key, this.message = 'Consultando endereço...'});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0x59000000), // preto a 35%
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.all(AppMetrics.spaceLg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppMetrics.radius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.accent),
            const SizedBox(height: AppMetrics.spaceMd),
            Text(
              message,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
