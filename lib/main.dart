import 'package:flutter/material.dart';

import 'src/app_widget.dart';
import 'src/shared/storage/hive_config.dart';

/// Ponto de entrada refatorado: inicializa o binding do Flutter e o
/// armazenamento local (Hive) antes de subir o app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveConfig.start();
  runApp(const AppWidget());
}
