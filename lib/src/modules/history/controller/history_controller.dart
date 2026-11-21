import 'package:mobx/mobx.dart';

import '../../home/model/address_model.dart';
import '../../home/repositories/address_local_repository.dart';

part 'history_controller.g.dart';

class HistoryController = _HistoryControllerBase with _$HistoryController;

/// Carrega o histórico de consultas a partir do armazenamento local.
abstract class _HistoryControllerBase with Store {
  final AddressLocalRepository _local;

  _HistoryControllerBase({AddressLocalRepository? local})
      : _local = local ?? AddressLocalRepository();

  @observable
  ObservableList<AddressModel> history = ObservableList<AddressModel>();

  @observable
  bool isLoading = false;

  @computed
  bool get isEmpty => history.isEmpty;

  @action
  Future<void> loadHistory() async {
    isLoading = true;
    history = ObservableList.of(_local.getAll());
    isLoading = false;
  }

  @action
  Future<void> clearHistory() async {
    await _local.clear();
    history.clear();
  }
}
