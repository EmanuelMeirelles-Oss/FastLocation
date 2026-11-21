import 'package:fast_location/src/modules/home/model/address_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddressModel', () {
    final json = {
      'cep': '88015-200',
      'logradouro': 'Rua Felipe Schmidt',
      'complemento': '',
      'bairro': 'Centro',
      'localidade': 'Florianópolis',
      'uf': 'SC',
      'ddd': '48',
    };

    test('converte o JSON do ViaCEP', () {
      final address = AddressModel.fromJson(json);
      expect(address.cepDigits, '88015200');
      expect(address.formattedCep, '88015-200');
      expect(address.streetLine, 'Rua Felipe Schmidt');
      expect(address.cityLine, 'Centro · Florianópolis - SC');
    });

    test('monta o endereço completo para a rota', () {
      final address = AddressModel.fromJson(json);
      expect(
        address.fullAddress,
        'Rua Felipe Schmidt, Centro, Florianópolis, SC, Brasil',
      );
    });

    test('CEP geral de cidade, sem logradouro', () {
      final address = AddressModel.fromJson({
        ...json,
        'logradouro': '',
        'bairro': '',
      });
      expect(address.streetLine, 'CEP geral de Florianópolis');
    });
  });
}
