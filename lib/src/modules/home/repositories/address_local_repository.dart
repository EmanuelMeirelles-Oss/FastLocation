import 'package:hive/hive.dart';

import '../../../shared/storage/storage_keys.dart';
import '../model/address_model.dart';

/// Comunicação com o armazenamento local (Hive): histórico de consultas.
class AddressLocalRepository {
  Box<AddressModel> get _box =>
      Hive.box<AddressModel>(StorageKeys.addressHistoryBox);

  /// Salva usando o CEP como chave: consultar o mesmo CEP de novo
  /// atualiza o registro em vez de duplicar.
  Future<void> save(AddressModel address) async {
    await _box.put(address.cepDigits, address);
  }

  AddressModel? getByCep(String cep) => _box.get(cep);

  /// Histórico ordenado da consulta mais recente para a mais antiga.
  List<AddressModel> getAll() {
    final list = _box.values.toList();
    list.sort((a, b) => b.consultedAt.compareTo(a.consultedAt));
    return list;
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
