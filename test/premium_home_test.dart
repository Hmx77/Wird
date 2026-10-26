import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wird/main.dart';
import 'package:wird/content.dart';
import 'package:wird/ui_strings.dart';

void main() {
  setUpAll(() async {
    final font = FontLoader('NotoSansArabic')..addFont(rootBundle.load('assets/fonts/NotoSansArabic.ttf'));
    await font.load();
  });
  Future<WirdState> mount(WidgetTester tester, {String language = 'ar'}) async {
    SharedPreferences.setMockInitialValues({'haptics': false, 'language': language});
    final store = WirdState();
    await store.initialize();
    await tester.pumpWidget(MaterialApp(
      locale: Locale(language), supportedLocales: const [Locale('ar'),Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: wirdTheme(store.palette), home: WirdShell(store: store),
    ));
    await tester.pumpAndSettle();
    return store;
  }
  Future<void> tapHome(WidgetTester tester, String key) async {
    final f=find.byKey(Key(key));
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
    expect(tester.takeException(),isNull);
  }
  Future<void> close(WidgetTester tester, WirdState store) async {
    await store.pendingWrites;
    await tester.pumpWidget(const SizedBox.shrink());
    store.dispose();
  }
  for (final language in ['ar','en']) {
    testWidgets('premium home cards and every shortcut navigate $language', (tester) async {
      tester.view.physicalSize=const Size(430,932);
      tester.view.devicePixelRatio=1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store=await mount(tester,language:language);
      expect(Directionality.of(tester.element(find.byType(HomePage))),language=='ar'?TextDirection.rtl:TextDirection.ltr);
      expect(find.descendant(of: find.byKey(const Key('home-morning')), matching: find.text(uiString('18 ذكر',language))),findsOneWidget);
      expect(find.text(uiString('15 ذكر',language)),findsOneWidget);
      expect(find.descendant(of: find.byKey(const Key('home-sleep')), matching: find.text(uiString('18 ذكر',language))),findsOneWidget);
      final arrow = find.descendant(of: find.byKey(const Key('home-morning')),
        matching: find.byIcon(language == 'ar' ? Icons.chevron_left_rounded : Icons.chevron_right_rounded));
      expect(tester.widget<Icon>(arrow).textDirection, TextDirection.ltr,
        reason: 'Explicit icon direction prevents RTL auto-mirroring twice');
      final shortcut = tester.getRect(find.byKey(const Key('home-all')));
      final navigation = tester.getRect(find.byType(NavigationBar));
      expect(shortcut.bottom, lessThanOrEqualTo(navigation.top),
        reason: 'All four normal-size shortcuts must be fully above bottom navigation');
      for(final section in DhikrSection.values) {
        await tapHome(tester,'home-${section.name}');
        expect(tester.widget<ReaderPage>(find.byType(ReaderPage)).section,section);
        await tester.tap(find.byType(BackButton));await tester.pumpAndSettle();
      }
      await tapHome(tester,'home-search');
      expect(find.byType(LibraryPage),findsOneWidget);
      await tester.tap(find.byType(BackButton));await tester.pumpAndSettle();
      await tapHome(tester,'home-favorites');
      expect(tester.widget<LibraryPage>(find.byType(LibraryPage)).initialFavorites,isTrue);
      await tester.tap(find.byType(BackButton));await tester.pumpAndSettle();
      await tapHome(tester,'home-tasbih');
      await tester.tap(find.byKey(const Key('home-tasbih-add')));await tester.pump();
      expect(store.tasbih,1);expect(find.text('1'),findsOneWidget);
      await tester.tap(find.byType(BackButton));await tester.pumpAndSettle();
      await tapHome(tester,'home-nawafil');
      expect(find.text(uiString('السُّنن والنوافل',language)),findsOneWidget);
      await tester.tap(find.byKey(const Key('nav-home')));await tester.pumpAndSettle();
      await tapHome(tester,'home-all');
      expect(find.text(uiString('ابحث واقرأ واحفظ أذكارك المفضلة',language)),findsOneWidget);
      await tester.tap(find.byKey(const Key('nav-home')));await tester.pumpAndSettle();
      await tapHome(tester,'home-settings');
      expect(find.text(uiString('المظهر والقراءة والخصوصية',language)),findsOneWidget);
      await tester.tap(find.byKey(const Key('nav-home')));await tester.pumpAndSettle();
      await close(tester,store);
    });
  }
  testWidgets('serenity progress reacts to counters and resumes partially read entry', (tester) async {
    final store=await mount(tester);
    final entry=inSection(DhikrSection.morning).firstWhere((e)=>e.count>1);
    store.setCount(entry,1);await tester.pumpAndSettle();
    await tapHome(tester,'home-resume');
    final reader=tester.widget<ReaderPage>(find.byType(ReaderPage));
    expect(reader.section,entry.section);
    expect(reader.initialIndex,inSection(entry.section).indexOf(entry));
    await tester.tap(find.byType(BackButton));await tester.pumpAndSettle();
    store.setCount(entry,store.target(entry));await tester.pumpAndSettle();
    final indicator=tester.widget<LinearProgressIndicator>(find.byKey(const Key('home-progress')));
    expect(indicator.value,1/entries.length);
    await close(tester,store);
  });
  testWidgets('supplied filled sujood silhouette renders at actual navigation and shortcut sizes', (tester) async {
    final key=GlobalKey();
    await tester.pumpWidget(RepaintBoundary(key:key,child:const MaterialApp(home:Scaffold(
      backgroundColor:Color(0xFF002C32),body:Center(child:Row(mainAxisSize:MainAxisSize.min,children:[
        IconTheme(data:IconThemeData(color:Color(0xFFE4C47E)),child:SujoodIcon()),
        SizedBox(width:20),IconTheme(data:IconThemeData(color:Color(0xFFE4C47E)),child:SujoodIcon(size:42)),
      ]))))));
    expect(tester.getSize(find.byType(SujoodIcon).first),const Size(28,28));
    if(Platform.environment['WIRD_REVIEW_IMAGES']=='1') {
      final render=key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image=await render.toImage(pixelRatio:2);
        final data=await image.toByteData(format:ui.ImageByteFormat.png);
        Directory('verification/screenshots').createSync(recursive:true);
        File('verification/screenshots/sujood-actual-sizes.png').writeAsBytesSync(data!.buffer.asUint8List());
        image.dispose();
      });
    }
    expect(tester.takeException(),isNull);
  });
}
