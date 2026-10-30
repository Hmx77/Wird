import 'dart:io';
import 'dart:convert';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(responseDataCallback: (data) async {
    final summary = Map<String, dynamic>.from(data ?? {});
    summary['screenshots'] = (summary['screenshots'] as List? ?? [])
        .map((shot) => shot['screenshotName']).toList();
    final baseline = (summary['homePolish'] as Map?)?['baseline'] == true;
    await File('verification/ios-device/home-polish-${baseline ? "before" : "after"}-results.json')
        .writeAsString(const JsonEncoder.withIndent('  ').convert(summary));
  }, onScreenshot: (name, bytes, [args]) async {
    final file = File('verification/ios-device/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes);
    return bytes.isNotEmpty;
  });
}
