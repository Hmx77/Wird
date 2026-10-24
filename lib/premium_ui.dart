part of 'main.dart';

/// Both uploaded originals are immutable. The new artwork already has its kasra.
const wirdArtwork = AssetImage('assets/brand/wird_artwork_20261015.png');
const openingTeal = Color(0xFF00242C);

class WirdMark extends StatelessWidget {
  const WirdMark({super.key, this.size = 104});
  final double size;
  @override
  Widget build(BuildContext context) => Semantics(
    label: tr(context, 'شعار ورد'),
    image: true,
    child: ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: ClipRect(
          child: Transform.scale(
            // Remove only the supplied transparent outer canvas. No new mask,
            // painted lettering, kasra overlay, tint or calligraphy recreation.
            scale: 1.17,
            child: Image(
              image: wirdArtwork,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              gaplessPlayback: true,
            ),
          ),
        ),
      ),
    ),
  );
}

/// Filled vector traced from the owner's supplied prostration silhouette.
/// Internal cutouts retain even-odd fill; no yoga-like stroke approximation.
class SujoodIcon extends StatelessWidget {
  const SujoodIcon({super.key, this.selected = false, this.size = 28});
  final bool selected;
  final double size;
  @override
  Widget build(BuildContext context) => SizedBox.square(
    key: Key('sujood-navigation-icon'), dimension: size,
    child: CustomPaint(painter: _SujoodPainter(IconTheme.of(context).color ?? AppAppearance.of(context).ink)),
  );
}
class _SujoodPainter extends CustomPainter {
  const _SujoodPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(0, size.height * .245);
    canvas.scale(size.width / 100);
    final path = Path()..fillType = PathFillType.evenOdd
..moveTo(38.66, 0.00)
..lineTo(47.44, 0.32)
..lineTo(53.83, 1.76)
..lineTo(55.11, 2.40)
..lineTo(56.39, 2.56)
..lineTo(57.35, 3.19)
..lineTo(58.63, 3.35)
..lineTo(59.11, 3.83)
..lineTo(60.22, 3.99)
..lineTo(61.02, 4.63)
..lineTo(63.90, 5.59)
..lineTo(64.22, 6.07)
..lineTo(65.18, 6.23)
..lineTo(69.65, 8.63)
..lineTo(78.43, 14.54)
..lineTo(85.46, 21.09)
..lineTo(85.62, 21.73)
..lineTo(86.10, 21.88)
..lineTo(86.26, 22.52)
..lineTo(87.70, 24.12)
..lineTo(88.50, 25.88)
..lineTo(88.98, 28.75)
..lineTo(88.50, 30.99)
..lineTo(88.98, 31.47)
..lineTo(91.37, 31.63)
..lineTo(95.21, 33.07)
..lineTo(95.53, 33.55)
..lineTo(96.49, 33.87)
..lineTo(98.72, 36.26)
..lineTo(99.68, 38.34)
..lineTo(100.00, 41.69)
..lineTo(99.52, 43.77)
..lineTo(98.24, 45.85)
..lineTo(95.69, 48.24)
..lineTo(94.73, 48.56)
..lineTo(93.77, 47.76)
..lineTo(90.89, 42.49)
..lineTo(88.34, 33.87)
..lineTo(87.86, 33.87)
..lineTo(86.90, 35.30)
..lineTo(87.06, 36.90)
..lineTo(89.30, 43.93)
..lineTo(90.73, 46.81)
..lineTo(92.17, 48.56)
..lineTo(92.33, 49.52)
..lineTo(91.85, 49.84)
..lineTo(85.30, 49.84)
..lineTo(82.91, 49.04)
..lineTo(80.35, 47.44)
..lineTo(78.27, 45.05)
..lineTo(77.32, 42.65)
..lineTo(77.32, 40.42)
..lineTo(78.75, 39.30)
..lineTo(79.07, 38.50)
..lineTo(78.59, 37.86)
..lineTo(72.04, 38.82)
..lineTo(65.81, 38.82)
..lineTo(63.26, 36.58)
..lineTo(62.78, 36.58)
..lineTo(61.98, 37.38)
..lineTo(62.30, 38.50)
..lineTo(68.37, 43.45)
..lineTo(69.01, 44.41)
..lineTo(61.66, 49.36)
..lineTo(59.11, 48.24)
..lineTo(55.43, 45.37)
..lineTo(51.60, 41.21)
..lineTo(50.64, 39.14)
..lineTo(50.16, 38.82)
..lineTo(49.52, 36.90)
..lineTo(49.52, 34.50)
..lineTo(50.16, 33.07)
..lineTo(50.64, 32.91)
..lineTo(51.76, 31.47)
..lineTo(57.03, 28.59)
..lineTo(63.74, 26.36)
..lineTo(72.20, 24.60)
..lineTo(72.52, 23.48)
..lineTo(72.04, 22.84)
..lineTo(66.45, 23.64)
..lineTo(67.25, 19.01)
..lineTo(66.29, 18.53)
..lineTo(65.50, 19.01)
..lineTo(63.90, 24.44)
..lineTo(57.67, 26.20)
..lineTo(52.24, 28.91)
..lineTo(47.92, 27.48)
..lineTo(44.09, 25.40)
..lineTo(43.13, 25.24)
..lineTo(38.18, 21.88)
..lineTo(37.70, 21.88)
..lineTo(37.06, 22.68)
..lineTo(37.54, 23.96)
..lineTo(40.58, 26.04)
..lineTo(46.96, 29.23)
..lineTo(49.84, 30.19)
..lineTo(49.68, 30.99)
..lineTo(48.56, 31.95)
..lineTo(47.76, 33.39)
..lineTo(47.44, 35.30)
..lineTo(47.60, 37.22)
..lineTo(48.56, 40.10)
..lineTo(49.04, 40.42)
..lineTo(50.00, 42.33)
..lineTo(51.60, 44.41)
..lineTo(54.79, 47.28)
..lineTo(54.79, 48.08)
..lineTo(52.88, 49.68)
..lineTo(50.80, 50.48)
..lineTo(48.40, 50.80)
..lineTo(37.86, 50.96)
..lineTo(32.27, 49.84)
..lineTo(30.99, 49.20)
..lineTo(29.55, 49.04)
..lineTo(25.88, 47.60)
..lineTo(24.60, 47.44)
..lineTo(21.25, 46.01)
..lineTo(19.97, 46.01)
..lineTo(19.49, 46.49)
..lineTo(19.49, 47.12)
..lineTo(19.97, 47.76)
..lineTo(23.00, 49.04)
..lineTo(24.76, 49.36)
..lineTo(25.24, 49.84)
..lineTo(27.00, 50.00)
..lineTo(27.64, 50.96)
..lineTo(11.18, 50.96)
..lineTo(9.42, 50.48)
..lineTo(8.47, 43.29)
..lineTo(7.99, 42.65)
..lineTo(7.67, 41.05)
..lineTo(6.39, 38.82)
..lineTo(5.43, 37.86)
..lineTo(4.95, 37.86)
..lineTo(3.67, 36.90)
..lineTo(4.31, 35.30)
..lineTo(6.55, 33.71)
..lineTo(11.02, 33.71)
..lineTo(17.25, 35.78)
..lineTo(22.04, 36.42)
..lineTo(30.35, 36.42)
..lineTo(35.30, 42.49)
..lineTo(36.42, 42.81)
..lineTo(37.06, 42.33)
..lineTo(36.90, 41.05)
..lineTo(35.14, 38.82)
..lineTo(34.66, 38.66)
..lineTo(32.75, 35.78)
..lineTo(32.43, 35.78)
..lineTo(30.51, 32.75)
..lineTo(30.19, 32.75)
..lineTo(27.64, 28.43)
..lineTo(27.16, 28.12)
..lineTo(27.00, 27.16)
..lineTo(25.72, 25.24)
..lineTo(23.48, 19.17)
..lineTo(22.84, 15.34)
..lineTo(22.84, 12.78)
..lineTo(23.32, 10.06)
..lineTo(24.28, 7.83)
..lineTo(25.72, 5.75)
..lineTo(27.64, 3.99)
..lineTo(29.39, 2.72)
..lineTo(32.27, 1.60)
..lineTo(32.75, 1.12)
..lineTo(38.66, 0.00)
..close()
..moveTo(2.56, 38.66)
..lineTo(3.99, 38.98)
..lineTo(5.43, 40.26)
..lineTo(6.87, 43.77)
..lineTo(6.87, 44.57)
..lineTo(6.07, 45.21)
..lineTo(4.79, 45.53)
..lineTo(3.83, 47.12)
..lineTo(4.15, 48.88)
..lineTo(6.23, 49.36)
..lineTo(6.71, 50.16)
..lineTo(6.23, 50.64)
..lineTo(1.12, 50.64)
..lineTo(0.48, 50.32)
..lineTo(0.00, 49.04)
..lineTo(0.32, 46.49)
..lineTo(1.28, 43.61)
..lineTo(1.12, 39.62)
..lineTo(1.60, 38.98)
..lineTo(2.56, 38.66)
..close()
..moveTo(69.81, 46.49)
..lineTo(73.16, 46.81)
..lineTo(76.52, 47.76)
..lineTo(79.39, 49.36)
..lineTo(79.39, 50.32)
..lineTo(78.75, 50.64)
..lineTo(64.38, 50.64)
..lineTo(64.22, 50.16)
..lineTo(66.93, 47.76)
..lineTo(67.73, 47.44)
..lineTo(67.89, 46.96)
..lineTo(69.81, 46.49)
..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.restore();
  }
  @override
  bool shouldRepaint(_SujoodPainter oldDelegate) => oldDelegate.color != color;
}

