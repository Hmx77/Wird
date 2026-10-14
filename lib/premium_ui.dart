part of 'main.dart';

/// Original artwork stays immutable. Only its excess canvas is clipped and the
/// owner-requested single kasra is composed as a separate vector layer.
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * .225),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: Color(0xFF0B3437)),
              Transform.translate(
                offset: Offset(0, size * .016),
                child: Transform.scale(
                  scale: 1.92,
                  child: Image.asset(
                    'assets/brand/wird_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const CustomPaint(painter: _KasraPainter()),
            ],
          ),
        ),
      ),
    ),
  );
}

class _KasraPainter extends CustomPainter {
  const _KasraPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF8F4E6)
      ..strokeWidth = size.width * .016
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * .77, size.height * .87),
      Offset(size.width * .85, size.height * .84),
      paint,
    );
  }

  @override
  bool shouldRepaint(_KasraPainter oldDelegate) => false;
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
    // Bent torso, kneeling legs and forehead resting at ground level.
    canvas.drawPath(
      Path()
        ..moveTo(5, 22)
        ..lineTo(10, 21)
        ..lineTo(8, 14)
        ..quadraticBezierTo(7, 11, 11, 9)
        ..quadraticBezierTo(14, 9, 18, 17)
        ..lineTo(20, 22)
        ..lineTo(15, 22),
      p,
    );
    canvas.drawCircle(const Offset(24, 23), 2, p);
    canvas.drawLine(const Offset(3, 25), const Offset(26, 25), p);
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
    color: const Color(0xFFF3EEDF),
    child: Stack(
      fit: StackFit.expand,
      children: [
        const CustomPaint(painter: _BotanicalPainter()),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const WirdMark(size: 136),
                const SizedBox(height: 24),
                const Text(
                  'W I R D',
                  style: TextStyle(
                    color: Color(0xFF0B3437),
                    fontSize: 14,
                    letterSpacing: 5,
                  ),
                ),
                const SizedBox(height: 24),
                Container(width: 32, height: 1, color: const Color(0xFFB49D63)),
                const SizedBox(height: 24),
                const UiText(
                  'ذِكْرٌ يُرَافِقُ يَوْمَكَ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF355650),
                    fontSize: 16,
                    height: 1.9,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

/// Original vector composition; no competitor art or external stock assets.
class _BotanicalPainter extends CustomPainter {
  const _BotanicalPainter();
  @override
  void paint(Canvas c, Size s) {
    final leaf = Paint()..color = const Color(0xFF6B8068).withOpacity(.21);
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
          ..color = const Color(0xFF6B8068).withOpacity(.3)
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
    final crescent = Paint()..color = const Color(0xFFB49D63).withOpacity(.65);
    c.drawCircle(Offset(s.width * .5, s.height * .15), 17, crescent);
    c.drawCircle(
      Offset(s.width * .5 - 8, s.height * .15 - 5),
      17,
      Paint()..color = const Color(0xFFF3EEDF),
    );
    final skyline = Paint()..color = const Color(0xFF315958).withOpacity(.13);
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
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
            children: [
              Row(
                children: [
                  const WirdMark(size: 68),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const UiText(
                          'وردك اليومي',
                          style: TextStyle(
                            color: cream,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        UiText(
                          'ذِكْرٌ يُرَافِقُ يَوْمَكَ',
                          style: TextStyle(
                            color: cream.withOpacity(.65),
                            fontSize: 11,
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: tr(context, 'ابحث عن ذكر'),
                    onPressed: () => browse(context),
                    icon: const Icon(Icons.search_rounded, color: cream),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: p.homeSurface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: gold.withOpacity(.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.spa_outlined, color: gold, size: 24),
                    const SizedBox(height: 14),
                    const UiText(
                      'لحظات من السكينة',
                      style: TextStyle(
                        color: cream,
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    UiText(
                      'اختر وردك وابدأ القراءة',
                      style: TextStyle(
                        color: cream.withOpacity(.7),
                        fontSize: 13,
                        height: 1.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              ...DhikrSection.values.map((section) {
                final count = inSection(section).length;
                final completed =
                    store.completed(section) == count && count > 0;
                final icon = switch (section) {
                  DhikrSection.morning => Icons.wb_sunny_outlined,
                  DhikrSection.evening => Icons.nightlight_outlined,
                  DhikrSection.sleep => Icons.bedtime_outlined,
                };
                final accent = switch (section) {
                  DhikrSection.morning => gold,
                  DhikrSection.evening => const Color(0xFF87BCB5),
                  DhikrSection.sleep => const Color(0xFFB4A4CD),
                };
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: p.homeSurface,
                    borderRadius: BorderRadius.circular(22),
                    child: InkWell(
                      key: Key('home-${section.name}'),
                      borderRadius: BorderRadius.circular(22),
                      onTap: () => openReader(context, store, section),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: accent.withOpacity(.12),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(icon, color: accent, size: 26),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  UiText(
                                    sectionLabel(section),
                                    style: const TextStyle(
                                      color: cream,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      height: 1.7,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  UiText(
                                    '$count ذكر',
                                    style: TextStyle(
                                      color: cream.withOpacity(.6),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              completed
                                  ? Icons.check_circle_outline
                                  : (Localizations.localeOf(
                                              context,
                                            ).languageCode ==
                                            'ar'
                                        ? Icons.chevron_left
                                        : Icons.chevron_right),
                              color: completed
                                  ? accent
                                  : cream.withOpacity(.55),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => browse(context, favorites: true),
                style: OutlinedButton.styleFrom(
                  foregroundColor: cream,
                  side: BorderSide(color: gold.withOpacity(.3)),
                  padding: const EdgeInsets.all(16),
                ),
                icon: const Icon(Icons.bookmark_border),
                label: const UiText('المفضلة'),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 15,
                    color: cream.withOpacity(.5),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: UiText(
                      'أذكارك محفوظة دون اتصال',
                      style: TextStyle(
                        color: cream.withOpacity(.5),
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
