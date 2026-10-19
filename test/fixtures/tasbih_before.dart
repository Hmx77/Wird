import 'package:flutter/material.dart';
import 'package:wird/main.dart';
import 'package:wird/ui_strings.dart';
class TasbihBefore extends StatelessWidget {
  const TasbihBefore({required this.store});
  final WirdState store;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const UiText('السبحة الشخصية')),
    body: AnimatedBuilder(animation: store, builder: (context, _) => Center(
      child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(
        mainAxisSize: MainAxisSize.min, children: [
          Text('${store.tasbih}', key: const Key('home-tasbih-count'), style: TextStyle(
            fontSize: 64, color: store.palette.primary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 30),
          FilledButton.icon(key: const Key('home-tasbih-add'), onPressed: () => store.setTasbih(store.tasbih + 1),
            icon: const Icon(Icons.add_rounded), label: const UiText('تسبيح +')),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: () => store.setTasbih(0), child: const UiText('إعادة')),
          const SizedBox(height: 24),
          const UiText('هدف شخصي، وليس عددًا تعبديًا منصوصًا.', textAlign: TextAlign.center),
        ])),
    )),
  );
}