const homeCream = Color(0xFFF5EAD0);
const homeGold = Color(0xFFE4C47E);
const homeArt = <String, AssetImage>{
  'morning': AssetImage('assets/home/morning.webp'),
  'evening': AssetImage('assets/home/evening.webp'),
  'sleep': AssetImage('assets/home/night.webp'),
  'serenity': AssetImage('assets/home/serenity.webp'),
};

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.store, this.onNavigate});
  final WirdState store;
  final ValueChanged<int>? onNavigate;

  void browse(BuildContext context, {bool favorites = false}) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => Scaffold(
      backgroundColor:store.palette.homeBackground,
      appBar: AppBar(backgroundColor:store.palette.homeBackground,foregroundColor:AppAppearance.of(context).ink,surfaceTintColor:Colors.transparent,title: UiText(favorites ? 'المفضلة' : 'الأذكار')),
      body: SafeArea(child: LibraryPage(store: store, initialFavorites: favorites)),
    )),
  );

  void destination(BuildContext context, int page) {
    if (onNavigate != null) { onNavigate!(page); return; }
    final screen = switch (page) {
      1 => LibraryPage(store: store),
      2 => NawafilPage(store: store),
      _ => SettingsPage(store: store),
    };
    Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
      appBar: AppBar(), body: SafeArea(child: screen),
    )));
  }

  void resume(BuildContext context) {
    // Prefer an unfinished entry already started today. Otherwise open the
    // first incomplete entry in the current collection; no new storage keys.
    final hour = DateTime.now().hour;
    var section = hour < 12 ? DhikrSection.morning : hour < 21 ? DhikrSection.evening : DhikrSection.sleep;
    for (final entry in entries) {
      if (store.count(entry) > 0 && !store.isDone(entry)) {
        section = entry.section;
        openReader(context, store, section, initial: inSection(section).indexOf(entry));
        return;
      }
    }
    final list = inSection(section);
    final index = list.indexWhere((e) => !store.isDone(e));
    openReader(context, store, section, initial: index < 0 ? 0 : index);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (context, _) {
      final p = store.palette;
      if (!p.dark) return _IvoryHome(home: this);
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      final done = entries.where((e) => store.isDone(e)).length;
      return ColoredBox(
        color: p.homeBackground,
        child: Center(child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 760),
          child: LayoutBuilder(builder: (context, constraints) {
            final wideText = scale > 1.4 && constraints.maxWidth < 650;
            final padding = constraints.maxWidth < 360 ? 12.0 : 16.0;
            final shortcuts = <Widget>[
              _HomeShortcut(key: Key('home-favorites'), label: 'المفضلة',
                subtitle: '${store.favorites.length} ذكر', icon: Icons.favorite_border_rounded,
                accent: AppAppearance.of(context).gold, onTap: () => browse(context, favorites: true)),
              _HomeShortcut(key: Key('home-nawafil'), label: 'النوافل',
                subtitle: 'السنن والنوافل', symbol: SujoodIcon(size: 42),
                accent: AppAppearance.of(context).gold, onTap: () => destination(context, 2)),
              _HomeShortcut(key: Key('home-tasbih'), label: 'التسبيح',
                subtitle: 'عداد رقمي', symbol: SizedBox.square(dimension: 34,
                  child: CustomPaint(painter: _BeadsPainter(AppAppearance.of(context).dark ? homeGold : AppAppearance.of(context).accent))),
                accent: AppAppearance.of(context).gold, onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => _HomeTasbihPage(store: store)))),
              _HomeShortcut(key: Key('home-all'), label: 'جميع الأذكار',
                subtitle: 'كل الأقسام', icon: Icons.grid_view_rounded,
                accent: appearanceTone(context, 0xFF86D8C8), onTap: () => destination(context, 1)),
            ];
            return SingleChildScrollView(
              key: PageStorageKey('premium-home-scroll'),
              child: Padding(
                padding: EdgeInsets.fromLTRB(padding, 0, padding, 18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  _HomeHeader(store: store, onSearch: () => browse(context),
                    onSettings: () => destination(context, 3)),
                  _HomeIllustratedSurface(
                    art: homeArt['serenity']!, radius: 23,
                    onTap: () => resume(context), actionKey: Key('home-resume'),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(18, 13, 16, 12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Align(alignment: AlignmentDirectional.centerStart,
                          child: Icon(Icons.spa_outlined, size: 20, color: AppAppearance.of(context).gold)),
                        SizedBox(height: 4),
                        Align(alignment: AlignmentDirectional.centerStart,
                          child: FractionallySizedBox(widthFactor: wideText ? .95 : .7,
                            child: IvoryReadingBacking(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              UiText('لحظات من السكينة', style: TextStyle(
                                color: AppAppearance.of(context).ink, fontSize: 20, height: 1.4, fontWeight: FontWeight.w700)),
                              SizedBox(height: 4),
                              UiText('اختر وردك وابدأ القراءة', style: TextStyle(
                                color: AppAppearance.of(context).ink, fontSize: 11, height: 1.5)),
                              SizedBox(height: 8),
                              Container(padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(color: AppAppearance.of(context).dark ? appearanceTone(context, 0xD0083035) : IvoryContrast.cream,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: AppAppearance.of(context).dark ? appearanceTone(context, 0x5585BCB2) : IvoryContrast.border)),
                                child: Row(children: [
                                  Icon(Icons.menu_book_outlined, color: AppAppearance.of(context).gold, size: 21),
                                  SizedBox(width: 8),
                                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    UiText('متابعة القراءة', style: TextStyle(color: AppAppearance.of(context).ink, fontSize: 10)),
                                    SizedBox(height: 5),
                                    LinearProgressIndicator(key: Key('home-progress'),
                                      value: done / entries.length, minHeight: 4,
                                      borderRadius: BorderRadius.circular(5),
                                      color: AppAppearance.of(context).dark ? appearanceTone(context, 0xFF7DDBCA) : IvoryContrast.accent,
                                      backgroundColor: AppAppearance.of(context).dark ? appearanceTone(context, 0xFF31565A) : IvoryContrast.progressTrack,
                                      semanticsLabel: tr(context, 'تقدم اليوم'), semanticsValue: '$done / ${entries.length}'),
                                    SizedBox(height: 3),
                                    UiText('$done / ${entries.length} مكتمل', textDirection: TextDirection.ltr, style: TextStyle(
                                      color: AppAppearance.of(context).ink, fontSize: 9)),
                                  ])),
                                  SizedBox(width: 8),
                                  _HomeArrow(filled: true, size: 30),
                                ])),
                            ])))),
                      ])),
                  ),
                  SizedBox(height: 10),
                  if (wideText) ...[
                    _category(context, DhikrSection.morning, wide: true),
                    SizedBox(height: 10),
                    _category(context, DhikrSection.evening, wide: true),
                  ] else Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: _category(context, DhikrSection.morning)),
                    SizedBox(width: 10),
                    Expanded(child: _category(context, DhikrSection.evening)),
                  ]),
                  SizedBox(height: 10),
                  _category(context, DhikrSection.sleep, wide: true),
                  SizedBox(height: 10),
                  LayoutBuilder(builder: (context, c) {
                    final columns = wideText || c.maxWidth < 330 ? 2 : 4;
                    return Wrap(spacing: 7, runSpacing: 8, children: shortcuts.map((card) => SizedBox(
                      width: (c.maxWidth - 7 * (columns - 1)) / columns, child: card)).toList());
                  }),
                ]),
              ),
            );
          }),
        )),
      );
    },
  );

  Widget _category(BuildContext context, DhikrSection section, {bool wide = false}) {
    final count = inSection(section).length;
    final categoryInk = !store.palette.dark && section == DhikrSection.sleep
        ? homeCream : AppAppearance.of(context).ink;
    final done = store.completed(section);
    final icon = switch (section) {
      DhikrSection.morning => Icons.wb_sunny_outlined,
      DhikrSection.evening => Icons.nightlight_outlined,
      DhikrSection.sleep => Icons.bedtime_outlined,
    };
    final badge = AppAppearance.of(context).dark
        ? (section == DhikrSection.morning ? appearanceTone(context, 0xAA507B70) : appearanceTone(context, 0xAA343D88))
        : section == DhikrSection.morning ? const Color(0xFFD4E2CB) : IvoryContrast.cream;
    final badgeInk = !store.palette.dark && section == DhikrSection.sleep
        ? const Color(0xFF426E8A) : categoryInk;
    return _HomeIllustratedSurface(
      art: homeArt[section.name]!, radius: 21,
      actionKey: Key('home-${section.name}'), onTap: () => openReader(context, store, section),
      shade: true,
      child: Padding(padding: EdgeInsets.all(wide ? 16 : 13),
        child: wide ? Row(children: [
          Container(padding: EdgeInsets.all(7),
            decoration: BoxDecoration(color: badge, borderRadius: BorderRadius.circular(13),
              border: Border.all(color: appearanceTone(context, 0x55E9D8AE))),
            child: Icon(icon, color: badgeInk, size: 25)),
          SizedBox(width: 12),
          Expanded(child: RepaintBoundary(
            key: ValueKey('category-label-${section.name}-${store.themeIndex}-${store.languageCode}'),
            child: Column(mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            UiText(sectionLabel(section), style: TextStyle(color: categoryInk,
              fontSize: 18, fontWeight: FontWeight.w700, height: 1.5)),
            SizedBox(height: 3),
            UiText('$count ذكر', style: TextStyle(color: categoryInk, fontSize: 11)),
            if (done > 0) ...[
              SizedBox(height: 6),
              LinearProgressIndicator(value: done / count, minHeight: 3,
                color: AppAppearance.of(context).gold, backgroundColor: Colors.white12,
                semanticsLabel: tr(context, sectionLabel(section)), semanticsValue: '$done / $count'),
            ],
          ]))),
          SizedBox(width: 8),
          _HomeArrow(ink: categoryInk, size: 28, complete: done == count),
        ]) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: EdgeInsets.all(7),
            decoration: BoxDecoration(color: badge, borderRadius: BorderRadius.circular(13),
              border: Border.all(color: appearanceTone(context, 0x55E9D8AE))),
            child: Icon(icon, color: badgeInk, size: 29)),
          SizedBox(height: 12),
          IvoryReadingBacking(child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              UiText(sectionLabel(section), style: TextStyle(color: categoryInk,
                fontSize: 16, fontWeight: FontWeight.w700, height: 1.5)),
              SizedBox(height: 3),
              UiText('$count ذكر', style: TextStyle(color: categoryInk, fontSize: 11)),
            ])),
            SizedBox(width: 5),
            _HomeArrow(ink: categoryInk, size: 24, complete: done == count),
          ])),
          if (done > 0) ...[
            SizedBox(height: 8),
            LinearProgressIndicator(value: done / count, minHeight: 3,
              color: AppAppearance.of(context).gold, backgroundColor: Colors.white12,
              semanticsLabel: tr(context, sectionLabel(section)), semanticsValue: '$done / $count'),
          ],
        ])),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.store, required this.onSearch, required this.onSettings});
  final WirdState store;
  final VoidCallback onSearch, onSettings;
  @override
  Widget build(BuildContext context) => Stack(children: [
    Positioned.fill(child: ClipRect(child: Opacity(opacity: store.palette.dark ? .48 : .72, child: Transform(
      alignment: Alignment.center, transform: Matrix4.diagonal3Values(-1, 1, 1),
      child: Image(image: appearanceArt(context, homeArt['morning']!), fit: BoxFit.cover, alignment: Alignment.centerLeft,
        excludeFromSemantics: true))))),
    Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: store.palette.dark
        ? [store.palette.homeBackground.withOpacity(.35), store.palette.homeBackground.withOpacity(.82), store.palette.homeBackground]
        : [store.palette.homeBackground.withOpacity(.20), store.palette.homeBackground.withOpacity(.72), store.palette.homeBackground])))),
    Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 16), child: Column(children: [
      Stack(alignment: Alignment.topCenter, children: [
        SizedBox(height: 96, child: Semantics(label: tr(context, 'شعار ورد'), image: true,
          child: ExcludeSemantics(child: ClipRect(child: Transform.scale(scale: 1.5,
            child: AppearanceWordmark(key: Key('home-wordmark'))))))),
        Align(alignment: AlignmentDirectional.topEnd, child: Row(mainAxisSize: MainAxisSize.min, textDirection: TextDirection.ltr, children: [
          IconButton.outlined(key: Key('home-settings'), tooltip: tr(context, 'الإعدادات'),
            onPressed: onSettings, icon: Icon(Icons.settings_outlined, size: 21),
            style: IconButton.styleFrom(foregroundColor: AppAppearance.of(context).ink, backgroundColor: store.palette.dark ? appearanceTone(context, 0x30002C32) : IvoryContrast.cream.withValues(alpha: .96),
              side: BorderSide(color: store.palette.dark ? appearanceTone(context, 0x556DB9AF) : IvoryContrast.outline))),
          SizedBox(width: 6),
          IconButton.outlined(key: Key('home-search'), tooltip: tr(context, 'ابحث عن ذكر'),
            onPressed: onSearch, icon: Icon(Icons.search_rounded, size: 21),
            style: IconButton.styleFrom(foregroundColor: AppAppearance.of(context).ink, backgroundColor: store.palette.dark ? appearanceTone(context, 0x30002C32) : IvoryContrast.cream.withValues(alpha: .96),
              side: BorderSide(color: store.palette.dark ? appearanceTone(context, 0x556DB9AF) : IvoryContrast.outline))),
        ])),
      ]),
      UiText('وردك اليومي', textAlign: TextAlign.center, style: TextStyle(
        fontSize: 29, height: 1.5, color: AppAppearance.of(context).ink, fontWeight: FontWeight.w700)),
      SizedBox(height: 2),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(width: 25, child: Divider(color: appearanceTone(context, 0x887B744F))),
        SizedBox(width: 9),
        Flexible(child: UiText('ذِكْرٌ يُرَافِقُ يَوْمَكَ', textAlign: TextAlign.center,
          style: TextStyle(color: AppAppearance.of(context).ink, fontSize: 13, height: 1.8))),
        SizedBox(width: 9),
        SizedBox(width: 25, child: Divider(color: appearanceTone(context, 0x887B744F))),
      ]),
    ])),
  ]);
}

