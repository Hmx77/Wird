import 'dart:io';
import 'package:home_widget/home_widget.dart';

class WirdWidgets {
  static const group = 'group.ae.wird.app';
  static Future<void> _pending = Future.value();
  static Future<void> update(
    String day,
    int completed,
    int total,
    String languageCode,
  ) {
    _pending = _pending
        .catchError((Object _) {})
        .then((_) => _update(day, completed, total, languageCode));
    return _pending;
  }

  static Future<void> _update(
    String day,
    int completed,
    int total,
    String languageCode,
  ) async {
    if (!(Platform.isAndroid || Platform.isIOS)) return;
    if (Platform.isIOS) await HomeWidget.setAppGroupId(group);
    await HomeWidget.saveWidgetData<String>('language', languageCode);
    await HomeWidget.saveWidgetData<String>('day', day);
    await HomeWidget.saveWidgetData<int>('completed', completed);
    await HomeWidget.saveWidgetData<int>('total', total);
    await HomeWidget.updateWidget(
      androidName: 'WirdWidgetProvider',
      iOSName: 'WirdWidget',
    );
  }
}
