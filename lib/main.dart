import 'ui_strings.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/reminders.dart';
import 'services/audio_library.dart';
import 'services/widgets.dart';
import 'feature_panels.dart';
import 'share_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'content.dart';
import 'quran_text.dart';
part 'premium_ui.dart';
part 'nawafil_ui.dart';
part 'settings_ui.dart';
part 'reading_ui.dart';
part 'cinematic_opening.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(WirdApp(firstFrameRasterized: WidgetsBinding.instance.waitUntilFirstFrameRasterized));
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['Noto Sans Arabic'], license);
    yield LicenseEntryWithLineBreaks([
      'Tanzil Quran Text 1.1',
    ], quranTextLicense);
  });
}

class WirdPalette {
  const WirdPalette(
    this.name,
    this.background,
    this.card,
    this.primary,
    this.ink, {
    this.dark = false,
  });
  final String name;
  final Color background, card, primary, ink;
  final bool dark;
  // A restrained slate foundation; every theme retains its original identity.
  Color get homeBackground =>
      Color.lerp(const Color(0xFF002C32), primary, .09)!;
  Color get homeSurface => Color.lerp(homeBackground, primary, .065)!;
  Color get homeOutline => const Color(0xFFE3E0D5).withOpacity(.16);
  Color get homeAccent => Color.lerp(primary, const Color(0xFFB5CBC3), .7)!;
}

const themes = <WirdPalette>[
  WirdPalette(
    'Olive & Cream',
    Color(0xFFF8F5ED),
    Color(0xFFE5E7D8),
    Color(0xFF77856A),
    Color(0xFF293E32),
  ),
  WirdPalette(
    'Ocean Blue',
    Color(0xFFF4F8FA),
    Color(0xFFDDECF1),
    Color(0xFF618DA5),
    Color(0xFF1D425A),
  ),
  WirdPalette(
    'Mocha & Sand',
    Color(0xFFFAF6EF),
    Color(0xFFE6D9C8),
    Color(0xFFA8896C),
    Color(0xFF4C3A30),
  ),
  WirdPalette(
    'Soft Lavender',
    Color(0xFFF9F7FC),
    Color(0xFFE9E3F2),
    Color(0xFFA595C5),
    Color(0xFF50466F),
  ),
  WirdPalette(
    'Emerald & Gold',
    Color(0xFFF6F2E8),
    Color(0xFFE8DABC),
    Color(0xFFB49A60),
    Color(0xFF174D42),
  ),
  WirdPalette(
    'Midnight Blue',
    Color(0xFF101B2B),
    Color(0xFF21334A),
    Color(0xFF50748E),
    Color(0xFFE6C796),
    dark: true,
  ),
  WirdPalette(
    'Charcoal & Sage',
    Color(0xFF181F22),
    Color(0xFF293639),
    Color(0xFF728D82),
    Color(0xFFE1E5D7),
    dark: true,
  ),
  WirdPalette(
    'Dusty Rose & Stone',
    Color(0xFFFBF7F4),
    Color(0xFFF1E2DC),
    Color(0xFFBB9289),
    Color(0xFF624C49),
  ),
  WirdPalette(
    'Stone & Teal',
    Color(0xFFF6F7F5),
    Color(0xFFE0E8E7),
    Color(0xFF427C7A),
    Color(0xFF263C40),
  ),
  WirdPalette(
    'Sage & Ivory',
    Color(0xFFF7F5EE),
    Color(0xFFB3C6B5),
    Color(0xFF355E50),
    Color(0xFF263B32),
  ),
];

String dayKey([DateTime? d]) {
  final v = d ?? DateTime.now();
  return '${v.year.toString().padLeft(4, '0')}-${v.month.toString().padLeft(2, '0')}-${v.day.toString().padLeft(2, '0')}';
}

class WirdState extends ChangeNotifier {
  WirdState({DateTime Function()? now}) : _now = now ?? DateTime.now;
  final DateTime Function() _now;
  void refreshDate() {
    notifyListeners();
    unawaited(updateWidget());
  }

