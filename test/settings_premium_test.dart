import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wird/main.dart';

void main() {
  Future<WirdState> mount(WidgetTester tester,{int theme=8,String language='ar',double scale=1}) async {
    SharedPreferences.setMockInitialValues({'theme':theme,'language':language,'haptics':false,'favorites':['test'],'reminder.morning.hour':9,'reminder.morning.minute':35});
    final store=WirdState(); await store.initialize();
    await tester.pumpWidget(AnimatedBuilder(animation:store,builder:(context,_)=>MaterialApp(locale:Locale(store.languageCode),supportedLocales:const[Locale('ar'),Locale('en')],localizationsDelegates:GlobalMaterialLocalizations.delegates,theme:wirdTheme(store.palette),builder:(context,child)=>MediaQuery(data:MediaQuery.of(context).copyWith(textScaler:TextScaler.linear(scale)),child:child!),home:Scaffold(body:SettingsPage(store:store)))));
    await tester.pumpAndSettle();return store;
  }
  Future<void> tap(WidgetTester t, String key) async {await t.ensureVisible(find.byKey(Key(key)));await t.pumpAndSettle();await t.tap(find.byKey(Key(key)));await t.pumpAndSettle();}
  Future<void> finish(WidgetTester t,WirdState s) async {await s.pendingWrites;await t.pumpWidget(const SizedBox.shrink());s.dispose();}
  for(final language in ['ar','en']) {
    for(var theme=0;theme<10;theme++) {
      testWidgets('Settings theme $theme $language 320px 200% text scrolls without overflow',(t) async {
        t.view.physicalSize=const Size(320,700);t.view.devicePixelRatio=1;addTearDown(t.view.resetPhysicalSize);addTearDown(t.view.resetDevicePixelRatio);
        final s=await mount(t,theme:theme,language:language,scale:2);
        expect(Directionality.of(t.element(find.byType(SettingsPage))),language=='ar'?TextDirection.rtl:TextDirection.ltr);
        for(final key in ['appearance-picker','reading-font-slider','settings-tasbih-add','auto-advance-switch','settings-erase']) {await t.ensureVisible(find.byKey(Key(key)));await t.pumpAndSettle();expect(t.takeException(),isNull);}
        await finish(t,s);
      });
    }
  }
  testWidgets('Settings controls persist and erase requires confirmation with original scope',(t)async {
    final s=await mount(t);
    await tap(t,'appearance-picker');
    expect(find.byType(RadioListTile<int>),findsNWidgets(10));
    await tap(t,'settings-theme-5');expect(s.themeIndex,5);
    await tap(t,'language-picker');await t.tap(find.text('English').last);await t.pumpAndSettle();expect(s.languageCode,'en');
    final slider=find.byKey(const Key('reading-font-slider'));await t.ensureVisible(slider);await t.drag(slider,const Offset(90,0));await t.pumpAndSettle();expect(s.fontSize,isNot(25));expect(s.fontSize,inInclusiveRange(19,38));
    await tap(t,'settings-tasbih-add');expect(s.tasbih,1);
    await tap(t,'haptics-switch');expect(s.haptics,isTrue);
    await tap(t,'auto-advance-switch');expect(s.autoAdvance,isTrue);
    await s.pendingWrites;
    final restored=WirdState();await restored.initialize();expect(restored.themeIndex,5);expect(restored.languageCode,'en');expect(restored.fontSize,s.fontSize);expect(restored.tasbih,1);expect(restored.haptics,isTrue);expect(restored.autoAdvance,isTrue);restored.dispose();
    await tap(t,'settings-erase');expect(s.favorites,contains('test'));await t.tap(find.text('Cancel'));await t.pumpAndSettle();expect(s.favorites,contains('test'));
    await tap(t,'settings-erase');await tap(t,'confirm-local-erase');expect(s.favorites,isEmpty);expect(s.tasbih,0);expect(s.themeIndex,5);expect(s.languageCode,'en');
    final prefs=await SharedPreferences.getInstance();expect(prefs.getInt('reminder.morning.hour'),9);expect(prefs.getInt('reminder.morning.minute'),35);
    await finish(t,s);
  });
  testWidgets('Reminder defaults and saved time picker work without enabling notifications',(t)async {
    final s=await mount(t);
    for(final section in ['morning','evening','bedtime']) {
      final f=find.byKey(Key('reminder-switch-$section'));expect(t.widget<Switch>(f).value,isFalse);
    }
    await tap(t,'reminder-time-morning');expect(find.byType(TimePickerDialog),findsOneWidget);await t.tap(find.text('إلغاء'));await t.pumpAndSettle();
    await tap(t,'settings-tasbih-add');await tap(t,'settings-tasbih-reset');expect(s.tasbih,0);
    await tap(t,'privacy-details');expect(find.text(settingsPrivacyCopy),findsOneWidget);
    await tap(t,'settings-licenses');expect(find.byType(LicensePage),findsOneWidget);
    await finish(t,s);
  });
}
