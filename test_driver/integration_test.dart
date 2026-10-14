import 'dart:io';
import 'dart:convert';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  Process? recording;
  final output = Directory('docs/media')..createSync(recursive: true);
  await integrationDriver(
    onScreenshot:
        (String name, List<int> bytes, [Map<String, Object?>? args]) async {
          File('${output.path}/$name.png').writeAsBytesSync(bytes);
          if (recording == null) {
            recording = await Process.start('adb', [
              'shell',
              'screenrecord',
              '--time-limit',
              '120',
              '--size',
              '540x1200',
              '--bit-rate',
              '3000000',
              '/sdcard/portfolio-demo.mp4',
            ]);
            recording!.stdout.transform(utf8.decoder).listen(stdout.write);
            recording!.stderr.transform(utf8.decoder).listen(stderr.write);
          }
          if (name.endsWith('profil') || name.endsWith('dark')) {
            await Process.run('adb', [
              'shell',
              'killall',
              '-INT',
              'screenrecord',
            ]);
            await recording!.exitCode;
          }
          return bytes.isNotEmpty;
        },
  );
}