  String languageCode = 'ar';
  int themeIndex = 8; // Stone & Teal default
  double fontSize = 25;
  Set<String> favorites = {};
  Map<String, int> counts = {};
  Map<String, int> countTargets = {};
  Map<String, int> countChoices = {};
  Set<String> prayers = {};
  int tasbih = 0;
  SharedPreferences? _prefs;
  bool ready = false;
  bool _disposed = false;
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  bool haptics = true;
  bool autoAdvance = false;
  String? storageError;
  Future<void> _writes = Future.value();
  Future<void> get pendingWrites => _writes;
  void save(Future<bool> Function() write) {
    _writes = _writes.then((_) async {
      try {
        if (!await write()) throw StateError('write');
      } catch (_) {
        storageError = 'تعذر حفظ آخر تغيير؛ تحقق من مساحة الجهاز.';
        notifyListeners();
      }
    });
  }

  void preferences({bool? feedback, bool? advance}) {
    haptics = feedback ?? haptics;
    autoAdvance = advance ?? autoAdvance;
    save(() => _prefs!.setBool('haptics', haptics));
    save(() => _prefs!.setBool('advance', autoAdvance));
    notifyListeners();
  }

  Future<void> updateWidget() async {
    try {
      await WirdWidgets.update(
        dayKey(_now()),
        entries.where((e) => isDone(e)).length,
        entries.length,
        languageCode,
      );
    } catch (_) {
      /* Widget failure must not prevent private reading. */
    }
  }

  Future<void> erase() async {
    await pendingWrites;
    for (final key in [
      'counts',
      'count_targets',
      'count_choices',
      'prayers',
      'favorites',
      'tasbih',
    ]) {
      if (_prefs == null || !await _prefs!.remove(key)) {
        throw StateError('Local deletion failed');
      }
    }
    counts.clear();
    countTargets.clear();
    countChoices.clear();
    prayers.clear();
    favorites.clear();
    tasbih = 0;
    await updateWidget();
    notifyListeners();
  }

  WirdPalette get palette => themes[themeIndex];
  int target(DhikrEntry entry, [String? date]) {
    final today = dayKey(_now());
    final selected =
        countTargets['${date ?? today}|${entry.id}'] ??
        ((date == null || date == today) ? countChoices[entry.id] : null);
    return entry.allowedCounts.contains(selected) ? selected! : entry.count;
  }

  int count(DhikrEntry entry, [String? date]) =>
      (counts['${date ?? dayKey(_now())}|${entry.id}'] ?? 0).clamp(
        0,
        target(entry, date),
      );
  bool isDone(DhikrEntry entry, [String? date]) =>
      count(entry, date) >= target(entry, date);
  int completed(DhikrSection section, [String? date]) =>
      inSection(section).where((e) => isDone(e, date)).length;
  bool prayerDone(String id, [String? date]) =>
      prayers.contains('${date ?? dayKey(_now())}|$id');

  Future<void> initialize() async {
    try {
      await _load();
    } catch (_) {
      storageError =
          'تعذر فتح الحفظ المحلي. يمكنك القراءة؛ قد لا تحفظ التغييرات.';
      ready = true;
      notifyListeners();
    }
  }

  Future<void> _load() async {
    _prefs = await SharedPreferences.getInstance();
    final p = _prefs!;
    languageCode = p.getString('language') == 'en' ? 'en' : 'ar';
    themeIndex = (p.getInt('theme') ?? 8).clamp(0, themes.length - 1);
    fontSize = (p.getDouble('font') ?? 25).clamp(19, 38);
    favorites = p.getStringList('favorites')?.toSet() ?? {};
    prayers = p.getStringList('prayers')?.toSet() ?? {};
    tasbih = (p.getInt('tasbih') ?? 0).clamp(0, 1000000000);
    haptics = p.getBool('haptics') ?? true;
    autoAdvance = p.getBool('advance') ?? false;
    try {
      final raw =
          jsonDecode(p.getString('counts') ?? '{}') as Map<String, dynamic>;
      counts = raw.map(
        (key, value) => MapEntry(key, (value as num).toInt().clamp(0, 1000000)),
      );
    } catch (_) {
      counts = {};
    }
    Map<String, int> readTargets(String key) {
      try {
        final raw =
            jsonDecode(p.getString(key) ?? '{}') as Map<String, dynamic>;
        return raw.map((key, value) => MapEntry(key, (value as num).toInt()));
      } catch (_) {
        return {};
      }
    }

    countTargets = readTargets('count_targets');
    countChoices = readTargets('count_choices');
    ready = true;
    notifyListeners();
    unawaited(updateWidget());
  }