class _HomeIllustratedSurface extends StatelessWidget {
  const _HomeIllustratedSurface({required this.art, required this.child, required this.onTap,
    required this.actionKey, this.radius = 22, this.shade = false});
  final AssetImage art;
  final Widget child;
  final VoidCallback onTap;
  final Key actionKey;
  final double radius;
  final bool shade;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius), boxShadow: [
      BoxShadow(color: appearanceTone(context, 0x22000000), offset: Offset(0, 6), blurRadius: 18)]),
    child: Material(color: appearanceTone(context, 0xFF07373D), clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: AppAppearance.of(context).dark ? Theme.of(context).colorScheme.primary.withOpacity(.65) : IvoryContrast.border, width: 1)),
      child: Stack(children: [
        Positioned.fill(child: Image(image: !AppAppearance.of(context).dark && art == homeArt['serenity'] ? ivorySanctuary : art, fit: BoxFit.cover, alignment: Alignment.topCenter, excludeFromSemantics: true,
          gaplessPlayback: true, filterQuality: FilterQuality.medium)),
        if (shade || !AppAppearance.of(context).dark) Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
          begin: !AppAppearance.of(context).dark && art == homeArt['serenity']
              ? AlignmentDirectional.centerStart.resolve(Directionality.of(context)) : Alignment.topCenter,
          end: !AppAppearance.of(context).dark && art == homeArt['serenity']
              ? AlignmentDirectional.centerEnd.resolve(Directionality.of(context)) : Alignment.bottomCenter,
          stops: AppAppearance.of(context).dark || art == homeArt['sleep'] ? null
              : art == homeArt['serenity'] ? const [0, .68, 1] : const [0, .35, .52, 1],
          colors: AppAppearance.of(context).dark || art == homeArt['sleep']
            ? [Color(0x00002128), Color(0xDA002128)]
            : art == homeArt['serenity']
              ? [IvoryContrast.readingBacking, IvoryContrast.readingBacking, Color(0x22FFF8E8)]
              : [Color(0x00FFF8E8), Color(0x26FFF8E8), IvoryContrast.readingBacking, IvoryContrast.cream])))),
        InkWell(key: actionKey, onTap: onTap, splashColor: AppAppearance.of(context).gold.withOpacity(.15),
          highlightColor: AppAppearance.of(context).gold.withOpacity(.07), child: child),
      ])),
  );
}

