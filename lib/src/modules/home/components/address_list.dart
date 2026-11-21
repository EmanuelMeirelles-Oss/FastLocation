import 'package:flutter/material.dart';

import '../../../shared/colors/app_colors.dart';
import '../../../shared/components/address_tile.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../model/address_model.dart';

/// Lista de endereços consultados (ou resultados da busca por endereço).
class AddressList extends StatelessWidget {
  final String title;
  final List<AddressModel> addresses;
  final ValueChanged<AddressModel>? onSelect;

  const AddressList({
    super.key,
    required this.title,
    required this.addresses,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppMetrics.spaceSm),
        for (final address in addresses)
          AddressTile(
            address: address,
            onTap: onSelect == null ? null : () => onSelect!(address),
          ),
      ],
    );
  }
}
