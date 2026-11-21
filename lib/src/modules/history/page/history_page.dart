import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../shared/colors/app_colors.dart';
import '../../../shared/components/address_tile.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../controller/history_controller.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryController controller = HistoryController();

  @override
  void initState() {
    super.initState();
    // Carregamento automático do histórico ao abrir a página.
    controller.loadHistory();
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpar histórico?'),
        content: const Text('Todas as consultas salvas no aparelho serão apagadas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.clearHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
        actions: [
          Observer(
            builder: (_) => IconButton(
              tooltip: 'Limpar histórico',
              icon: const Icon(Icons.delete_outline),
              onPressed: controller.isEmpty ? null : _confirmClear,
            ),
          ),
        ],
      ),
      body: Observer(
        builder: (_) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }
          if (controller.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppMetrics.spaceLg),
                child: Text(
                  'Nenhum endereço consultado ainda.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppMetrics.spaceMd),
            itemCount: controller.history.length,
            itemBuilder: (_, i) => AddressTile(address: controller.history[i]),
          );
        },
      ),
    );
  }
}
