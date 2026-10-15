part of 'main.dart';

/// Both uploaded originals are immutable. The new artwork already has its kasra.
const wirdArtwork = AssetImage('assets/brand/wird_artwork_20261015.png');
const openingIvory = Color(0xFFF3EEDF);

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
        ..moveTo(3, 23)
        ..lineTo(5, 19)
        ..lineTo(9, 21)
        ..lineTo(13, 21)
        ..lineTo(7, 16)
        ..quadraticBezierTo(5, 13, 8, 10)
        ..quadraticBezierTo(11, 7, 14, 10)
        ..lineTo(20, 17),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(16, 14)
        ..lineTo(15, 20)
        ..quadraticBezierTo(15, 23, 18, 23)
        ..lineTo(20, 23),
      p,
    );
    canvas.drawCircle(
      const Offset(23, 20.5),
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

class WirdOpening extends StatelessWidget {
  const WirdOpening({super.key});
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: openingIvory,
    child: LayoutBuilder(
      builder: (context, bounds) => Stack(
        fit: StackFit.expand,
        children: [
          const CustomPaint(painter: _BotanicalPainter()),
          const Center(child: WirdMark(size: 128)),
          Positioned(
            top: bounds.maxHeight / 2 + 88,
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'WIRD',
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    color: Color(0xFF0B3437),
                    fontSize: 13,
                    letterSpacing: 7,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Container(width: 28, height: 1, color: const Color(0xFFB49D63)),
                const SizedBox(height: 16),
                const UiText(
                  'ذِكْرٌ يُرَافِقُ يَوْمَكَ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF355650),
                    fontSize: 14,
                    height: 1.9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// Original vector composition; no competitor art or external stock assets.
class _BotanicalPainter extends CustomPainter {
  const _BotanicalPainter();
  @override
  void paint(Canvas c, Size s) {
    final leaf = Paint()..color = const Color(0xFF6B8068).withOpacity(.07);
    for (final flip in [false, true]) {
      c.save();
      if (flip) {
        c.translate(s.width, 0);
        c.scale(-1, 1);
      }
      final stem = Path()
        ..moveTo(-16, -10)
        ..quadraticBezierTo(
          s.width * .16,
          s.height * .08,
          s.width * .13,
          s.height * .26,
        );
      c.drawPath(
        stem,
        Paint()
          ..color = const Color(0xFF6B8068).withOpacity(.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
      for (var i = 0; i < 5; i++) {
        c.save();
        c.translate(s.width * .09, s.height * (.025 + i * .04));
        c.rotate(i.isEven ? -.7 : .7);
        c.drawPath(
          Path()
            ..moveTo(0, 0)
            ..quadraticBezierTo(35, -28, 58, -6)
            ..quadraticBezierTo(31, 17, 0, 0),
          leaf,
        );
        c.restore();
      }
      c.restore();
    }
    final skyline = Paint()..color = const Color(0xFF315958).withOpacity(.035);
    final base = s.height * .93;
    c.drawRect(Rect.fromLTRB(0, base, s.width, s.height), skyline);
    final dome = Path()
      ..moveTo(s.width * .25, base)
      ..lineTo(s.width * .25, base - 28)
      ..quadraticBezierTo(s.width * .26, base - 60, s.width * .5, base - 106)
      ..quadraticBezierTo(s.width * .74, base - 60, s.width * .75, base - 28)
      ..lineTo(s.width * .75, base)
      ..close();
    c.drawPath(dome, skyline);
    for (final x in [.12, .87]) {
      final center = s.width * x;
      c.drawRect(
        Rect.fromLTRB(center - 8, base - 136, center + 8, base),
        skyline,
      );
      c.drawPath(
        Path()
          ..moveTo(center - 13, base - 136)
          ..lineTo(center, base - 167)
          ..lineTo(center + 13, base - 136)
          ..close(),
        skyline,
      );
    }
  }

  @override
  bool shouldRepaint(_BotanicalPainter old) => false;
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