class _HomeArrow extends StatelessWidget {
  const _HomeArrow({this.filled = false, this.size = 28, this.complete = false, this.ink});
  final Color? ink;
  final bool filled, complete;
  final double size;
  @override
  Widget build(BuildContext context) {
    if (!AppAppearance.of(context).dark) {
      final night = ink == homeCream && !filled;
      return ExcludeSemantics(child: Container(width: size, height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle,
          color: filled ? IvoryContrast.ink : night ? const Color(0xFF082A36) : IvoryContrast.cream,
          border: Border.all(color: night ? homeGold : IvoryContrast.outline)),
        child: Icon(complete ? Icons.check_rounded : Directionality.of(context) == TextDirection.rtl
          ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
          textDirection: TextDirection.ltr, size: size * .7,
          color: filled || night ? IvoryContrast.cream : IvoryContrast.ink)));
    }
    return ExcludeSemantics(child: Container(
    width: size, height: size, alignment: Alignment.center,
    decoration: BoxDecoration(shape: BoxShape.circle,
      gradient: filled ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [appearanceTone(context, 0xFFF7DE9E), appearanceTone(context, 0xFFB49352)]) : null,
      border: Border.all(color: AppAppearance.of(context).gold.withOpacity(.75))),
    child: Icon(complete ? Icons.check_rounded : Directionality.of(context) == TextDirection.rtl
      ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
      textDirection: TextDirection.ltr, size: size * .7, color: filled ? appearanceTone(context, 0xFF143D3D) : (ink ?? AppAppearance.of(context).ink))));
  }
}

