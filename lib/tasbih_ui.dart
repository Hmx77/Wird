part of 'main.dart';

/// Standalone personal tool. Uses the existing Tasbih preference and no targets.
class PersonalTasbihPage extends StatefulWidget {
  const PersonalTasbihPage({super.key, required this.store});
  final WirdState store;
  @override
  State<PersonalTasbihPage> createState() => _PersonalTasbihPageState();
}

class _PersonalTasbihPageState extends State<PersonalTasbihPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 300),
  );
  bool _resetOpen = false;
  bool get _still =>
      MediaQuery.disableAnimationsOf(context) ||
      MediaQuery.accessibleNavigationOf(context);
  String _label(String ar, String en) =>
      widget.store.languageCode == 'en' ? en : ar;
  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _increment() {
    widget.store.setTasbih(widget.store.tasbih + 1);
    if (widget.store.haptics) unawaited(HapticFeedback.selectionClick());
    if (!_still) _pulse.forward(from: 0);
  }

  Future<void> _reset() async {
    if (_resetOpen || widget.store.tasbih == 0) return;
    if (widget.store.tasbih >= 100) {
      _resetOpen = true;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          backgroundColor: widget.store.palette.homeSurface,
          titleTextStyle: TextStyle(
            color: AppAppearance.of(context).ink,
            fontFamily: 'NotoSansArabic',
            fontSize: 21,
          ),
          contentTextStyle: TextStyle(
            color: AppAppearance.of(context).ink,
            fontFamily: 'NotoSansArabic',
            height: 1.8,
          ),
          title: Text(_label('إعادة العداد؟', 'Reset personal counter?')),
          content: Text(
            _label(
              'سيُصفّر عداد السبحة الشخصية فقط. لا تتغير الأذكار أو المفضلة أو الإعدادات.',
              'Only your personal Tasbih count will be reset. Athkar progress, favorites and preferences are kept.',
            ),
          ),
          actions: [
            TextButton(
              key: Key('tasbih-reset-cancel'),
              onPressed: () => Navigator.pop(dialog, false),
              child: UiText(
                'إلغاء',
                style: TextStyle(color: AppAppearance.of(context).ink),
              ),
            ),
            TextButton(
              key: Key('tasbih-reset-confirm'),
              onPressed: () => Navigator.pop(dialog, true),
              child: UiText(
                'إعادة',
                style: TextStyle(color: AppAppearance.of(context).gold),
              ),
            ),
          ],
        ),
      );
      _resetOpen = false;
      if (!mounted || confirmed != true) return;
    }
    widget.store.setTasbih(0);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.store,
    builder: (context, _) {
      final store = widget.store;
      final base = !store.palette.dark
          ? store.palette.homeBackground
          : Color.lerp(
              appearanceTone(context, 0xFF031C1B),
              store.palette.primary,
              .045,
            )!;
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value:
            (store.palette.dark
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.dark)
                .copyWith(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: base,
                ),
        child: Scaffold(
          backgroundColor: base,
          body: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: RepaintBoundary(
                    child: CustomPaint(painter: _TasbihAtmosphere(base: base)),
                  ),
                ),
              ),
              Positioned(
                top: -20,
                left: -30,
                width: 180,
                height: 310,
                child: _TasbihFoliage(),
              ),
              Positioned(
                right: -38,
                bottom: 85,
                width: 155,
                height: 290,
                child: Transform.rotate(
                  angle: 3.141592653589793,
                  child: _TasbihFoliage(),
                ),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, bounds) {
                    final diameter = (bounds.maxWidth * .65).clamp(
                      200.0,
                      330.0,
                    );
                    final gap = (bounds.maxHeight * .065).clamp(22.0, 56.0);
                    return SingleChildScrollView(
                      key: Key('tasbih-scroll'),
                      padding: EdgeInsets.fromLTRB(24, 14, 24, 24),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: (bounds.maxHeight - 38).clamp(
                            0.0,
                            double.infinity,
                          ),
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 520),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    BackButton(
                                      key: Key('tasbih-back'),
                                      color: AppAppearance.of(context).gold,
                                      onPressed: () =>
                                          Navigator.maybePop(context),
                                    ),
                                    Expanded(
                                      child: UiText(
                                        'السبحة الشخصية',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppAppearance.of(context).ink,
                                          fontSize: 23,
                                          fontWeight: FontWeight.w500,
                                          height: 1.6,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 48),
                                  ],
                                ),
                                SizedBox(height: gap),
                                _TasbihOrnament(),
                                SizedBox(height: 22),
                                AnimatedBuilder(
                                  animation: _pulse,
                                  builder: (context, _) {
                                    final glow = _still
                                        ? 0.0
                                        : (1 - _pulse.value) *
                                              (_pulse.isAnimating ? 1 : 0);
                                    return Transform.scale(
                                      scale: 1 - glow * .012,
                                      child: Semantics(
                                        label: _label(
                                          'عداد السبحة الشخصية',
                                          'Personal Tasbih count',
                                        ),
                                        value: '${store.tasbih}',
                                        liveRegion: true,
                                        child: ExcludeSemantics(
                                          child: Container(
                                            key: Key('tasbih-circle'),
                                            width: diameter,
                                            height: diameter,
                                            padding: EdgeInsets.all(2.5),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  appearanceTone(
                                                    context,
                                                    0xFFFFE7AC,
                                                  ),
                                                  appearanceTone(
                                                    context,
                                                    0xFFA1824C,
                                                  ),
                                                  appearanceTone(
                                                    context,
                                                    0xFFDEC38D,
                                                  ),
                                                  appearanceTone(
                                                    context,
                                                    0xFFFFE5A1,
                                                  ),
                                                ],
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color:
                                                      AppAppearance.of(
                                                        context,
                                                      ).gold.withValues(
                                                        alpha: .12 + glow * .14,
                                                      ),
                                                  blurRadius: 28 + glow * 10,
                                                  spreadRadius: 1,
                                                ),
                                              ],
                                            ),
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Color(0xFF122D27),
                                                  width: 3,
                                                ),
                                                gradient: RadialGradient(
                                                  center: Alignment(-.55, -.7),
                                                  radius: 1.3,
                                                  colors: [
                                                    Color.lerp(
                                                      base,
                                                      store.palette.primary,
                                                      .32,
                                                    )!,
                                                    base,
                                                  ],
                                                ),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 22,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      height: diameter * .12,
                                                    ),
                                                    Flexible(
                                                      child: FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: AnimatedSwitcher(
                                                          duration: _still
                                                              ? Duration.zero
                                                              : Duration(
                                                                  milliseconds:
                                                                      140,
                                                                ),
                                                          transitionBuilder:
                                                              (
                                                                child,
                                                                animation,
                                                              ) => FadeTransition(
                                                                opacity:
                                                                    animation,
                                                                child: child,
                                                              ),
                                                          child: KeyedSubtree(
                                                            key: ValueKey(
                                                              store.tasbih,
                                                            ),
                                                            child: Text(
                                                              '${store.tasbih}',
                                                              key: Key(
                                                                'home-tasbih-count',
                                                              ),
                                                              style: TextStyle(
                                                                color:
                                                                    AppAppearance.of(
                                                                      context,
                                                                    ).ink,
                                                                fontSize:
                                                                    diameter *
                                                                    .40,
                                                                fontFamily:
                                                                    'NotoSansArabic',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                height: 1.35,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    _TasbihOrnament(
                                                      lines: true,
                                                    ),
                                                    SizedBox(
                                                      height: diameter * .1,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: gap * .85),
                                SizedBox(
                                  width: diameter,
                                  child: _TasbihPill(
                                    controlKey: Key('home-tasbih-add'),
                                    prominent: true,
                                    onPressed: _increment,
                                    child: UiText(
                                      'تسبيح +',
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 18),
                                SizedBox(
                                  width: 154,
                                  child: _TasbihPill(
                                    controlKey: Key('tasbih-reset'),
                                    onPressed: _reset,
                                    child: UiText(
                                      'إعادة',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 28),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Icon(
                                        Icons.info_outline_rounded,
                                        color: AppAppearance.of(context).gold,
                                        size: 19,
                                      ),
                                    ),
                                    SizedBox(width: 9),
                                    Flexible(
                                      child: UiText(
                                        'هدف شخصي، وليس عددًا تعبديًا منصوصًا.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppAppearance.of(
                                            context,
                                          ).ink.withValues(alpha: .8),
                                          fontSize: 13,
                                          height: 1.9,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (store.storageError != null)
                                  Padding(
                                    padding: EdgeInsets.only(top: 16),
                                    child: Semantics(
                                      liveRegion: true,
                                      child: UiText(
                                        store.storageError!,
                                        style: TextStyle(
                                          color: AppAppearance.of(context).ink,
                                        ),
                                      ),
                                    ),
                                  ),
                                SizedBox(height: gap * .5),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _TasbihPill extends StatelessWidget {
  const _TasbihPill({
    required this.controlKey,
    required this.onPressed,
    required this.child,
    this.prominent = false,
  });
  final Key controlKey;
  final VoidCallback onPressed;
  final Widget child;
  final bool prominent;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(60),
      gradient: prominent
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                appearanceTone(context, 0xFF3F6651),
                appearanceTone(context, 0xFF123C31),
                appearanceTone(context, 0xFF082924),
              ],
              stops: [0, .35, 1],
            )
          : null,
      boxShadow: prominent
          ? [
              BoxShadow(
                color: AppAppearance.of(context).gold.withValues(alpha: .10),
                blurRadius: 18,
              ),
            ]
          : null,
    ),
    child: OutlinedButton(
      key: controlKey,
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppAppearance.of(context).ink,
        backgroundColor: prominent
            ? Colors.transparent
            : appearanceTone(context, 0xFF092724),
        side: BorderSide(
          color: AppAppearance.of(context).dark
              ? AppAppearance.of(
                  context,
                ).gold.withValues(alpha: prominent ? .9 : .55)
              : IvoryContrast.outline,
          width: prominent ? 1.7 : 1,
        ),
        shape: StadiumBorder(),
        minimumSize: Size(48, prominent ? 64 : 48),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: child,
    ),
  );
}

class _TasbihOrnament extends StatelessWidget {
  const _TasbihOrnament({this.lines = false});
  final bool lines;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (lines)
          Container(
            width: 22,
            height: 1,
            color: AppAppearance.of(context).gold.withValues(alpha: .6),
          ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 9),
          child: SizedBox(
            width: 16,
            height: 16,
            child: CustomPaint(painter: _TasbihDiamondPainter()),
          ),
        ),
        if (lines)
          Container(
            width: 22,
            height: 1,
            color: AppAppearance.of(context).gold.withValues(alpha: .6),
          ),
      ],
    ),
  );
}

/// Vector decoration: offline, no reference screenshot or scenic mosque blocks.
class _TasbihAtmosphere extends CustomPainter {
  const _TasbihAtmosphere({required this.base});
  final Color base;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.8, -.75),
          radius: 1.3,
          colors: [Color.lerp(base, homeGold, .13)!, base],
        ).createShader(rect),
    );
    final line = Paint()
      ..color = homeGold.withValues(alpha: .085)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final inset in [0.0, 9.0]) {
      final left = size.width * .1 + inset, right = size.width * .9 - inset;
      final arch = Path()
        ..moveTo(left, size.height)
        ..lineTo(left, size.height * .24)
        ..cubicTo(
          left,
          size.height * .16,
          size.width * .42,
          size.height * .15,
          size.width * .5,
          size.height * .09,
        )
        ..cubicTo(
          size.width * .58,
          size.height * .15,
          right,
          size.height * .16,
          right,
          size.height * .24,
        )
        ..lineTo(right, size.height);
      canvas.drawPath(arch, line);
    }
  }

  @override
  bool shouldRepaint(_TasbihAtmosphere oldDelegate) => base != oldDelegate.base;
}

