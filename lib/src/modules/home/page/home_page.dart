import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';

import '../../../routes/app_routes.dart';
import '../../../shared/colors/app_colors.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/app_loading.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../components/address_list.dart';
import '../components/empty_search.dart';
import '../components/last_address_card.dart';
import '../components/search_form.dart';
import '../controller/home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController controller = HomeController();
  late final ReactionDisposer _errorReaction;

  @override
  void initState() {
    super.initState();
    controller.load();

    // Reação do MobX: toda vez que surgir um erro na consulta, mostra o aviso.
    _errorReaction = reaction<String?>(
      (_) => controller.errorMessage,
      (message) {
        if (message == null || !mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        controller.clearError();
      },
    );
  }

  @override
  void dispose() {
    _errorReaction();
    super.dispose();
  }

  Future<void> _newSearch() async {
    final request = await SearchForm.show(context);
    if (request is CepSearchRequest) {
      await controller.searchByCep(request.cep);
    } else if (request is AddressSearchRequest) {
      await controller.searchByAddress(
        uf: request.uf,
        city: request.city,
        street: request.street,
      );
    }
  }

  Future<void> _openHistory() async {
    await Navigator.of(context).pushNamed(AppRoutes.history);
    controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FastLocation'),
        actions: [
          IconButton(
            tooltip: 'Histórico de consultas',
            icon: const Icon(Icons.history),
            onPressed: _openHistory,
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(AppMetrics.spaceMd),
            children: [
              Observer(
                builder: (_) {
                  if (controller.notFound) {
                    return const EmptySearch(notFound: true);
                  }
                  final last = controller.lastAddress;
                  if (last == null) return const EmptySearch();
                  return LastAddressCard(address: last);
                },
              ),
              const SizedBox(height: AppMetrics.spaceMd),
              AppButton(
                label: 'Nova consulta',
                icon: Icons.search,
                onPressed: _newSearch,
              ),
              const SizedBox(height: AppMetrics.spaceSm),
              Observer(
                builder: (_) => AppButton(
                  label: 'Traçar rota',
                  icon: Icons.directions,
                  outlined: true,
                  onPressed:
                      controller.hasLastAddress ? controller.traceRoute : null,
                ),
              ),
              const SizedBox(height: AppMetrics.spaceLg),
              Observer(
                builder: (_) {
                  if (controller.hasSearchResults) {
                    return AddressList(
                      title: 'Resultados — toque para selecionar',
                      addresses: controller.searchResults.toList(),
                      onSelect: controller.selectResult,
                    );
                  }
                  if (controller.recent.isEmpty) return const SizedBox();
                  return AddressList(
                    title: 'Consultas recentes',
                    addresses: controller.recent.toList(),
                  );
                },
              ),
            ],
          ),
          Observer(
            builder: (_) => controller.isLoading
                ? const AppLoading()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
