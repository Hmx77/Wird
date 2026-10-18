part of 'main.dart';

// Existing religious copy and persistence IDs are intentionally preserved verbatim.
const rawatibPractices = <(String, String, String, String, int)>[
  ('الفجر', 'قبل', '٢', 'fajr_before', 2),
  ('الظهر', 'قبل', '٤', 'dhuhr_before', 4),
  ('الظهر', 'بعد', '٢', 'dhuhr_after', 2),
  ('المغرب', 'بعد', '٢', 'maghrib_after', 2),
  ('العشاء', 'بعد', '٢', 'isha_after', 2),
];
const rawatibSourceNote = 'أربع قبل الظهر وركعتان قبل الفجر: البخاري 1182. ركعتان بعد الظهر والمغرب والعشاء: البخاري 1180–1181. وفضل اثنتي عشرة ركعة في يوم وليلة: مسلم 728a. توجد روايات صحيحة أخرى؛ هذا عرض لإحدى صور التتبع.';
const otherPractices = <(String, String, String)>[
  ('duha', 'صلاة الضحى', 'ركعتان من الضحى تجزئان عن صدقة المفاصل؛ صحيح مسلم 720.'),
  ('witr', 'صلاة الوتر', 'صلاة الليل مثنى مثنى، وإذا خشي الصبح أوتر بواحدة؛ صحيح البخاري 990.'),
  ('night', 'قيام الليل', 'تصلّى ركعتين ركعتين؛ صحيح البخاري 990. التسجيل اختياري ولا يفرض عددًا.'),
];

class NawafilPage extends StatelessWidget {
  const NawafilPage({super.key, required this.store});
  final WirdState store;

  @override
  Widget build(BuildContext context) {
    final p = store.palette;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => ColoredBox(
        color: p.homeBackground,
        child: LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth > 680;
          final count = rawatibPractices.where((r) => store.prayerDone(r.$4)).length;
          final units = rawatibPractices.fold<int>(0, (sum, r) => sum + (store.prayerDone(r.$4) ? r.$5 : 0));
          return SingleChildScrollView(
            key: const PageStorageKey('nawafil-scroll'),
            child: Center(child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _NawafilHeader(palette: p),
                Padding(
                  padding: EdgeInsets.fromLTRB(wide ? 28 : 18, 0, wide ? 28 : 18, 30),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    _NawafilSummary(palette: p, groups: count, rakahs: units),
                    const SizedBox(height: 14),
                    ...rawatibPractices.indexed.map((entry) {
                      final r = entry.$2;
                      return _WorshipRow(
                        key: Key('prayer-${r.$4}'),
                        palette: p,
                        title: '${r.$1} — ${r.$2} الفريضة',
                        subtitle: '${r.$3} ركعات',
                        icon: [Icons.wb_twilight_rounded, Icons.wb_sunny_outlined, Icons.light_mode_outlined, Icons.wb_twilight_rounded, Icons.nightlight_round][entry.$1],
                        checked: store.prayerDone(r.$4),
                        onChanged: () => store.togglePrayer(r.$4),
                      );
                    }),
                    const SizedBox(height: 5),
                    _NawafilPanel(
                      key: const Key('nawafil-note'), palette: p, highlighted: true,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Row(children: [Icon(Icons.menu_book_rounded, color: homeGold, size: 25), SizedBox(width: 10), Flexible(child: UiText('المراجع والتنبيه', style: TextStyle(color: homeGold, fontSize: 15, fontWeight: FontWeight.w700)))]),
                        const SizedBox(height: 11),
                        const UiText(rawatibSourceNote, style: TextStyle(color: homeCream, fontSize: 13, height: 1.95)),
                      ]),
                    ),
                    const SizedBox(height: 24),
                    const Row(children: [Icon(Icons.spa_outlined, color: homeGold, size: 26), SizedBox(width: 10), UiText('نوافل أخرى', style: TextStyle(color: homeGold, fontSize: 23, fontWeight: FontWeight.w700)), SizedBox(width: 18), Expanded(child: Divider(color: Color(0x665F9D92)))]),
                    const SizedBox(height: 13),
                    ...otherPractices.indexed.map((entry) {
                      final r = entry.$2;
                      return _WorshipRow(
                        key: Key('prayer-${r.$1}'), palette: p,
                        title: r.$2, subtitle: r.$3,
                        icon: entry.$1 == 0 ? Icons.wb_sunny_outlined : Icons.nightlight_round,
                        prostration: entry.$1 == 2,
                        checked: store.prayerDone(r.$1), onChanged: () => store.togglePrayer(r.$1),
                      );
                    }),
                  ]),
                ),
              ]),
            )),
          );
        }),
      ),
    );
  }
}