/// Reuses the owned optimized botanical artwork, cropped to edge foliage only.
class _TasbihFoliage extends StatelessWidget {
  const _TasbihFoliage();
  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: RepaintBoundary(
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.white,
              Colors.white,
              Colors.transparent,
            ],
            stops: [0, .12, .28, 1],
          ).createShader(rect),
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (rect) => LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.transparent,
                Colors.white,
                Colors.white,
                Colors.transparent,
              ],
              stops: [0, .12, .28, 1],
            ).createShader(rect),
            child: Opacity(
              opacity: .56,
              child: Image.asset(
                botanicalAsset(context),
                fit: BoxFit.cover,
                alignment: Alignment.topLeft,
                cacheWidth: 720,
                excludeFromSemantics: true,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Four filled diamonds; no dependency on font coverage or fallback glyphs.
class _TasbihDiamondPainter extends CustomPainter {
  const _TasbihDiamondPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = homeGold;
    final r = size.width * .17;
    for (final point in const [
      Offset(.5, .18),
      Offset(.18, .5),
      Offset(.82, .5),
      Offset(.5, .82),
    ]) {
      final x = point.dx * size.width, y = point.dy * size.height;
      canvas.drawPath(
        Path()
          ..moveTo(x, y - r)
          ..lineTo(x + r, y)
          ..lineTo(x, y + r)
          ..lineTo(x - r, y)
          ..close(),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_TasbihDiamondPainter oldDelegate) => false;
}
