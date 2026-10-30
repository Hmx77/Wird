import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../test/support/home_polish_harness.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const baseline = bool.fromEnvironment('WIRD_BASELINE_RENDER');
  testWidgets('Native Home badges, safe areas, selection and persisted activity', (t) async {
    for (final mode in [0, 1]) {
      for (final scale in [1.0, 2.0]) {
        await verifyHomePolish(t, mode: mode, scale: scale, language: 'ar',
          baseline: baseline, prefix: 'ios-${baseline ? "before" : "after"}-$mode-text${scale.toInt()}',
          capture: (name) async { await binding.takeScreenshot(name); });
      }
    }
    binding.reportData ??= {};
    binding.reportData!['homePolish'] = {'baseline': baseline, 'themes': 2,
      'textScales': [1, 2], 'nativeSafeAreas': true, 'tabs': 4, 'categoryDestinations': 3};
  });
}