class _HomeShortcut extends StatelessWidget {
  const _HomeShortcut({super.key, required this.label, required this.subtitle, this.icon,
    this.symbol, required this.accent, required this.onTap});
  final String label, subtitle;
  final IconData? icon;
  final Widget? symbol;
  final Color accent;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent, clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19),
      side: BorderSide(color: AppAppearance.of(context).dark ? accent.withOpacity(.35) : IvoryContrast.border)),
    child: Ink(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft,
      end: Alignment.bottomRight, colors: AppAppearance.of(context).dark
        ? [accent.withOpacity(.14), appearanceTone(context, 0xFF073035)]
        : label == 'جميع الأذكار' ? [IvoryContrast.sage, const Color(0xFFF0F3E5)]
        : [IvoryContrast.cream, const Color(0xFFF6EDD9)])),
      child: InkWell(onTap: onTap, child: Padding(padding: EdgeInsets.symmetric(horizontal: 7, vertical: 13),
        child: Column(children: [
          IconTheme(data: IconThemeData(color: accent), child: SizedBox(height: 35,
            child: Center(child: symbol ?? Icon(icon, color: accent, size: 31)))),
          SizedBox(height: 9),
          UiText(label, textAlign: TextAlign.center, style: TextStyle(
            color: AppAppearance.of(context).ink, fontSize: 13, height: 1.6, fontWeight: FontWeight.w600)),
          SizedBox(height: 4),
          UiText(subtitle, textAlign: TextAlign.center, style: TextStyle(
            color: appearanceTone(context, 0xFFCAD9D3), fontSize: 10, height: 1.6)),
        ])))),
  );
}

