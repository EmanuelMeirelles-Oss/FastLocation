import 'package:mobx/mobx.dart';

import '../model/address_model.dart';
import '../repositories/address_repository.dart';
import '../service/address_service.dart';

part 'home_controller.g.dart';

class HomeController = _HomeControllerBase with _$HomeController;

/// Estado da Home, controlado com MobX e alimentado pelo AddressService.
abstract class _HomeControllerBase with Store {
  final AddressService _service;

  _HomeControllerBase({AddressService? service})
      : _service = service ?? AddressService();

  @observable
  bool isLoading = false;

  @observable
  AddressModel? lastAddress;

  /// Últimas consultas (lista da Home).
  @observable
  ObservableList<AddressModel> recent = ObservableList<AddressModel>();

  /// Resultados da busca de CEP por endereço.
  @observable
  ObservableList<AddressModel> searchResults = ObservableList<AddressModel>();

  /// true quando a última busca não encontrou nada.
  @observable
  bool notFound = false;

  /// Mensagem de erro observada pela página com uma reaction.
  @observable
  String? errorMessage;

  @computed
  bool get hasLastAddress => lastAddress != null;

  @computed
  bool get hasSearchResults => searchResults.isNotEmpty;

  @action
  void load() {
    lastAddress = _service.getLastAddress();
    recent = ObservableList.of(_service.getHistory().take(5));
  }

  @action
  Future<void> searchByCep(String cep) async {
    _startRequest();
    try {
      final address = await _service.searchByCep(cep);
      if (address == null) {
        notFound = true;
      } else {
        load();
      }
    } on AddressException catch (e) {
      errorMessage = e.message;
    } on AddressApiException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Erro inesperado na consulta.';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> searchByAddress({
    required String uf,
    required String city,
    required String street,
  }) async {
    _startRequest();
    try {
      final results = await _service.searchByAddress(
        uf: uf,
        city: city,
        street: street,
      );
      if (results.isEmpty) {
        notFound = true;
      } else {
        searchResults = ObservableList.of(results);
      }
    } on AddressException catch (e) {
      errorMessage = e.message;
    } on AddressApiException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Erro inesperado na consulta.';
    } finally {
      isLoading = false;
    }
  }

  /// Escolhe um endereço da lista de resultados da busca por endereço.
  @action
  Future<void> selectResult(AddressModel address) async {
    await _service.select(address);
    searchResults.clear();
    load();
  }

  @action
  void clearSearch() {
    searchResults.clear();
    notFound = false;
  }

  @action
  Future<void> traceRoute() async {
    final address = lastAddress;
    if (address == null) return;
    errorMessage = null;
    try {
      await _service.traceRoute(address);
    } on AddressException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Não foi possível abrir a rota.';
    }
  }

  @action
  void clearError() => errorMessage = null;

  void _startRequest() {
    isLoading = true;
    notFound = false;
    errorMessage = null;
    searchResults.clear();
  }
}
