import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wird/content.dart';
import 'package:wird/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({'haptics': false}));

  test(
    'all prescribed targets bound, undo, reset and persist independently',
    () async {
      final state = WirdState();
      await state.initialize();
      for (final e in entries) {
        state.setCount(e, state.target(e) + 1);
        expect(state.count(e), state.target(e));
        expect(state.isDone(e), true);
        state.setCount(e, state.count(e) - 1);
        expect(state.isDone(e), false);
        state.setCount(e, -1);
        expect(state.count(e), 0);
        state.setCount(e, state.target(e));
      }
      await state.pendingWrites;
      final restored = WirdState();
      await restored.initialize();
      expect(entries.every(restored.isDone), true);
      await restored.pendingWrites;
      state.dispose();
      restored.dispose();
    },
  );

  test(
    'alternative choices persist; changes reset today, preserve yesterday',
    () async {
      var date = DateTime(2026, 10, 14, 23, 59);
      final state = WirdState(now: () => date);
      await state.initialize();
      final morning = entries.singleWhere((e) => e.id == 'morning_tahlil');
      final evening = entries.singleWhere((e) => e.id == 'evening_tahlil');
      expect(state.target(morning), 100);
      state.setCount(morning, 100);
      date = DateTime(2026, 10, 15);
      expect(state.count(morning), 0);
      state.chooseCount(morning, 10);
      expect(state.target(morning), 10);
      expect(state.target(evening), 100);
      expect(state.target(morning, '2026-10-14'), 100);
      expect(state.count(morning, '2026-10-14'), 100);
      state.setCount(morning, 99);
      expect(state.count(morning), 10);
      state.chooseCount(morning, 7);
      expect(state.target(morning), 10);
      state.chooseCount(morning, 1);
      expect(state.count(morning), 0);
      state.setCount(morning, 1);
      await state.pendingWrites;
      final restored = WirdState(now: () => date);
      await restored.initialize();
      expect(restored.target(morning), 1);
      expect(restored.count(morning), 1);
      expect(restored.target(morning, '2026-10-14'), 100);
      expect(restored.isDone(morning, '2026-10-14'), true);
      expect(restored.target(evening), 100);
      await restored.erase();
      expect(restored.countChoices, isEmpty);
      expect(restored.countTargets, isEmpty);
      state.dispose();
      restored.dispose();
    },
  );

  test(
    'invalid or malformed saved targets recover to admitted defaults',
    () async {
      SharedPreferences.setMockInitialValues({
        'haptics': false,
        'count_choices': '{"morning_tahlil":7}',
        'count_targets': 'broken',
      });
      final state = WirdState();
      await state.initialize();
      final e = entries.singleWhere((e) => e.id == 'morning_tahlil');
      expect(state.target(e), 100);
      expect(state.countTargets, isEmpty);
      state.dispose();
    },
  );
}
