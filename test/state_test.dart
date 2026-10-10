import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wird/main.dart';
import 'package:wird/content.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'default theme, counter bounds, persistence and midnight isolation',
    () async {
      var date = DateTime(2026, 10, 9, 23, 59);
      final state = WirdState(now: () => date);
      await state.initialize();
      state.preferences(feedback: false);
      expect(state.palette.name, 'Stone & Teal');
      final entry = entries.first;
      state.setCount(entry, 9999);
      expect(state.count(entry), entry.count);
      state.toggleFavorite(entry.id);
      state.changeTheme(5);
      await state.pendingWrites;
      final reopened = WirdState(now: () => date);
      await reopened.initialize();
      expect(reopened.count(entry), entry.count);
      expect(reopened.favorites, contains(entry.id));
      expect(reopened.themeIndex, 5);
      date = DateTime(2026, 10, 10);
      expect(state.count(entry), 0);
      expect(state.count(entry, '2026-10-09'), entry.count);
      state.setCount(entry, -3);
      expect(state.count(entry), 0);
      await state.pendingWrites;
      state.dispose();
      reopened.dispose();
    },
  );
  test('corrupt count JSON recovers without losing favorites', () async {
    SharedPreferences.setMockInitialValues({
      'counts': '{broken',
      'favorites': ['morning_sayyid'],
    });
    final state = WirdState();
    await state.initialize();
    expect(state.counts, isEmpty);
    expect(state.favorites, contains('morning_sayyid'));
    state.dispose();
  });
  test('deletion clears progress but retains appearance', () async {
    final state = WirdState();
    await state.initialize();
    state.preferences(feedback: false);
    state.changeTheme(3);
    state.setCount(entries.first, 1);
    state.togglePrayer('fajr_before');
    state.toggleFavorite(entries.first.id);
    await state.erase();
    expect(state.counts, isEmpty);
    expect(state.prayers, isEmpty);
    expect(state.favorites, isEmpty);
    final reopened = WirdState();
    await reopened.initialize();
    expect(reopened.counts, isEmpty);
    expect(reopened.themeIndex, 3);
    state.dispose();
    reopened.dispose();
  });
}
