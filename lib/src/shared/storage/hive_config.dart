import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../modules/home/model/address_model.dart';
import 'storage_keys.dart';

/// Configuração do armazenamento local (Hive).
abstract class HiveConfig {
  static Future<void> start() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(p.join(dir.path, StorageKeys.folder));

    if (!Hive.isAdapterRegistered(AddressModelAdapter().typeId)) {
      Hive.registerAdapter(AddressModelAdapter());
    }

    await Hive.openBox<AddressModel>(StorageKeys.addressHistoryBox);
  }
}
