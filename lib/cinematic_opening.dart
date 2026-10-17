part of 'main.dart';

const wirdSanctuary = AssetImage('assets/brand/wird_sanctuary_20261017.png');

/// A bounded, automatic overlay over the real shell, never a screenshot route.
class WirdStartup extends StatefulWidget {
  const WirdStartup({super.key, required this.ready, required this.child});
  final bool ready;
  final Widget child;
  @override
  State<WirdStartup> createState() => _WirdStartupState();
}

class _WirdStartupState extends State<WirdStartup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _exit;
  Timer? _hold;
  bool _elapsed = false;
  bool _finished = false;
  bool _exiting = false;

  @override
  void initState() {
    super.initState();
    _exit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _hold = Timer(const Duration(milliseconds: 1200), () {
      _elapsed = true;
      _tryExit();
    });
  }

  @override
  void didUpdateWidget(WirdStartup oldWidget) {
    super.didUpdateWidget(oldWidget);
    _tryExit();
  }

  void _tryExit() {
    if (!_elapsed || !widget.ready || _exiting || !mounted) return;
    _exiting = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      setState(() => _finished = true);
      return;
    }
    _exit.forward().then((_) {
      if (mounted) setState(() => _finished = true);
    });
  }

  @override
  void dispose() {
    _hold?.cancel();
    _exit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Mount the functioning home underneath the reveal. Optional services
        // and saved preferences finish before the splash is removed.
        widget.child,
        if (!_finished) FadeTransition(
          opacity: Tween<double>(begin: 1, end: 0).animate(
            CurvedAnimation(parent: _exit, curve: Curves.easeInOutCubic),
          ),
          child: const AbsorbPointer(child: WirdOpening(animate: true)),
        ),
      ],
    );
  }
}

class WirdOpening extends StatelessWidget {
  const WirdOpening({super.key, this.animate = false});
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: openingTeal,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: ColoredBox(
        key: const Key('cinematic-splash'),
        color: openingTeal,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: animate && !reduced ? 0 : 1, end: 1),
          duration: Duration(milliseconds: reduced ? 0 : 1000),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => LayoutBuilder(
            builder: (context, bounds) => Stack(
              fit: StackFit.expand,
              children: [
                RepaintBoundary(
                  child: Transform.scale(
                    scale: 1.018 - value * .018,
                    child: Image(
                      image: wirdSanctuary,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      gaplessPlayback: true,
                      excludeFromSemantics: true,
                      errorBuilder: (_, error, stack) => const ColoredBox(
                        color: openingTeal,
                      ),
                    ),
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x1800242C),
                        Color(0x0000242C),
                        Color(0x2200242C),
                        Color(0x7700242C),
                      ],
                      stops: [0, .4, .65, 1],
                    ),
                  ),
                ),
                Positioned(
                  top: bounds.maxHeight * .49,
                  left: 20,
                  right: 20,
                  child: SafeArea(
                    top: false,
                    child: Opacity(
                      opacity: .35 + .65 * value,
                      child: Transform.scale(
                        scale: .97 + .03 * value,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const WirdMark(size: 124),
                            const SizedBox(height: 14),
                            const Text(
                              'WIRD',
                              textDirection: TextDirection.ltr,
                              style: TextStyle(
                                color: Color(0xFFF6E5BF),
                                fontSize: 16,
                                letterSpacing: 8,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'ذِكْرٌ يُرَافِقُ يَوْمَكَ',
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'NotoSansArabic',
                                color: Color(0xFFF6E5BF),
                                fontSize: 19,
                                height: 1.7,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