class _BeadsPainter extends CustomPainter {
  const _BeadsPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const beads = <Offset>[
      Offset(.26,.79),Offset(.15,.63),Offset(.12,.44),Offset(.16,.26),Offset(.29,.13),
      Offset(.47,.09),Offset(.64,.16),Offset(.76,.29),Offset(.81,.48),Offset(.75,.66),
      Offset(.61,.79),Offset(.43,.85),
    ];
    for (final o in beads) { canvas.drawCircle(Offset(o.dx*size.width,o.dy*size.height),size.width*.057,paint); }
    canvas.drawLine(Offset(size.width*.29,size.height*.82),Offset(size.width*.23,size.height*.99),
      paint..strokeWidth = size.width*.05..strokeCap = StrokeCap.round);
  }
  @override
  bool shouldRepaint(_BeadsPainter oldDelegate) => oldDelegate.color != color;
}

class _HomeTasbihPage extends PersonalTasbihPage {
  const _HomeTasbihPage({required super.store});
}

// Ivory Home uses separately composed scenery. The approved dark widget tree
// above remains unchanged, including its typography and illustration layers.
const ivoryHomeHeader = AssetImage('assets/appearance/ivory-home-header-v2.webp');
const ivoryHomeFeature = AssetImage('assets/appearance/ivory-home-feature-v2.webp');

class _IvoryHome extends StatelessWidget {
  const _IvoryHome({required this.home});
  final HomePage home;
  WirdState get store => home.store;
  static const paper = Color(0xFFFAF6E9);
  static const edge = Color(0xFFC1A775);

  TextStyle text(double size, {bool bold = false, Color? color}) => TextStyle(
    color: color ?? IvoryContrast.ink, fontSize: size, height: 1.5,
    fontWeight: bold ? FontWeight.w700 : FontWeight.w400);

