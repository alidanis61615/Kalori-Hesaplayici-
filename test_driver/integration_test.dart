import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final output = Directory('docs/media')..createSync(recursive: true);
  await integrationDriver(
    onScreenshot:
        (String name, List<int> bytes, [Map<String, Object?>? args]) async {
          await File('${output.path}/$name.png').writeAsBytes(bytes);
          return bytes.isNotEmpty;
        },
  );
}
