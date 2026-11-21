import 'package:flutter/material.dart';

import '../../modules/home/model/address_model.dart';
import '../colors/app_colors.dart';
import '../metrics/app_metrics.dart';

/// Linha de endereço reutilizada na Home e no Histórico.
class AddressTile extends StatelessWidget {
  final AddressModel address;
  final VoidCallback? onTap;

  const AddressTile({super.key, required this.address, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppMetrics.spaceSm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppMetrics.radius),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.place_outlined, color: AppColors.primary),
        title: Text(
          address.streetLine,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${address.cityLine}\nCEP ${address.formattedCep}'),
        isThreeLine: true,
      ),
    );
  }
}