  @override
  Widget build(BuildContext context) => ColoredBox(color: paper,
    child: Align(alignment: Alignment.topCenter, child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760),
      child: LayoutBuilder(builder: (context, box) {
        final large = MediaQuery.textScalerOf(context).scale(14) > 20;
        final inset = box.maxWidth < 360 ? 10.0 : 13.0;
        final width = box.maxWidth - inset * 2;
        final unit = (width / 400).clamp(.80, 1.4).toDouble();
        return SingleChildScrollView(key: const PageStorageKey('premium-home-scroll'),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _header(context, unit),
            Padding(padding: EdgeInsets.fromLTRB(inset, 0, inset, 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _featured(context, unit, large),
                const SizedBox(height: 10),
                if (large && width < 600) ...[
                  _category(context, DhikrSection.morning, unit),
                  const SizedBox(height: 10),
                  _category(context, DhikrSection.evening, unit),
                ] else Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: _category(context, DhikrSection.morning, unit)),
                  const SizedBox(width: 10),
                  Expanded(child: _category(context, DhikrSection.evening, unit)),
                ]),
                const SizedBox(height: 10),
                _category(context, DhikrSection.sleep, unit),
                const SizedBox(height: 10),
                _shortcuts(context, width, unit, large),
              ])),
          ]));
      }))));

  Widget _header(BuildContext context, double unit) => Stack(children: [
    Positioned.fill(child: ShaderMask(blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => const LinearGradient(begin: Alignment.topCenter,
        end: Alignment.bottomCenter, colors: [Colors.white, Colors.white, Colors.transparent],
        stops: [0, .72, 1]).createShader(bounds),
      child: const Image(image: ivoryHomeHeader, fit: BoxFit.cover,
        alignment: Alignment.topCenter, excludeFromSemantics: true))),
    Padding(padding: EdgeInsets.fromLTRB(13, 5, 13, 15 * unit), child: Column(children: [
      Stack(alignment: Alignment.topCenter, children: [
        SizedBox(height: 115 * unit, child: Center(child: Semantics(
          label: tr(context, 'شعار ورد'), image: true,
          child: ExcludeSemantics(child: Transform.scale(scale: 1.35, child: AppearanceWordmark(key: const Key('home-wordmark'),
            width: 158 * unit, height: 112 * unit)))))),
        Align(alignment: Alignment.topLeft, child: Row(mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.ltr, children: [
            _headerControl(context, 'home-settings', 'الإعدادات', Icons.settings_outlined,
              () => home.destination(context, 3)),
            const SizedBox(width: 5),
            _headerControl(context, 'home-search', 'ابحث عن ذكر', Icons.search_rounded,
              () => home.browse(context)),
          ])),
      ]),
      UiText('وردك اليومي', textAlign: TextAlign.center, style: text(30 * unit, bold: true)),
      const SizedBox(height: 3),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const SizedBox(width: 29, child: Divider(color: edge, thickness: 1)),
        const SizedBox(width: 9),
        Flexible(child: UiText('ذِكْرٌ يُرَافِقُ يَوْمَكَ', textAlign: TextAlign.center,
          style: text(14 * unit, color: IvoryContrast.gold))),
        const SizedBox(width: 9),
        const SizedBox(width: 29, child: Divider(color: edge, thickness: 1)),
      ]),
    ])),
  ]);

  Widget _headerControl(BuildContext context, String keyName, String label,
      IconData icon, VoidCallback action) => IconButton.outlined(
    key: Key(keyName), tooltip: tr(context, label), onPressed: action,
    icon: Icon(icon, size: 23), style: IconButton.styleFrom(
      foregroundColor: IvoryContrast.ink, backgroundColor: paper.withValues(alpha: .86),
      minimumSize: const Size(44, 44), side: const BorderSide(color: Color(0xFFC9BEA0), width: .75)));

  Widget _surface({required String keyName, required AssetImage image,
      required Widget child, required VoidCallback onTap, Gradient? gradient,
      double radius = 22, bool mirror = false}) => DecoratedBox(
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius), boxShadow: const [
      BoxShadow(color: Color(0x0A70572D), offset: Offset(0, 3), blurRadius: 9)]),
    child: Material(color: paper, clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius),
        side: const BorderSide(color: edge, width: .75)),
      child: Stack(children: [
        Positioned.fill(child: Transform(
          alignment: Alignment.center, transform: Matrix4.diagonal3Values(mirror ? -1 : 1, 1, 1),
          child: Image(image: image, fit: BoxFit.cover, alignment: Alignment.topCenter,
            filterQuality: FilterQuality.high, excludeFromSemantics: true))),
        if (gradient != null) Positioned.fill(child: DecoratedBox(
          decoration: BoxDecoration(gradient: gradient))),
        InkWell(key: Key(keyName), onTap: onTap,
          splashColor: IvoryContrast.accent.withValues(alpha: .12),
          highlightColor: IvoryContrast.gold.withValues(alpha: .06), child: child),
      ])));

  Widget _featured(BuildContext context, double unit, bool large) {
    final done = entries.where(store.isDone).length;
    return _surface(keyName: 'home-resume', image: ivoryHomeFeature,
      onTap: () => home.resume(context),
      mirror: Directionality.of(context) == TextDirection.ltr,
      // Feather only the outer botanical edge, never the left architectural scene.
      gradient: LinearGradient(
        begin: AlignmentDirectional.centerEnd.resolve(Directionality.of(context)),
        end: AlignmentDirectional.centerStart.resolve(Directionality.of(context)),
        stops: const [0, .75, 1],
        colors: const [Color(0x00FAF6E9), Color(0x00FAF6E9), Color(0xE6FAF6E9)]),
      // Text sits in the art's clear sky; only the real reading control has a fill.
      child: ConstrainedBox(constraints: BoxConstraints(minHeight: 195 * unit),
        child: Padding(padding: EdgeInsets.fromLTRB(10, 11 * unit, 14, 10 * unit),
          child: Align(alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(widthFactor: large ? .72 : .70,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Align(alignment: AlignmentDirectional.centerStart,
                  child: Icon(Icons.spa_outlined, size: 24 * unit, color: IvoryContrast.gold)),
                SizedBox(height: 6 * unit),
                UiText('لحظات من السكينة', style: text(20 * unit, bold: true)),
                SizedBox(height: 5 * unit),
                UiText('اختر وردك وابدأ القراءة', style: text(11.5 * unit)),
                SizedBox(height: 13 * unit),
                Container(width: double.infinity, padding: EdgeInsets.all(10 * unit),
                  decoration: BoxDecoration(color: paper.withValues(alpha: .95),
                    borderRadius: BorderRadius.circular(29),
                    border: Border.all(color: const Color(0xFFC9BEA0), width: .75)),
                  child: Row(children: [
                    Icon(Icons.menu_book_outlined, color: IvoryContrast.gold, size: 24 * unit),
                    const SizedBox(width: 8),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      UiText('متابعة القراءة', style: text(11 * unit, bold: true)),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(key: const Key('home-progress'), value: done / entries.length,
                        minHeight: 5, borderRadius: BorderRadius.circular(8),
                        color: IvoryContrast.accent, backgroundColor: const Color(0xFFE1DECE),
                        semanticsLabel: tr(context, 'تقدم اليوم'), semanticsValue: '$done / ${entries.length}'),
                      const SizedBox(height: 5),
                      UiText('$done / ${entries.length} مكتمل', textDirection: TextDirection.ltr,
                        style: text(10.5 * unit)),
                    ])),
                    const SizedBox(width: 9),
                    _HomeArrow(filled: true, size: 36 * unit),
                  ])),
              ]))))));
  }

  Widget _category(BuildContext context, DhikrSection section, double unit) {
    final large = MediaQuery.textScalerOf(context).scale(14) > 20;
    final night = section == DhikrSection.sleep;
    final morning = section == DhikrSection.morning;
    final count = inSection(section).length;
    final done = store.completed(section);
    final ink = night ? homeCream : IvoryContrast.ink;
    final icon = night ? Icons.bedtime_outlined : morning ? Icons.wb_sunny_outlined : Icons.nightlight_outlined;
    final badge = Container(width: 48 * unit, height: 48 * unit,
      decoration: BoxDecoration(color: morning ? const Color(0xFFD8E5CB) : paper,
        borderRadius: BorderRadius.circular(13), border: Border.all(color: const Color(0xFFC8C5AD), width: .7)),
      child: Icon(icon, size: 33 * unit, color: night ? const Color(0xFF426E8A) : IvoryContrast.ink));
    final label = RepaintBoundary(
      key: ValueKey('category-label-${section.name}-${store.themeIndex}-${store.languageCode}'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        UiText(sectionLabel(section), style: text((night ? 21 : 17) * unit, bold: true, color: ink)),
        const SizedBox(height: 2), UiText('$count ذكر', style: text(12 * unit, color: ink)),
      ]));
    return _surface(keyName: 'home-${section.name}', image: homeArt[section.name]!,
      onTap: () => openReader(context, store, section),
      gradient: night ? const LinearGradient(colors: [Color(0x18002128), Color(0x30002128)])
        : LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
          stops: large ? const [0, .12, .25, .40, 1] : const [0, .30, .45, .65, 1],
          colors: const [Color(0x00FAF6E9), Color(0x00FAF6E9), Color(0x40FAF6E9), Color(0xF5FAF6E9), paper]),
      child: Padding(padding: EdgeInsets.all(11 * unit),
        child: night ? ConstrainedBox(constraints: BoxConstraints(minHeight: 67 * unit),
          child: Row(children: [badge, const SizedBox(width: 12), Expanded(child: label),
            const SizedBox(width: 8), _HomeArrow(ink: ink, size: 32 * unit, complete: done == count)]))
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              badge, SizedBox(height: 15 * unit),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(child: label), const SizedBox(width: 2),
                _HomeArrow(size: 31 * unit, complete: done == count),
              ]),
              if (done > 0) ...[const SizedBox(height: 5),
                LinearProgressIndicator(value: done / count, minHeight: 3,
                  color: IvoryContrast.accent, backgroundColor: IvoryContrast.progressTrack,
                  semanticsLabel: tr(context, sectionLabel(section)), semanticsValue: '$done / $count')],
            ])));
  }

  Widget _shortcuts(BuildContext context, double width, double unit, bool large) {
    final cards = <Widget>[
      _HomeShortcut(key: const Key('home-favorites'), label: 'المفضلة',
        subtitle: '${store.favorites.length} ذكر', icon: Icons.favorite_border_rounded,
        accent: IvoryContrast.gold, onTap: () => home.browse(context, favorites: true)),
      _HomeShortcut(key: const Key('home-nawafil'), label: 'النوافل', subtitle: 'السنن والنوافل',
        symbol: const SujoodIcon(size: 42), accent: IvoryContrast.gold,
        onTap: () => home.destination(context, 2)),
      _HomeShortcut(key: const Key('home-tasbih'), label: 'التسبيح', subtitle: 'عداد رقمي',
        symbol: SizedBox.square(dimension: 34,
          child: CustomPaint(painter: const _BeadsPainter(IvoryContrast.accent))),
        accent: IvoryContrast.accent, onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => _HomeTasbihPage(store: store)))),
      _HomeShortcut(key: const Key('home-all'), label: 'جميع الأذكار', subtitle: 'كل الأقسام',
        icon: Icons.grid_view_rounded, accent: IvoryContrast.accent,
        onTap: () => home.destination(context, 1)),
    ];
    final columns = large ? 2 : 4;
    return Wrap(spacing: 7, runSpacing: 8, children: cards.map((card) => SizedBox(
      width: (width - 7 * (columns - 1)) / columns, child: card)).toList());
  }
}

