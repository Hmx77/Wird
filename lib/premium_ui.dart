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

class SujoodIcon extends StatelessWidget {
  const SujoodIcon({super.key, this.selected = false});
  final bool selected;
  @override
  Widget build(BuildContext context) => SizedBox.square(
    key: const Key('sujood-navigation-icon'),
    dimension: 26,
    child: CustomPaint(
      painter: _SujoodPainter(
        IconTheme.of(context).color ?? ThemeColors.of(context).ink,
        selected,
      ),
    ),
  );
}

class _SujoodPainter extends CustomPainter {
  const _SujoodPainter(this.color, this.selected);
  final Color color;
  final bool selected;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 28, size.height / 28);
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = selected ? 2.5 : 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    // Original side-view: tucked feet at left, bent knees, rounded back,
    // forearms and hands on the ground, forehead touching the prayer mat.
    canvas.drawPath(
      Path()
        ..moveTo(3, 25)
        ..lineTo(5, 21)
        ..lineTo(9, 24)
        ..lineTo(13, 24)
        ..lineTo(7, 16)
        ..quadraticBezierTo(5, 13, 8, 10)
        ..quadraticBezierTo(11, 7, 14, 10)
        ..lineTo(20, 17)
        ..lineTo(22, 21),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(16, 14)
        ..lineTo(15, 20)
        ..quadraticBezierTo(15, 25, 18, 25)
        ..lineTo(20, 25),
      p,
    );
    canvas.drawCircle(
      const Offset(23, 23.5),
      2.5,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    canvas.drawLine(
      const Offset(2, 26),
      const Offset(26, 26),
      p
        ..strokeWidth = 1
        ..color = color.withOpacity(.45),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SujoodPainter old) =>
      old.color != color || old.selected != selected;
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.store});
  final WirdState store;
  void browse(BuildContext context, {bool favorites = false}) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: UiText(favorites ? 'المفضلة' : 'الأذكار')),
        body: SafeArea(
          child: LibraryPage(store: store, initialFavorites: favorites),
        ),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final p = store.palette;
    const cream = Color(0xFFF3EEDF);
    const gold = Color(0xFFB49D63);
    return ColoredBox(
      color: p.homeBackground,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
            children: [
              Row(
                children: [
                  const WirdMark(size: 46),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const UiText(
                          'وردك اليومي',
                          style: TextStyle(
                            color: cream,
                            fontSize: 19,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        UiText(
                          'ذِكْرٌ يُرَافِقُ يَوْمَكَ',
                          style: TextStyle(
                            color: cream.withOpacity(.62),
                            fontSize: 11,
                            height: 1.9,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.outlined(
                    tooltip: tr(context, 'ابحث عن ذكر'),
                    style: IconButton.styleFrom(
                      foregroundColor: cream,
                      side: BorderSide(color: p.homeOutline),
                    ),
                    onPressed: () => browse(context),
                    icon: const Icon(Icons.search_rounded, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 34),
              const UiText(
                'الأذكار',
                style: TextStyle(
                  color: cream,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  height: 1.8,
                ),
              ),
              UiText(
                'اختر وردك وابدأ القراءة',
                style: TextStyle(
                  color: cream.withOpacity(.65),
                  fontSize: 12,
                  height: 1.9,
                ),
              ),
              const SizedBox(height: 22),
              // Content-height cards retain their full labels at large text.
              // Three equal rows avoid an unbalanced empty fourth grid cell.
              ...DhikrSection.values.map((section) {
                final count = inSection(section).length;
                final done = store.completed(section);
                final icon = switch (section) {
                  DhikrSection.morning => Icons.wb_sunny_outlined,
                  DhikrSection.evening => Icons.nightlight_outlined,
                  DhikrSection.sleep => Icons.bedtime_outlined,
                };
                final accent = switch (section) {
                  DhikrSection.morning => gold,
                  DhikrSection.evening => p.homeAccent,
                  DhikrSection.sleep => const Color(0xFFB8ACC3),
                };
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: p.homeSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(color: p.homeOutline),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      key: Key('home-${section.name}'),
                      onTap: () => openReader(context, store, section),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 20,
                        ),
                        child: Row(
                          children: [
                            Icon(icon, color: accent, size: 25),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  UiText(
                                    sectionLabel(section),
                                    style: const TextStyle(
                                      color: cream,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                      height: 1.8,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  UiText(
                                    '$count ذكر',
                                    style: TextStyle(
                                      color: cream.withOpacity(.63),
                                      fontSize: 11,
                                    ),
                                  ),
                                  if (done > 0) ...[
                                    const SizedBox(height: 10),
                                    LinearProgressIndicator(
                                      value: done / count,
                                      minHeight: 2,
                                      color: accent,
                                      backgroundColor: cream.withOpacity(.07),
                                      semanticsLabel: tr(
                                        context,
                                        sectionLabel(section),
                                      ),
                                      semanticsValue: '$done / $count',
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              done == count
                                  ? Icons.check_circle_outline
                                  : (Directionality.of(context) ==
                                            TextDirection.rtl
                                        ? Icons.chevron_left
                                        : Icons.chevron_right),
                              size: 20,
                              color: cream.withOpacity(.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => browse(context, favorites: true),
                style: OutlinedButton.styleFrom(
                  foregroundColor: cream.withOpacity(.85),
                  side: BorderSide(color: p.homeOutline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: const Size(48, 52),
                ),
                icon: const Icon(Icons.bookmark_border_rounded, size: 20),
                label: const UiText('المفضلة'),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 14,
                    color: cream.withOpacity(.55),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: UiText(
                      'أذكارك محفوظة دون اتصال',
                      style: TextStyle(
                        color: cream.withOpacity(.55),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