  void changeLanguage(String code) {
    languageCode = code == 'en' ? 'en' : 'ar';
    final saved = languageCode;
    save(() => _prefs!.setString('language', saved));
    notifyListeners();
    unawaited(updateWidget());
    unawaited(pendingWrites.then((_) => ReminderPanel.reschedule()));
  }

  void changeTheme(int idx) {
    themeIndex = idx.clamp(0, themes.length - 1);
    save(() => _prefs!.setInt('theme', themeIndex));
    notifyListeners();
  }

  void changeFont(double value) {
    fontSize = value.clamp(19, 38);
    save(() => _prefs!.setDouble('font', fontSize));
    notifyListeners();
  }

  void toggleFavorite(String id) {
    if (!favorites.add(id)) favorites.remove(id);
    final saved = favorites.toList();
    save(() => _prefs!.setStringList('favorites', saved));
    notifyListeners();
  }

  void setCount(DhikrEntry e, int value) {
    if (!entries.contains(e)) return;
    final key = '${dayKey(_now())}|${e.id}';
    final selected = target(e);
    countTargets[key] = selected;
    counts[key] = value.clamp(0, selected);
    final saved = jsonEncode(counts);
    final savedTargets = jsonEncode(countTargets);
    save(() => _prefs!.setString('counts', saved));
    save(() => _prefs!.setString('count_targets', savedTargets));
    notifyListeners();
    if (haptics) unawaited(HapticFeedback.selectionClick());
    unawaited(updateWidget());
  }

  void chooseCount(DhikrEntry e, int selected) {
    if (!entries.contains(e) ||
        !e.allowedCounts.contains(selected) ||
        selected == target(e))
      return;
    countChoices[e.id] = selected;
    countTargets['${dayKey(_now())}|${e.id}'] = selected;
    final savedChoices = jsonEncode(countChoices);
    save(() => _prefs!.setString('count_choices', savedChoices));
    // Counts for another target cannot silently become completed repetitions.
    // Historical targets remain attached to their original local dates.
    setCount(e, 0);
  }

  void togglePrayer(String id) {
    final key = '${dayKey(_now())}|$id';
    if (!prayers.add(key)) prayers.remove(key);
    final saved = prayers.toList();
    save(() => _prefs!.setStringList('prayers', saved));
    notifyListeners();
  }

  void setTasbih(int value) {
    tasbih = value < 0 ? 0 : value;
    save(() => _prefs!.setInt('tasbih', tasbih));
    notifyListeners();
  }
}

/// Shared by the running app and visual regression captures.
ThemeData wirdTheme(WirdPalette p) => ThemeData(
  useMaterial3: true,
  fontFamily: 'NotoSansArabic',
  navigationBarTheme: NavigationBarThemeData(
    height: 76,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    backgroundColor: p.homeBackground,
    labelTextStyle: const WidgetStatePropertyAll(
      TextStyle(color: Color(0xFFF3EEDF), fontSize: 12),
    ),
    iconTheme: const WidgetStatePropertyAll(
      IconThemeData(color: Color(0xFFF3EEDF)),
    ),
  ),
  brightness: p.dark ? Brightness.dark : Brightness.light,
  scaffoldBackgroundColor: p.background,
  colorScheme: ColorScheme.fromSeed(
    seedColor: p.primary,
    brightness: p.dark ? Brightness.dark : Brightness.light,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: p.background,
    foregroundColor: p.ink,
    elevation: 0,
  ),
);

class WirdApp extends StatefulWidget {
  const WirdApp({super.key, this.firstFrameRasterized});
  final Future<void>? firstFrameRasterized;
  @override
  State<WirdApp> createState() => _WirdAppState();
}

