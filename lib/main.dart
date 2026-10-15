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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WirdApp());
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
      Color.lerp(const Color(0xFF303A3F), primary, .07)!;
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

class WirdApp extends StatefulWidget {
  const WirdApp({super.key});
  @override
  State<WirdApp> createState() => _WirdAppState();
}

class _WirdAppState extends State<WirdApp> with WidgetsBindingObserver {
  final WirdState store = WirdState();
  Timer? clock;
  String currentDay = dayKey();
  bool servicesReady = false;
  bool started = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    clock = Timer.periodic(const Duration(seconds: 30), (_) => refreshDay());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (started) return;
    started = true;
    // Hold the matching native launch surface only until the complete logo is
    // decoded. No animation timer or minimum splash duration is introduced.
    WidgetsBinding.instance.deferFirstFrame();
    unawaited(prepareOpening());
  }

  Future<void> prepareOpening() async {
    try {
      await precacheImage(wirdArtwork, context);
    } finally {
      WidgetsBinding.instance.allowFirstFrame();
    }
    await Future.wait([
      store.initialize(),
      Reminders.instance.initialize(),
      AudioLibrary.instance.load(),
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
        theme: ThemeData(
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
        ),
        home: store.ready && servicesReady
            ? WirdShell(store: store)
            : const Scaffold(body: Center(child: WirdOpening())),
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
      HomePage(store: store),
      LibraryPage(store: store),
      NawafilPage(store: store),
      SettingsPage(store: store),
    ];
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: page, children: screens),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: page,
        onDestinationSelected: (index) => setState(() => page = index),
        backgroundColor: p.homeBackground,
        indicatorColor: p.homeAccent.withOpacity(.12),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_outlined),
            label: tr(context, 'الرئيسية'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.auto_stories_outlined),
            selectedIcon: const Icon(Icons.auto_stories_outlined),
            label: tr(context, 'الأذكار'),
          ),
          NavigationDestination(
            icon: const SujoodIcon(),
            selectedIcon: const SujoodIcon(selected: true),
            label: tr(context, 'النوافل'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.tune_outlined),
            selectedIcon: const Icon(Icons.tune),
            label: tr(context, 'الإعدادات'),
          ),
        ],
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

