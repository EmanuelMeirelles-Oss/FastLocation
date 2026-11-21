import 'package:flutter/material.dart';

import '../../../shared/colors/app_colors.dart';
import '../../../shared/metrics/app_metrics.dart';

/// Componente exibido quando não há consulta ou a busca não encontrou nada.
class EmptySearch extends StatelessWidget {
  final bool notFound;

  const EmptySearch({super.key, this.notFound = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppMetrics.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppMetrics.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            notFound ? Icons.search_off : Icons.map_outlined,
            size: AppMetrics.iconLg,
            color: notFound ? AppColors.error : AppColors.textSecondary,
          ),
          const SizedBox(height: AppMetrics.spaceMd),
          Text(
            notFound ? 'Endereço não encontrado' : 'Nenhuma consulta ainda',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppMetrics.spaceSm),
          Text(
            notFound
                ? 'Confira o CEP ou o endereço digitado e tente de novo.'
                : 'Toque em "Nova consulta" para buscar um endereço pelo CEP '
                    'ou um CEP pelo endereço.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
