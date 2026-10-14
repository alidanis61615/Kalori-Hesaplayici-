import 'dart:io';

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
              '--bit-rate',
              '3000000',
              '/sdcard/portfolio-demo.mp4',
            ]);
            recording!.stdout.drain<void>();
            recording!.stderr.drain<void>();
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