class _WirdAppState extends State<WirdApp> with WidgetsBindingObserver {
  final WirdState store = WirdState();
  Timer? clock;
  String currentDay = dayKey();
  bool servicesReady = false;
  bool firstFrameReady = false;
  bool started = false;
  @override
  void initState() {
    super.initState();
    firstFrameReady = widget.firstFrameRasterized == null;
    widget.firstFrameRasterized?.then((_) {
      if (mounted) setState(() => firstFrameReady = true);
    });
    WidgetsBinding.instance.addObserver(this);
    clock = Timer.periodic(const Duration(seconds: 30), (_) => refreshDay());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (started) return;
    started = true;
    // Decode the scene before the first Flutter frame; keep native startup dark.
    WidgetsBinding.instance.deferFirstFrame();
    unawaited(prepareOpening());
  }

  Future<void> prepareOpening() async {
    // Start the existing local Home art in parallel with the approved opening.
    // Its ready flag must not reveal an unillustrated Home while decoding.
    final homeArtworkReady = Future.wait<void>(
      homeArt.values.map((image) => precacheImage(image, context)),
    );
    try {
      await Future.wait([
        precacheImage(wirdWordmark, context),
        precacheImage(wirdSanctuary, context),
      ]).timeout(const Duration(seconds: 2));
    } catch (_) {
      // The dark fallback and original logo remain usable if image decoding fails.
    } finally {
      WidgetsBinding.instance.allowFirstFrame();
    }
    await Future.wait([
      store.initialize(),
      Reminders.instance.initialize(),
      AudioLibrary.instance.load(),
      homeArtworkReady.then<void>((_) {}),
    ]);
    if (mounted) setState(() => servicesReady = true);
  }

  void refreshDay() {
    if (currentDay != dayKey()) {
      currentDay = dayKey();
      store.refreshDate();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshDay();
      ReminderPanel.reschedule();
    }
  }

  @override
  void dispose() {
    clock?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (context, _) {
      final p = store.palette;
      return MaterialApp(
        title: 'ورد — Wird',
        debugShowCheckedModeBanner: false,
        locale: Locale(store.languageCode),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: wirdTheme(p),
        home: WirdStartup(
          ready: store.ready && servicesReady && firstFrameReady,
          child: store.ready && servicesReady
              ? WirdShell(store: store)
              : const ColoredBox(color: openingTeal),
        ),
      );
    },
  );
}

class WirdShell extends StatefulWidget {
  const WirdShell({super.key, required this.store});
  final WirdState store;
  @override
  State<WirdShell> createState() => _WirdShellState();
}

class _WirdShellState extends State<WirdShell> {
  int page = 0;
  @override
  void initState() {
    super.initState();
    Reminders.instance.onOpen = openNotification;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final payload = Reminders.instance.initialPayload;
      if (payload != null) {
        Reminders.instance.initialPayload = null;
        openNotification(payload);
      }
    });
  }

  void openNotification(String payload) {
    if (!mounted) return;
    for (final section in DhikrSection.values) {
      if (section.name == payload) {
        openReader(context, widget.store, section);
        break;
      }
    }
  }

  @override
  void dispose() {
    Reminders.instance.onOpen = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final p = store.palette;
    final screens = [
      HomePage(store: store, onNavigate: (index) => setState(() => page = index)),
      LibraryPage(store: store),
      NawafilPage(store: store),
      DeferredSettingsPage(store: store, active: page == 3),
    ];
    final darkSurface = page == 0 || page == 1 || page == 2 || page == 3 || p.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: darkSurface
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: darkSurface ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: p.homeBackground,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: p.homeBackground,
        body: SafeArea(
          child: IndexedStack(index: page, children: screens),
        ),
        bottomNavigationBar: Container(
          margin: const EdgeInsets.fromLTRB(10, 4, 10, 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(29),
            border: Border.all(color: p.homeAccent.withOpacity(.3)),
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [p.homeSurface, p.homeBackground]),
          ),
          child: ClipRRect(borderRadius: BorderRadius.circular(29), child: NavigationBar(
          selectedIndex: page,
          onDestinationSelected: (index) => setState(() => page = index),
          backgroundColor: Colors.transparent,
          indicatorColor: const Color(0xFFE4C47E).withOpacity(.18),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              key: const Key('nav-home'),
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded, color: homeGold),
              label: tr(context, 'الرئيسية'),
            ),
            NavigationDestination(
              key: const Key('nav-library'),
              icon: const Icon(Icons.auto_stories_outlined),
              selectedIcon: const Icon(Icons.auto_stories_outlined),
              label: tr(context, 'الأذكار'),
            ),
            NavigationDestination(
              key: const Key('nav-nawafil'),
              icon: const SujoodIcon(),
              selectedIcon: const IconTheme(data: IconThemeData(color: homeGold), child: SujoodIcon(selected: true)),
              label: tr(context, 'النوافل'),
            ),
            NavigationDestination(
              key: const Key('nav-settings'),
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings, color: homeGold),
              label: tr(context, 'الإعدادات'),
            ),
          ],
        )),
        ),
      ),
    );
  }
}

