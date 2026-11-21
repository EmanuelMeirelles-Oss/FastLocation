import 'package:flutter/material.dart';

import '../../../shared/colors/app_colors.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../model/address_model.dart';

/// Destaque com o último endereço consultado.
class LastAddressCard extends StatelessWidget {
  final AddressModel address;

  const LastAddressCard({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppMetrics.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppMetrics.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Último endereço consultado',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: AppMetrics.spaceSm),
          Text(
            address.streetLine,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppMetrics.spaceXs),
          Text(
            address.cityLine,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
          const SizedBox(height: AppMetrics.spaceMd),
          Row(
            children: [
              _Info(label: 'CEP', value: address.formattedCep),
              const SizedBox(width: AppMetrics.spaceLg),
              if (address.ddd.isNotEmpty)
                _Info(label: 'DDD', value: address.ddd),
            ],
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final String label;
  final String value;

  const _Info({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
