import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Recebe os prints do teste de integração e salva em docs/screenshots.
Future<void> main() {
  return integrationDriver(
    onScreenshot: (String name, List<int> image, [Map<String, Object?>? args]) async {
      final file = File('docs/screenshots/$name.png');
      await file.create(recursive: true);
      await file.writeAsBytes(image);
      return true;
    },
  );
}