class _NawafilHeader extends StatelessWidget {
  const _NawafilHeader({required this.palette});
  final WirdPalette palette;
  @override
  Widget build(BuildContext context) => Stack(children: [
    Positioned.fill(child: ExcludeSemantics(child: Image.asset('assets/home/botanical-serenity.webp', fit: BoxFit.cover, alignment: Alignment.topCenter))),
    Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [palette.homeBackground.withOpacity(.05), palette.homeBackground.withOpacity(.36), palette.homeBackground], stops: const [0, .55, 1])))),
    Padding(
      padding: const EdgeInsets.fromLTRB(25, 38, 25, 27),
      child: SizedBox(width: double.infinity, child: Column(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(shape: BoxShape.circle, color: palette.homeBackground.withOpacity(.45), border: Border.all(color: homeGold.withOpacity(.24))), child: const IconTheme(data: IconThemeData(color: homeGold), child: SujoodIcon(size: 43))),
        const SizedBox(height: 14),
        const UiText('السُّنن والنوافل', textAlign: TextAlign.center, style: TextStyle(color: homeCream, fontSize: 29, fontWeight: FontWeight.w700, height: 1.55, shadows: [Shadow(color: Color(0xFF00262B), blurRadius: 18)])),
        const SizedBox(height: 5),
        const UiText('تتبّع شخصي اختياري — دون إلزام أو تنبيهات ضاغطة', textAlign: TextAlign.center, style: TextStyle(color: homeCream, fontSize: 12, height: 1.8)),
      ])),
    ),
  ]);
}

class _NawafilSummary extends StatelessWidget {
  const _NawafilSummary({required this.palette, required this.groups, required this.rakahs});
  final WirdPalette palette;
  final int groups, rakahs;
  @override
  Widget build(BuildContext context) => _NawafilPanel(
    key: const Key('nawafil-summary'), palette: palette, highlighted: true,
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const UiText('السنن الرواتب الاثنتا عشرة', style: TextStyle(color: homeGold, fontSize: 20, height: 1.6, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        UiText('$groups / 5 مجموعات سُجّلت اليوم', style: const TextStyle(color: homeCream, fontSize: 12, height: 1.8)),
      ])),
      const SizedBox(width: 12),
      Semantics(label: uiString('ركعات سُجّلت اليوم', Localizations.localeOf(context).languageCode), value: '$rakahs / 12', child: SizedBox(width: 74, height: 74, child: Stack(alignment: Alignment.center, children: [
        Positioned.fill(child: CircularProgressIndicator(value: rakahs / 12, strokeWidth: 5, color: homeGold, backgroundColor: const Color(0xFF27595E))),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text('$rakahs/12', textDirection: TextDirection.ltr, style: const TextStyle(color: homeCream, fontSize: 18, fontWeight: FontWeight.w600)),
          const UiText('ركعات', style: TextStyle(color: homeCream, fontSize: 10)),
        ]),
      ]))),
    ]),
  );
}

class _NawafilPanel extends StatelessWidget {
  const _NawafilPanel({super.key, required this.palette, required this.child, this.highlighted = false});
  final WirdPalette palette;
  final Widget child;
  final bool highlighted;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25),
      gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color.lerp(palette.homeSurface, const Color(0xFF366259), .24)!, palette.homeBackground]),
      border: Border.all(color: highlighted ? homeGold.withOpacity(.55) : palette.homeOutline),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.11), blurRadius: 16, offset: const Offset(0, 7))],
    ), child: child,
  );
}

class _WorshipRow extends StatelessWidget {
  const _WorshipRow({super.key, required this.palette, required this.title, required this.subtitle, required this.icon, required this.checked, required this.onChanged, this.prostration = false});
  final WirdPalette palette;
  final String title, subtitle;
  final IconData icon;
  final bool checked, prostration;
  final VoidCallback onChanged;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Semantics(
      checked: checked, label: '${uiString(title, Localizations.localeOf(context).languageCode)}. ${uiString(subtitle, Localizations.localeOf(context).languageCode)}',
      onTap: onChanged,
      child: ExcludeSemantics(child: Material(
        color: Colors.transparent,
        child: Ink(decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(colors: [Color.lerp(palette.homeSurface, const Color(0xFF356457), checked ? .45 : .15)!, palette.homeBackground]),
          border: Border.all(color: checked ? homeGold.withOpacity(.72) : const Color(0xFF49716C)),
        ), child: InkWell(
          onTap: onChanged, borderRadius: BorderRadius.circular(22),
          splashColor: homeGold.withOpacity(.1), highlightColor: homeGold.withOpacity(.06),
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14), child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              UiText(title, style: const TextStyle(color: homeCream, fontSize: 17, fontWeight: FontWeight.w600, height: 1.6)),
              const SizedBox(height: 3),
              UiText(subtitle, style: const TextStyle(color: Color(0xFFCFD9CD), fontSize: 12, height: 1.85)),
            ])),
            const SizedBox(width: 12),
            IconTheme(data: const IconThemeData(color: homeGold, size: 28), child: prostration ? const SujoodIcon(size: 34) : Icon(icon)),
            const SizedBox(width: 16),
            AnimatedContainer(duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 170), width: 26, height: 26,
              decoration: BoxDecoration(color: checked ? homeGold : Colors.transparent, borderRadius: BorderRadius.circular(7), border: Border.all(color: homeGold, width: 1.6)),
              child: checked ? const Icon(Icons.check_rounded, size: 20, color: Color(0xFF003439)) : null),
          ])),
        )),
      )),
    ),
  );
}