void openReader(
  BuildContext context,
  WirdState store,
  DhikrSection section, {
  int initial = 0,
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          ReaderPage(store: store, section: section, initialIndex: initial),
    ),
  );
}

class Header extends StatelessWidget {
  const Header(this.title, {super.key, this.subtitle});
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) {
    final p = ThemeColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UiText(
            title,
            style: TextStyle(
              color: p.ink,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 5),
            UiText(
              subtitle!,
              style: TextStyle(color: p.ink.withOpacity(.65), fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

/// Read the currently active palette from the nearest MaterialApp's color scheme.
/// Palette inherited color choices are resolved by a thin holder below.
class ThemeColors {
  static WirdPalette of(BuildContext context) {
    final root = context.findAncestorWidgetOfExactType<WirdShell>();
    if (root != null) return root.store.palette;
    final library = context.findAncestorWidgetOfExactType<LibraryPage>();
    if (library != null) return library.store.palette;
    final reader = context.findAncestorWidgetOfExactType<ReaderPage>();
    return reader?.store.palette ?? themes[8];
  }
}

class Surface extends StatelessWidget {
  const Surface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
  });
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: color ?? ThemeColors.of(context).card,
      borderRadius: BorderRadius.circular(22),
    ),
    padding: padding,
    child: child,
  );
}

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key, required this.store});
  final WirdState store;
  @override
  Widget build(BuildContext context) {
    final p = store.palette;
    return ListView(
      padding: const EdgeInsets.only(bottom: 25),
      children: [
        const Header(
          'متابعتي',
          subtitle: 'محفوظة على جهازك فقط — تسجيل نشاط لا قياس للأجر',
        ),
        ProgressCalendar(store: store),
        ...DhikrSection.values.map((section) {
          final total = inSection(section).length;
          final complete = store.completed(section);
          return Padding(
            padding: const EdgeInsets.fromLTRB(19, 0, 19, 11),
            child: Surface(
              child: Column(
                children: [
                  Row(
                    children: [
                      UiText(
                        sectionLabel(section),
                        style: TextStyle(
                          color: p.ink,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      UiText(
                        '$complete / $total',
                        style: TextStyle(color: p.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: total == 0 ? 0 : complete / total,
                    color: p.primary,
                    backgroundColor: p.background,
                    minHeight: 7,
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 19),
          child: Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UiText(
                  'آخر سبعة أيام',
                  style: TextStyle(
                    color: p.ink,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 14),
                ...List.generate(7, (i) {
                  final date = dayKey(
                    DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day - i,
                    ),
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Row(
                      children: [
                        UiText(
                          date,
                          style: TextStyle(color: p.ink, fontSize: 12),
                        ),
                        const Spacer(),
                        ...DhikrSection.values.map((section) {
                          final total = inSection(section).length;
                          final checked =
                              total > 0 &&
                              store.completed(section, date) == total;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(
                              checked
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: checked
                                  ? p.primary
                                  : p.ink.withOpacity(.28),
                              size: 18,
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
                UiText(
                  'الدلالات: الصباح • المساء • النوم',
                  style: TextStyle(color: p.ink.withOpacity(.6), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