class LibraryPage extends StatefulWidget {
  const LibraryPage({
    super.key,
    required this.store,
    this.initialFavorites = false,
  });
  final bool initialFavorites;
  final WirdState store;
  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  String query = '';
  late bool favoriteOnly = widget.initialFavorites;
  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final p = store.palette;
    final filtered = entries
        .where(
          (e) =>
              (!favoriteOnly || store.favorites.contains(e.id)) &&
              normalizeArabic(
                '${e.title} ${e.arabic} ${sectionLabel(e.section)} ${uiString(sectionLabel(e.section), 'en')} ${e.source}',
              ).contains(normalizeArabic(query)),
        )
        .toList();
    return Column(
      children: [
        const Header('الأذكار', subtitle: 'ابحث واقرأ واحفظ أذكارك المفضلة'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 19),
          child: TextField(
            textDirection: Directionality.of(context),
            onChanged: (value) => setState(() => query = value.trim()),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: tr(context, 'ابحث عن ذكر'),
              filled: true,
              fillColor: p.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              FilterChip(
                label: const UiText('المفضلة'),
                selected: favoriteOnly,
                onSelected: (v) => setState(() => favoriteOnly = v),
              ),
              const SizedBox(width: 8),
              UiText(
                '${filtered.length} ذكر',
                style: TextStyle(color: p.ink.withOpacity(.7)),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: UiText(
                    'لا توجد نتائج',
                    style: TextStyle(color: p.ink),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 19),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final e = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: InkWell(
                        onTap: () => openReader(
                          context,
                          store,
                          e.section,
                          initial: inSection(
                            e.section,
                          ).indexWhere((x) => x.id == e.id),
                        ),
                        child: Surface(
                          child: Row(
                            children: [
                              Icon(
                                e.isQuran
                                    ? Icons.menu_book_outlined
                                    : Icons.auto_stories_outlined,
                                color: p.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    UiText(
                                      e.title,
                                      style: TextStyle(
                                        color: p.ink,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    UiText(
                                      '${sectionLabel(e.section)} • ${e.source}',
                                      style: TextStyle(
                                        color: p.ink.withOpacity(.65),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => store.toggleFavorite(e.id),
                                icon: Icon(
                                  store.favorites.contains(e.id)
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: p.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class ReaderPage extends StatefulWidget {
  const ReaderPage({
    super.key,
    required this.store,
    required this.section,
    this.initialIndex = 0,
  });
  final WirdState store;
  final DhikrSection section;
  final int initialIndex;
  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  late int index;
  bool expanded = false;
  bool focus = false;
  @override
  void initState() {
    super.initState();
    index = widget.initialIndex.clamp(
      0,
      inSection(widget.section).isNotEmpty
          ? inSection(widget.section).length - 1
          : 0,
    );
    widget.store.addListener(refresh);
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.store.removeListener(refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.store.palette;
    final sectionEntries = inSection(widget.section);
    if (sectionEntries.isEmpty)
      return const Scaffold(body: Center(child: UiText('لا توجد أذكار بعد')));
    final e = sectionEntries[index.clamp(0, sectionEntries.length - 1)];
    final progress = widget.store.count(e);
    final target = widget.store.target(e);
    return Scaffold(
      appBar: AppBar(
        title: UiText(sectionLabel(widget.section)),
        actions: [
          IconButton(
            tooltip: tr(context, 'مشاركة بطاقة'),
            onPressed: () async {
              try {
                await shareDhikrCard(
                  context,
                  e,
                  p.background,
                  p.ink,
                  repetitionTarget: target,
                );
              } catch (_) {
                if (context.mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: UiText('تعذرت المشاركة، حاول مجددًا.'),
                    ),
                  );
              }
            },
            icon: const Icon(Icons.ios_share),
          ),
          IconButton(
            tooltip: tr(context, 'وضع التركيز'),
            onPressed: () => setState(() => focus = !focus),
            icon: Icon(
              focus ? Icons.visibility : Icons.visibility_off_outlined,
            ),
          ),
          IconButton(
            tooltip: tr(context, 'المفضلة'),
            onPressed: () => widget.store.toggleFavorite(e.id),
            icon: Icon(
              widget.store.favorites.contains(e.id)
                  ? Icons.bookmark
                  : Icons.bookmark_outline,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!focus)
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 5, 22, 8),
              child: Row(
                children: [
                  UiText(
                    '${index + 1} / ${sectionEntries.length}',
                    textDirection: TextDirection.ltr,
                    style: TextStyle(color: p.ink),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (index + 1) / sectionEntries.length,
                      color: p.primary,
                      backgroundColor: p.card,
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 13, 18, 18),
              children: [
                Surface(
                  color: p.dark ? p.card : Colors.white,
                  padding: const EdgeInsets.all(23),
                  child: Column(
                    children: [
                      UiText(
                        e.title,
                        style: TextStyle(
                          color: p.primary,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SelectableText(
                        e.arabic,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: p.ink,
                          fontSize: widget.store.fontSize,
                          height: 2.05,
                        ),
                      ),
                      const SizedBox(height: 21),
                      AudioPanel(key: ValueKey(e.id), entry: e),
                      UiText(
                        e.source,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: p.ink.withOpacity(.65),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!focus) ...[
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => setState(() => expanded = !expanded),
                    borderRadius: BorderRadius.circular(19),
                    child: Surface(
                      child: Row(
                        children: [
                          Icon(Icons.menu_book_outlined, color: p.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: UiText(
                              'الفضل والدليل والمعنى',
                              style: TextStyle(
                                color: p.ink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(
                            expanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: p.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (expanded)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Surface(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            UiText(
                              'المعنى',
                              style: TextStyle(
                                color: p.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 7),
                            UiText(
                              e.meaning,
                              style: TextStyle(color: p.ink, height: 1.7),
                            ),
                            const SizedBox(height: 14),
                            UiText(
                              'الفضل',
                              style: TextStyle(
                                color: p.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 7),
                            UiText(
                              e.benefit,
                              style: TextStyle(color: p.ink, height: 1.7),
                            ),
                            const SizedBox(height: 14),
                            UiText(
                              'الدليل',
                              style: TextStyle(
                                color: p.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 7),
                            UiText(
                              e.evidence,
                              style: TextStyle(color: p.ink, height: 1.7),
                            ),
                            const SizedBox(height: 12),
                            UiText(e.timing, style: TextStyle(color: p.ink)),
                            TextButton.icon(
                              onPressed: () async {
                                var ok = false;
                                try {
                                  ok = await launchUrl(
                                    Uri.parse(e.sourceUrl),
                                    mode: LaunchMode.externalApplication,
                                  );
                                } catch (_) {
                                  /* Show the same recoverable message. */
                                }
                                if (!ok && context.mounted)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: UiText(
                                        'تعذر فتح المرجع. يحتاج اتصالًا بالإنترنت.',
                                      ),
                                    ),
                                  );
                              },
                              icon: const Icon(Icons.open_in_new),
                              label: const UiText('فتح المصدر — يحتاج إنترنت'),
                            ),
                            if (e.quranSourceUrl.isNotEmpty)
                              TextButton.icon(
                                onPressed: () async {
                                  var ok = false;
                                  try {
                                    ok = await launchUrl(
                                      Uri.parse(e.quranSourceUrl),
                                      mode: LaunchMode.externalApplication,
                                    );
                                  } catch (_) {
                                    /* Same recoverable source failure. */
                                  }
                                  if (!ok && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: UiText(
                                          'تعذر فتح المرجع. يحتاج اتصالًا بالإنترنت.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.open_in_new),
                                label: const UiText('نص القرآن — Tanzil'),
                              ),
                            const SizedBox(height: 12),
                            UiText(
                              e.isQuran ? 'آية قرآنية' : 'صحيح',
                              style: TextStyle(
                                color: p.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        tooltip: tr(context, 'تكبير الخط'),
                        onPressed: () =>
                            widget.store.changeFont(widget.store.fontSize + 2),
                        icon: Icon(Icons.text_increase, color: p.ink),
                      ),
                      IconButton(
                        tooltip: tr(context, 'تصغير الخط'),
                        onPressed: () =>
                            widget.store.changeFont(widget.store.fontSize - 2),
                        icon: Icon(Icons.text_decrease, color: p.ink),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                if (e.countAlternatives.isNotEmpty)
                  Center(
                    child: Semantics(
                      label: tr(context, 'عدد التكرار'),
                      child: DropdownButton<int>(
                        value: target,
                        items: e.allowedCounts
                            .map(
                              (value) => DropdownMenuItem<int>(
                                value: value,
                                child: UiText(
                                  '${tr(context, 'عدد التكرار')}: $value',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) widget.store.chooseCount(e, value);
                        },
                      ),
                    ),
                  ),
                Center(
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: progress >= target
                        ? null
                        : () {
                            widget.store.setCount(e, progress + 1);
                            if (widget.store.autoAdvance &&
                                progress + 1 == target &&
                                index < sectionEntries.length - 1)
                              setState(() {
                                index++;
                                expanded = false;
                              });
                          },
                    onLongPress: () => widget.store.setCount(e, 0),
                    child: Container(
                      width: 114,
                      height: 114,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: p.primary,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            progress == target
                                ? Icons.check
                                : Icons.touch_app_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          UiText(
                            '$progress / $target',
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const UiText(
                            'اضغط للعدّ',
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: progress > 0
                      ? () => widget.store.setCount(e, progress - 1)
                      : null,
                  icon: const Icon(Icons.undo),
                  label: const UiText('تراجع عن ضغطة'),
                ),
                if (e.countDescription.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: UiText(
                      e.countDescription,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: p.ink.withOpacity(.7),
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      onPressed: index > 0
                          ? () => setState(() {
                              index--;
                              expanded = false;
                            })
                          : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: const UiText('السابق'),
                    ),
                    OutlinedButton.icon(
                      onPressed: index < sectionEntries.length - 1
                          ? () => setState(() {
                              index++;
                              expanded = false;
                            })
                          : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const UiText('التالي'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NawafilPage extends StatelessWidget {
  const NawafilPage({super.key, required this.store});
  final WirdState store;
  @override
  Widget build(BuildContext context) {
    final p = store.palette;
    const rawatib = <(String, String, String, String)>[
      ('الفجر', 'قبل', '٢', 'fajr_before'),
      ('الظهر', 'قبل', '٤', 'dhuhr_before'),
      ('الظهر', 'بعد', '٢', 'dhuhr_after'),
      ('المغرب', 'بعد', '٢', 'maghrib_after'),
      ('العشاء', 'بعد', '٢', 'isha_after'),
    ];
    final done = rawatib.where((r) => store.prayerDone(r.$4)).length;
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        const Header(
          'السنن والنوافل',
          subtitle: 'تتبّع شخصي اختياري — دون إلزام أو تنبيهات ضاغطة',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 19),
          child: Surface(
            child: Column(
              children: [
                UiText(
                  'السنن الرواتب الاثنتا عشرة',
                  style: TextStyle(
                    color: p.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                UiText(
                  '$done / 5 مجموعات سُجّلت اليوم',
                  style: TextStyle(color: p.ink.withOpacity(.7)),
                ),
                const SizedBox(height: 12),
                ...rawatib.map(
                  (r) => CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    activeColor: p.primary,
                    value: store.prayerDone(r.$4),
                    onChanged: (_) => store.togglePrayer(r.$4),
                    title: UiText(
                      '${r.$1} — ${r.$2} الفريضة',
                      style: TextStyle(color: p.ink),
                    ),
                    subtitle: UiText(
                      '${r.$3} ركعات',
                      style: TextStyle(color: p.ink.withOpacity(.7)),
                    ),
                  ),
                ),
                const Divider(),
                UiText(
                  'أربع قبل الظهر وركعتان قبل الفجر: البخاري 1182. ركعتان بعد الظهر والمغرب والعشاء: البخاري 1180–1181. وفضل اثنتي عشرة ركعة في يوم وليلة: مسلم 728a. توجد روايات صحيحة أخرى؛ هذا عرض لإحدى صور التتبع.',
                  style: TextStyle(color: p.ink.withOpacity(.65), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 19),
          child: Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UiText(
                  'نوافل أخرى',
                  style: TextStyle(
                    color: p.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...const [
                  (
                    'duha',
                    'صلاة الضحى',
                    'ركعتان من الضحى تجزئان عن صدقة المفاصل؛ صحيح مسلم 720.',
                  ),
                  (
                    'witr',
                    'صلاة الوتر',
                    'صلاة الليل مثنى مثنى، وإذا خشي الصبح أوتر بواحدة؛ صحيح البخاري 990.',
                  ),
                  (
                    'night',
                    'قيام الليل',
                    'تصلّى ركعتين ركعتين؛ صحيح البخاري 990. التسجيل اختياري ولا يفرض عددًا.',
                  ),
                ].map(
                  (r) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: UiText(r.$2),
                    subtitle: UiText(r.$3),
                    value: store.prayerDone(r.$1),
                    onChanged: (_) => store.togglePrayer(r.$1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
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

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.store});
  final WirdState store;
  @override
  Widget build(BuildContext context) {
    final p = store.palette;
    return ListView(
      padding: const EdgeInsets.only(bottom: 25),
      children: [
        const Header('الإعدادات', subtitle: 'المظهر والقراءة والخصوصية'),
        if (store.storageError != null)
          Padding(
            padding: const EdgeInsets.all(19),
            child: UiText(store.storageError!),
          ),
        ListTile(
          title: const UiText('اللغة'),
          trailing: DropdownButton<String>(
            key: const Key('language-picker'),
            value: store.languageCode,
            items: const [
              DropdownMenuItem(value: 'ar', child: Text('العربية')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (value) {
              if (value != null) store.changeLanguage(value);
            },
          ),
        ),
        if (store.languageCode == 'en')
          const Padding(
            padding: EdgeInsets.all(19),
            child: UiText(
              'النص الديني بالعربية؛ الترجمة الإنجليزية قيد المراجعة.',
            ),
          ),
        const ReminderPanel(),
        SwitchListTile(
          title: const UiText('اهتزاز خفيف عند العد'),
          value: store.haptics,
          onChanged: (v) => store.preferences(feedback: v),
        ),
        SwitchListTile(
          title: const UiText('الانتقال تلقائيًا بعد إكمال الذكر'),
          value: store.autoAdvance,
          onChanged: (v) => store.preferences(advance: v),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 19),
          child: Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UiText(
                  'المظهر',
                  style: TextStyle(
                    color: p.ink,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(themes.length, (index) {
                  final t = themes[index];
                  return RadioListTile<int>(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Row(
                      children: [
                        Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            color: t.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: UiText(
                            t.name,
                            style: TextStyle(color: p.ink, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    value: index,
                    groupValue: store.themeIndex,
                    activeColor: p.primary,
                    onChanged: (value) {
                      if (value != null) store.changeTheme(value);
                    },
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 19),
          child: Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UiText(
                  'حجم الخط',
                  style: TextStyle(color: p.ink, fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: store.fontSize,
                  min: 19,
                  max: 38,
                  divisions: 19,
                  activeColor: p.primary,
                  onChanged: store.changeFont,
                ),
                UiText(
                  'هذا مثال على حجم القراءة',
                  style: TextStyle(fontSize: store.fontSize, color: p.ink),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 19),
          child: Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UiText(
                  'السبحة الشخصية',
                  style: TextStyle(color: p.ink, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Center(
                  child: UiText(
                    '${store.tasbih}',
                    style: TextStyle(
                      color: p.primary,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: () => store.setTasbih(store.tasbih + 1),
                      child: const UiText('تسبيح +'),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () => store.setTasbih(0),
                      child: const UiText('إعادة'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                UiText(
                  'هدف شخصي، وليس عددًا تعبديًا منصوصًا.',
                  style: TextStyle(color: p.ink.withOpacity(.65), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 19),
          child: Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UiText(
                  'خصوصيتك ومصادرك',
                  style: TextStyle(color: p.ink, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                UiText(
                  'لا حسابات ولا إعلانات ولا تحليلات ولا قاعدة بيانات خارجية. تحفظ المتابعة على جهازك. أضف ودجت ورد من الشاشة الرئيسية. الصوت لا يتاح إلا بعد اعتماد التسجيل وترخيصه. أوقات التذكير اختيار شخصي وليست تحديدًا شرعيًا.',
                  style: TextStyle(color: p.ink.withOpacity(.75), height: 1.7),
                ),
                TextButton(
                  onPressed: () => showLicensePage(
                    context: context,
                    applicationName: 'ورد — Wird',
                  ),
                  child: const UiText('تراخيص البرمجيات'),
                ),
                TextButton(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const UiText('مسح المتابعة والمفضلة؟'),
                        content: const UiText(
                          'لا يمكن التراجع. تبقى إعدادات المظهر والتذكيرات.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c, false),
                            child: const UiText('إلغاء'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(c, true),
                            child: const UiText('مسح'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      try {
                        await store.erase();
                      } catch (_) {
                        if (context.mounted)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: UiText(
                                'تعذر مسح البيانات. حاول مجددًا.',
                              ),
                            ),
                          );
                      }
                    }
                  },
                  child: const UiText('مسح بياناتي المحلية'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
