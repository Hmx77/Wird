import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:wird/services/reminders.dart';

void main() {
  setUpAll(tzdata.initializeTimeZones);
  test('future time today, equal time tomorrow, and date rollover', () {
    final dubai = tz.getLocation('Asia/Dubai');
    final before = tz.TZDateTime(dubai, 2026, 12, 31, 6, 59);
    expect(
      nextReminderOccurrence(before, 7, 0),
      tz.TZDateTime(dubai, 2026, 12, 31, 7),
    );
    final equal = tz.TZDateTime(dubai, 2026, 12, 31, 7);
    expect(
      nextReminderOccurrence(equal, 7, 0),
      tz.TZDateTime(dubai, 2027, 1, 1, 7),
    );
    expect(() => nextReminderOccurrence(before, 24, 0), throwsRangeError);
  });
  test(
    'calendar scheduling retains local clock time over a DST transition',
    () {
      final ny = tz.getLocation('America/New_York');
      final before = tz.TZDateTime(ny, 2026, 3, 7, 22);
      final next = nextReminderOccurrence(before, 7, 0);
      expect(next.day, 8);
      expect(next.hour, 7);
      expect(next.difference(before), const Duration(hours: 8));
    },
  );
}
