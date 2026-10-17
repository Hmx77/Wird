import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wird/main.dart';

void main() {
  testWidgets('automatic reveal has no CTA and keeps the real home mounted', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: WirdStartup(
      ready: true,
      child: Scaffold(body: Text('functioning home', key: Key('real-home'))),
    )));
    expect(find.byKey(const Key('cinematic-splash')), findsOneWidget);
    expect(find.byKey(const Key('real-home')), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.byType(TextButton), findsNothing);
    expect(find.text('ابدأ وردك'), findsNothing);
    final openingStyle = DefaultTextStyle.of(tester.element(find.text('WIRD'))).style;
    expect((openingStyle.decoration ?? TextDecoration.none).contains(TextDecoration.underline), isFalse,
      reason: 'Runtime opening must never inherit MaterialApp debug underlines');
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(find.byKey(const Key('cinematic-splash')), findsNothing);
    expect(find.byKey(const Key('real-home')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('slow readiness never reveals a blank page or restarts on rebuild', (tester) async {
    Widget app(bool ready) => MaterialApp(home: WirdStartup(
      ready: ready,
      child: const Scaffold(body: Text('actual home')),
    ));
    await tester.pumpWidget(app(false));
    await tester.pump(const Duration(seconds: 2));
    expect(find.byKey(const Key('cinematic-splash')), findsOneWidget);
    await tester.pumpWidget(app(true));
    expect(find.byKey(const Key('cinematic-splash')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(find.byKey(const Key('cinematic-splash')), findsNothing);
    await tester.pumpWidget(app(true));
    expect(find.byKey(const Key('cinematic-splash')), findsNothing);
  });

  testWidgets('reduced motion removes movement and still enters automatically', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MediaQuery(
      data: MediaQueryData(disableAnimations: true),
      child: WirdStartup(ready: true, child: Scaffold(body: Text('home'))),
    )));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump();
    expect(find.byKey(const Key('cinematic-splash')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
