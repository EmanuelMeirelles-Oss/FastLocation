import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/colors/app_colors.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/metrics/app_metrics.dart';

/// Pedido de consulta devolvido pelo formulário.
abstract class SearchRequest {}

class CepSearchRequest extends SearchRequest {
  final String cep;
  CepSearchRequest(this.cep);
}

class AddressSearchRequest extends SearchRequest {
  final String uf;
  final String city;
  final String street;
  AddressSearchRequest(this.uf, this.city, this.street);
}

/// Componente com os campos de consulta: por CEP ou por endereço.
/// Abre como bottom sheet e devolve um [SearchRequest].
class SearchForm extends StatefulWidget {
  const SearchForm({super.key});

  static Future<SearchRequest?> show(BuildContext context) {
    return showModalBottomSheet<SearchRequest>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppMetrics.radius * 2),
        ),
      ),
      builder: (_) => const SearchForm(),
    );
  }

  @override
  State<SearchForm> createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  final _cepController = TextEditingController();
  final _ufController = TextEditingController();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  bool _byCep = true;

  @override
  void dispose() {
    _cepController.dispose();
    _ufController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  void _submit() {
    final request = _byCep
        ? CepSearchRequest(_cepController.text)
        : AddressSearchRequest(
            _ufController.text,
            _cityController.text,
            _streetController.text,
          );
    Navigator.of(context).pop(request);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppMetrics.spaceLg,
        AppMetrics.spaceLg,
        AppMetrics.spaceLg,
        AppMetrics.spaceLg + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Nova consulta',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppMetrics.spaceMd),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: true,
                label: Text('Por CEP'),
                icon: Icon(Icons.pin_drop_outlined),
              ),
              ButtonSegment(
                value: false,
                label: Text('Por endereço'),
                icon: Icon(Icons.signpost_outlined),
              ),
            ],
            selected: {_byCep},
            onSelectionChanged: (s) => setState(() => _byCep = s.first),
          ),
          const SizedBox(height: AppMetrics.spaceMd),
          if (_byCep)
            TextField(
              controller: _cepController,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
              ],
              decoration: _decoration('CEP', 'Ex.: 88015200'),
              onSubmitted: (_) => _submit(),
            )
          else ...[
            TextField(
              controller: _ufController,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [LengthLimitingTextInputFormatter(2)],
              decoration: _decoration('UF', 'Ex.: SC'),
            ),
            const SizedBox(height: AppMetrics.spaceSm),
            TextField(
              controller: _cityController,
              textCapitalization: TextCapitalization.words,
              decoration: _decoration('Cidade', 'Ex.: Florianópolis'),
            ),
            const SizedBox(height: AppMetrics.spaceSm),
            TextField(
              controller: _streetController,
              textCapitalization: TextCapitalization.words,
              decoration: _decoration(
                'Logradouro (completo ou parcial)',
                'Ex.: Felipe Schmidt',
              ),
              onSubmitted: (_) => _submit(),
            ),
          ],
          const SizedBox(height: AppMetrics.spaceLg),
          AppButton(label: 'Consultar', icon: Icons.search, onPressed: _submit),
        ],
      ),
    );
  }

  InputDecoration _decoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppMetrics.radius),
      ),
    );
  }
}