/// The reference's full Home selection tile, restricted to the Ivory Home.
class _IvoryHomeNavigation extends StatelessWidget {
  const _IvoryHomeNavigation({required this.onNavigate});
  final ValueChanged<int> onNavigate;
  @override
  Widget build(BuildContext context) => ColoredBox(color: _IvoryHome.paper,
    child: SafeArea(top: false, minimum: const EdgeInsets.fromLTRB(11, 0, 11, 5),
      child: Container(padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(color: const Color(0xFFFFFAEF),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFFD0C09A), width: .75)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(4, (index) {
            const labels = ['الرئيسية', 'الأذكار', 'النوافل', 'الإعدادات'];
            const keys = ['nav-home', 'nav-library', 'nav-nawafil', 'nav-settings'];
            final selected = index == 0;
            final color = selected ? IvoryContrast.gold : IvoryContrast.ink;
            final icon = switch (index) {
              0 => const Icon(Icons.home_rounded),
              1 => const Icon(Icons.auto_stories_outlined),
              2 => const SujoodIcon(size: 29),
              _ => const Icon(Icons.settings_outlined),
            };
            return Expanded(child: Semantics(selected: selected, button: true,
              child: Material(color: selected ? const Color(0xFFF5EACF) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(key: Key(keys[index]), borderRadius: BorderRadius.circular(20),
                  onTap: () => onNavigate(index),
                  child: Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      IconTheme(data: IconThemeData(color: color, size: 28), child: icon),
                      const SizedBox(height: 3),
                      UiText(labels[index], textAlign: TextAlign.center,
                        style: TextStyle(color: color, fontSize: 12, height: 1.4,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
                    ]))))));
          })))));
}
