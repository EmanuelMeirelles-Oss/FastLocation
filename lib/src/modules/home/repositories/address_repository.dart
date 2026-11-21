import 'package:dio/dio.dart';

import '../../../http/http_client.dart';
import '../model/address_model.dart';

/// Erro de comunicação com a API externa (sem internet, timeout, 5xx).
class AddressApiException implements Exception {
  final String message;
  AddressApiException(this.message);

  @override
  String toString() => message;
}

/// Comunicação com a API pública ViaCEP.
class AddressRepository {
  final Dio _dio;

  AddressRepository({Dio? dio}) : _dio = dio ?? HttpClient.viaCep;

  /// GET /ws/{cep}/json/ — retorna null quando o CEP não existe.
  Future<AddressModel?> getByCep(String cep) async {
    try {
      final response = await _dio.get('/$cep/json/');
      final data = response.data;
      if (data is! Map || _isError(data)) return null;
      return AddressModel.fromJson(Map<String, dynamic>.from(data));
    } on DioError catch (e) {
      // ViaCEP responde 400 para CEP com formato inválido.
      if (e.response?.statusCode == 400) return null;
      throw AddressApiException(_messageFor(e));
    }
  }

  /// GET /ws/{UF}/{cidade}/{logradouro}/json/ — busca de CEP por endereço
  /// completo ou parcial. Retorna lista vazia quando nada é encontrado.
  Future<List<AddressModel>> getByAddress({
    required String uf,
    required String city,
    required String street,
  }) async {
    try {
      final path = '/${Uri.encodeComponent(uf)}'
          '/${Uri.encodeComponent(city)}'
          '/${Uri.encodeComponent(street)}/json/';
      final response = await _dio.get(path);
      final data = response.data;
      if (data is! List) return [];
      return data
          .whereType<Map>()
          .map((e) => AddressModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioError catch (e) {
      if (e.response?.statusCode == 400) return [];
      throw AddressApiException(_messageFor(e));
    }
  }

  bool _isError(Map data) {
    final erro = data['erro'];
    return erro == true || erro == 'true';
  }

  String _messageFor(DioError e) {
    switch (e.type) {
      case DioErrorType.connectTimeout:
      case DioErrorType.receiveTimeout:
      case DioErrorType.sendTimeout:
        return 'A consulta demorou demais. Verifique sua conexão e tente de novo.';
      case DioErrorType.other:
        return 'Sem conexão com a internet.';
      default:
        return 'Não foi possível consultar o endereço agora.';
    }
  }
}
