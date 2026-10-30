import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' show SemanticsFlag, SemanticsAction;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wird/main.dart';
import 'package:wird/content.dart';
import 'package:wird/ui_strings.dart';

/// Runs production shell/reader widgets, also reused by the native iOS test.
Future<void> verifyHomePolish(WidgetTester t, {required int mode,
    required double scale, required String language, required String prefix,
    required Future<void> Function(String) capture, bool baseline = false}) async {
  final semantics = t.ensureSemantics();
  final store = WirdState();
  await store.initialize();
  final prefs = await SharedPreferences.getInstance();
  Map<String, Object?> activity() => {for (final k in prefs.getKeys()
    .where((k) => ![appearancePreference, 'theme', 'language'].contains(k))) k: prefs.get(k)};
  final before = activity();
  store.changeTheme(mode); store.changeLanguage(language); await store.pendingWrites;
  await t.pumpWidget(AnimatedBuilder(animation: store, builder: (context, _) => MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: Locale(language), supportedLocales: const [Locale('ar'), Locale('en')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: wirdTheme(store.palette),
    builder: (context, child) => RepaintBoundary(key: const Key('polish-capture'),
      child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)), child: child!)),
    home: WirdShell(store: store),
  )));
  await t.pumpAndSettle();
  await t.runAsync(() async {
    final context = t.element(find.byType(WirdShell));
    await Future.wait([wirdWordmark, ...homeArt.values, ivoryHomeHeader,
      ivoryHomeFeature, ivoryMorning, ivoryEvening].map((image) => precacheImage(image, context)));
  });
  await t.pumpAndSettle();

  const navKeys = ['nav-home', 'nav-library', 'nav-nawafil', 'nav-settings'];
  const navLabels = ['الرئيسية', 'الأذكار', 'النوافل', 'الإعدادات'];
  void navigation(int selected) {
    for (var i = 0; i < 4; i++) {
      final target = find.byKey(Key(navKeys[i]));
      expect(target.hitTestable(), findsOneWidget);
      if (baseline) continue;
      final rect = t.getRect(target);
      expect(rect.width, greaterThanOrEqualTo(48));
      expect(rect.height, greaterThanOrEqualTo(48));
      final node = t.getSemantics(find.byKey(ValueKey('navigation-item-$i'))).getSemanticsData();
      expect(node.hasFlag(SemanticsFlag.isSelected), i == selected);
      expect(node.hasFlag(SemanticsFlag.isButton), isTrue);
      expect(node.hasAction(SemanticsAction.tap), isTrue);
      expect(node.label, uiString(navLabels[i], language));
      final highlight = find.byKey(ValueKey('navigation-highlight-$i'));
      final material = t.widget<Material>(highlight);
      expect(material.color == Colors.transparent, i != selected);
      final label = find.descendant(of: target, matching: find.byType(Text));
      final surface = t.getRect(highlight);
      expect(surface.contains(t.getCenter(label)), isTrue);
      expect(t.widget<Text>(label).style!.fontSize, 12.5);
      expect(t.widget<IconTheme>(find.descendant(of: target, matching: find.byType(IconTheme)).first).data.size, 28);
    }
    if (!baseline) {
      final surface = t.getRect(find.byKey(const Key('bottom-navigation-surface')));
      final media = MediaQuery.of(t.element(find.byType(WirdShell)));
      expect(media.size.height - surface.bottom,
        closeTo(math.max(media.padding.bottom, 5), .1), reason: 'Gesture inset is outside the border, once');
      final rects = navKeys.map((k) => t.getRect(find.byKey(Key(k)))).toList();
      expect(rects.map((r) => r.width).reduce(math.max) - rects.map((r) => r.width).reduce(math.min), lessThan(.1));
      expect(rects[0].center.dx > rects[1].center.dx, language == 'ar');
      if (scale == 1) {
        expect(surface.height, lessThanOrEqualTo(76));
        for (final r in rects) expect(r.top, closeTo(rects.first.top, .1));
      } else {
        expect(rects[2].top, greaterThan(rects[0].bottom));
      }
    }
    expect(t.takeException(), isNull);
  }

  navigation(0);
  await capture('$prefix-home');
  for (final section in DhikrSection.values) {
    final card = find.byKey(Key('home-${section.name}'));
    await t.ensureVisible(card); await t.pumpAndSettle();
    final badges = find.descendant(of: card, matching: find.byWidgetPredicate((w) =>
      w is Icon && [Icons.wb_sunny_outlined, Icons.nightlight_outlined,
        Icons.nightlight_round, Icons.bedtime_outlined].contains(w.icon)));
    expect(badges, baseline ? findsOneWidget : findsNothing);
    final arrows = find.descendant(of: card, matching: find.byWidgetPredicate((w) =>
      w is Icon && [Icons.chevron_left_rounded, Icons.chevron_right_rounded, Icons.check_rounded].contains(w.icon)));
    expect(arrows, findsOneWidget);
    expect(find.descendant(of: card, matching: find.text(uiString('${inSection(section).length} ذكر', language))), findsOneWidget);
    if (scale > 1 || section == DhikrSection.sleep) await capture('$prefix-card-${section.name}');
    await t.tap(card); await t.pumpAndSettle();
    final reader = t.widget<ReaderPage>(find.byType(ReaderPage));
    expect(reader.section, section);
    expect(t.takeException(), isNull);
    final back = find.byType(BackButton);
    expect(back.hitTestable(), findsOneWidget);
    await t.tap(back); await t.pumpAndSettle();
    expect(find.byType(ReaderPage), findsNothing);
    navigation(0);
  }
  for (var i = 1; i < 4; i++) {
    await t.tap(find.byKey(Key(navKeys[i]))); await t.pumpAndSettle();
    navigation(i);
    if (scale == 1) await capture('$prefix-tab-$i');
  }
  await t.tap(find.byKey(const Key('nav-home'))); await t.pumpAndSettle();
  navigation(0);
  await store.pendingWrites;
  await prefs.reload();
  expect(activity(), before, reason: 'Navigation and card opening must preserve existing local activity/preferences');
  await t.pumpWidget(const SizedBox.shrink());
  store.dispose(); semantics.dispose();
}
