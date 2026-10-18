import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../content.dart';
import '../ui_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Reminders {
  static final instance = Reminders();
  final plugin = FlutterLocalNotificationsPlugin();
  bool ready = false;
  String? error;
  void Function(String)? onOpen;
  String? initialPayload;

  Future<void> initialize() async {
    if (!(Platform.isAndroid || Platform.isIOS)) return;
    try {
      tzdata.initializeTimeZones();
      await refreshTimezone();
      await plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('ic_notification'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (response) {
          if (response.payload != null) onOpen?.call(response.payload!);
        },
      );
      initialPayload = (await plugin.getNotificationAppLaunchDetails())
          ?.notificationResponse
          ?.payload;
      ready = true;
    } catch (e) {
      if (kDebugMode) debugPrint('Wird reminder initialization failed: $e');
      error = 'تعذر تجهيز التذكيرات على هذا الجهاز.';
    }
  }

  Future<void> refreshTimezone() async {
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone));
  }

  Future<bool> requestPermission() async {
    if (!ready) return false;
    if (Platform.isAndroid) {
      return await plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission() ??
          false;
    }
    return await plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, sound: true, badge: false) ??
        false;
  }

  Future<void> set(
    DhikrSection section,
    int hour,
    int minute,
    bool enabled,
  ) async {
    if (!ready) throw StateError(error ?? 'التذكيرات غير متاحة');
    final id = section.index + 10;
    if (!enabled) {
      await plugin.cancel(id);
      return;
    }
    await refreshTimezone();
    final language =
        (await SharedPreferences.getInstance()).getString('language') ?? 'ar';
    final now = tz.TZDateTime.now(tz.local);
    final next = nextReminderOccurrence(now, hour, minute);
    await plugin.zonedSchedule(
      id,
      'Wird — ${uiString(sectionLabel(section), language)}',
      language == 'en'
          ? 'A quiet moment for remembrance'
          : 'لحظة هادئة لذكر الله',
      next,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'wird_reminders',
          'تذكيرات ورد',
          channelDescription: 'تذكيرات اختيارية بالأذكار',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: section.name,
    );
  }
}

/// Calendar-based scheduling preserves the chosen local clock time across DST.
tz.TZDateTime nextReminderOccurrence(tz.TZDateTime now, int hour, int minute) {
  RangeError.checkValueInInterval(hour, 0, 23, 'hour');
  RangeError.checkValueInInterval(minute, 0, 59, 'minute');
  final candidate = tz.TZDateTime(
    now.location,
    now.year,
    now.month,
    now.day,
    hour,
    minute,
  );
  return candidate.isAfter(now)
      ? candidate
      : tz.TZDateTime(
          now.location,
          now.year,
          now.month,
          now.day + 1,
          hour,
          minute,
        );
}
