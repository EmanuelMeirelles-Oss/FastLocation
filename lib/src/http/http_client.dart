import 'package:dio/dio.dart';

/// Configuração do Dio para comunicação HTTP com sistemas externos.
class HttpClient {
  HttpClient._();

  static const String viaCepBaseUrl = 'https://viacep.com.br/ws';

  static final Dio viaCep = Dio(
    BaseOptions(
      baseUrl: viaCepBaseUrl,
      connectTimeout: 10000, // ms (dio 4.x)
      receiveTimeout: 10000,
      responseType: ResponseType.json,
      headers: {'Accept': 'application/json'},
    ),
  );
}
