import 'package:hive/hive.dart';

part 'address_model.g.dart';

/// Estrutura de dados do retorno da API ViaCEP (https://viacep.com.br/ws)
/// e do registro salvo no histórico local (Hive).
@HiveType(typeId: 0)
class AddressModel {
  @HiveField(0)
  final String cep;

  @HiveField(1)
  final String logradouro;

  @HiveField(2)
  final String complemento;

  @HiveField(3)
  final String bairro;

  @HiveField(4)
  final String localidade;

  @HiveField(5)
  final String uf;

  @HiveField(6)
  final String ddd;

  @HiveField(7)
  final DateTime consultedAt;

  AddressModel({
    required this.cep,
    required this.logradouro,
    required this.complemento,
    required this.bairro,
    required this.localidade,
    required this.uf,
    required this.ddd,
    required this.consultedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      cep: (json['cep'] ?? '').toString(),
      logradouro: (json['logradouro'] ?? '').toString(),
      complemento: (json['complemento'] ?? '').toString(),
      bairro: (json['bairro'] ?? '').toString(),
      localidade: (json['localidade'] ?? '').toString(),
      uf: (json['uf'] ?? '').toString(),
      ddd: (json['ddd'] ?? '').toString(),
      consultedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'cep': cep,
        'logradouro': logradouro,
        'complemento': complemento,
        'bairro': bairro,
        'localidade': localidade,
        'uf': uf,
        'ddd': ddd,
        'consultedAt': consultedAt.toIso8601String(),
      };

  AddressModel copyWith({DateTime? consultedAt}) {
    return AddressModel(
      cep: cep,
      logradouro: logradouro,
      complemento: complemento,
      bairro: bairro,
      localidade: localidade,
      uf: uf,
      ddd: ddd,
      consultedAt: consultedAt ?? this.consultedAt,
    );
  }

  /// CEP só com dígitos, usado como chave no armazenamento local.
  String get cepDigits => cep.replaceAll(RegExp(r'\D'), '');

  String get formattedCep {
    final d = cepDigits;
    return d.length == 8 ? '${d.substring(0, 5)}-${d.substring(5)}' : cep;
  }

  String get streetLine {
    if (logradouro.isEmpty) return 'CEP geral de $localidade';
    return complemento.isEmpty ? logradouro : '$logradouro, $complemento';
  }

  String get cityLine {
    final parts = [bairro, '$localidade - $uf'].where((s) => s.trim().isNotEmpty);
    return parts.join(' · ');
  }

  /// Endereço em texto corrido para geocodificação (rota).
  String get fullAddress {
    final parts = [logradouro, bairro, localidade, uf, 'Brasil']
        .where((s) => s.trim().isNotEmpty);
    return parts.join(', ');
  }
}
