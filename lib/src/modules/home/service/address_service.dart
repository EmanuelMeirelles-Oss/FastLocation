import 'package:geocoding/geocoding.dart';
import 'package:map_launcher/map_launcher.dart';

import '../model/address_model.dart';
import '../repositories/address_local_repository.dart';
import '../repositories/address_repository.dart';

/// Erro de regra de negócio, com mensagem pronta para o usuário.
class AddressException implements Exception {
  final String message;
  AddressException(this.message);

  @override
  String toString() => message;
}

/// Regras de negócio da consulta de endereços.
/// Combina a API externa (ViaCEP) com o armazenamento local (Hive).
class AddressService {
  final AddressRepository _remote;
  final AddressLocalRepository _local;

  AddressService({
    AddressRepository? remote,
    AddressLocalRepository? local,
  })  : _remote = remote ?? AddressRepository(),
        _local = local ?? AddressLocalRepository();

  /// Consulta de endereço por CEP.
  /// Consultas recorrentes saem do armazenamento local, sem ir à internet.
  Future<AddressModel?> searchByCep(String rawCep) async {
    final cep = rawCep.replaceAll(RegExp(r'\D'), '');
    if (cep.length != 8) {
      throw AddressException('Informe um CEP com 8 números.');
    }

    final cached = _local.getByCep(cep);
    if (cached != null) {
      final refreshed = cached.copyWith(consultedAt: DateTime.now());
      await _local.save(refreshed);
      return refreshed;
    }

    final address = await _remote.getByCep(cep);
    if (address != null) await _local.save(address);
    return address;
  }

  /// Busca de CEP por endereço completo ou parcial (UF + cidade + rua).
  Future<List<AddressModel>> searchByAddress({
    required String uf,
    required String city,
    required String street,
  }) async {
    final ufClean = uf.trim().toUpperCase();
    final cityClean = city.trim();
    final streetClean = street.trim();

    if (!RegExp(r'^[A-Z]{2}$').hasMatch(ufClean)) {
      throw AddressException('Informe a UF com 2 letras (ex.: SC).');
    }
    if (cityClean.length < 3 || streetClean.length < 3) {
      throw AddressException(
        'Cidade e logradouro precisam ter pelo menos 3 letras.',
      );
    }

    return _remote.getByAddress(
      uf: ufClean,
      city: cityClean,
      street: streetClean,
    );
  }

  /// Registra no histórico um endereço escolhido na busca por endereço.
  Future<AddressModel> select(AddressModel address) async {
    final selected = address.copyWith(consultedAt: DateTime.now());
    await _local.save(selected);
    return selected;
  }

  List<AddressModel> getHistory() => _local.getAll();

  AddressModel? getLastAddress() {
    final history = _local.getAll();
    return history.isEmpty ? null : history.first;
  }

  /// Abre o app de mapas com a rota da localização atual do aparelho
  /// até o endereço (sem origem informada, o app de mapas usa o GPS).
  Future<void> traceRoute(AddressModel address) async {
    final List<Location> locations;
    try {
      locations = await locationFromAddress(address.fullAddress);
    } catch (_) {
      throw AddressException(
        'Não foi possível localizar esse endereço no mapa.',
      );
    }
    if (locations.isEmpty) {
      throw AddressException(
        'Não foi possível localizar esse endereço no mapa.',
      );
    }

    final maps = await MapLauncher.installedMaps;
    if (maps.isEmpty) {
      throw AddressException('Nenhum aplicativo de mapas instalado.');
    }

    final map = maps.firstWhere(
      (m) => m.mapType == MapType.google,
      orElse: () => maps.first,
    );

    await map.showDirections(
      destination: Coords(locations.first.latitude, locations.first.longitude),
      destinationTitle: address.streetLine,
    );
  }
}
