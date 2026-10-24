part of 'main.dart';

const settingsPrivacyCopy =
    'لا حسابات ولا إعلانات ولا تحليلات ولا قاعدة بيانات خارجية. تحفظ المتابعة على جهازك. أضف ودجت ورد من الشاشة الرئيسية. الصوت لا يتاح إلا بعد اعتماد التسجيل وترخيصه. أوقات التذكير اختيار شخصي وليست تحديدًا شرعيًا.';

/// Uses the existing preference setters; no data migration or new storage keys.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.store});
  final WirdState store;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (context, _) {
      final p = store.palette;
      return SettingsStyle(
        palette: p,
        child: ColoredBox(
          color: p.homeBackground,
          child: SingleChildScrollView(
            key: PageStorageKey('settings-scroll'),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SettingsHeader(palette: p),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (store.storageError != null)
                            Padding(
                              padding: EdgeInsets.all(12),
                              child: UiText(store.storageError!),
                            ),
                          SettingsPanel(
                            child: _SettingsControl(
                              icon: Icons.language_rounded,
                              title: 'اللغة',
                              subtitle: 'اختر لغة التطبيق',
                              control: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  key: Key('language-picker'),
                                  value: store.languageCode,
                                  dropdownColor: p.homeSurface,
                                  style: TextStyle(
                                    color: AppAppearance.of(context).ink,
                                    fontFamily: 'NotoSansArabic',
                                    fontSize: 15,
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                      value: 'ar',
                                      child: Text('العربية'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'en',
                                      child: Text('English'),
                                    ),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) store.changeLanguage(v);
                                  },
                                ),
                              ),
                            ),
                          ),
                          if (store.languageCode == 'en')
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: UiText(
                                'النص الديني بالعربية؛ الترجمة الإنجليزية قيد المراجعة.',
                                style: TextStyle(
                                  color: AppAppearance.of(context).ink,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          SizedBox(height: 10),
                          SettingsPanel(
                            highlighted: true,
                            child: InkWell(
                              key: Key('appearance-picker'),
                              borderRadius: BorderRadius.circular(22),
                              onTap: () => _appearance(context),
                              child: _SettingsControl(
                                icon: Icons.palette_outlined,
                                title: 'المظهر',
                                subtitle: themes[store.themeIndex].name,
                                control: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ...{0, 1}
                                        .take(2)
                                        .map(
                                          (i) => Padding(
                                            padding: EdgeInsets.all(3),
                                            child: Container(
                                              width: 28,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: themes[i].primary,
                                                border: Border.all(
                                                  color: i == store.themeIndex
                                                      ? AppAppearance.of(
                                                          context,
                                                        ).gold
                                                      : AppAppearance.of(
                                                          context,
                                                        ).ink.withOpacity(.3),
                                                  width: i == store.themeIndex
                                                      ? 2
                                                      : 1,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    Icon(
                                      Directionality.of(context) ==
                                              TextDirection.rtl
                                          ? Icons.chevron_left
                                          : Icons.chevron_right,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          ReminderPanel(),
                          SizedBox(height: 12),
                          SettingsPanel(
                            highlighted: true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SettingsHeading(
                                  'حجم الخط',
                                  icon: Icons.text_fields_rounded,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Aa',
                                      style: TextStyle(
                                        color: AppAppearance.of(context).gold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Expanded(
                                      child: Slider(
                                        key: Key('reading-font-slider'),
                                        value: store.fontSize,
                                        min: 19,
                                        max: 38,
                                        divisions: 19,
                                        label: '${store.fontSize.round()}',
                                        onChanged: store.changeFont,
                                      ),
                                    ),
                                    Text(
                                      '${store.fontSize.round()}',
                                      style: TextStyle(
                                        color: AppAppearance.of(context).gold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  key: Key('reading-font-preview'),
                                  padding: EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: AppAppearance.of(
                                        context,
                                      ).gold.withOpacity(.32),
                                    ),
                                    color: p.homeBackground.withOpacity(.55),
                                  ),
                                  child: UiText(
                                    'هذا مثال على حجم القراءة',
                                    style: TextStyle(
                                      fontSize: store.fontSize,
                                      color: AppAppearance.of(context).ink,
                                      height: 1.7,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                          SettingsPanel(
                            highlighted: true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SettingsHeading(
                                  'السبحة الشخصية',
                                  icon: Icons.grain_rounded,
                                ),
                                SizedBox(height: 8),
                                UiText(
                                  'هدف شخصي، وليس عددًا تعبديًا منصوصًا.',
                                  style: TextStyle(
                                    color: AppAppearance.of(context).ink,
                                    fontSize: 12,
                                    height: 1.8,
                                  ),
                                ),
                                SizedBox(height: 12),
                                LayoutBuilder(
                                  builder: (context, c) {
                                    final counter = Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 24,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(22),
                                        border: Border.all(
                                          color: AppAppearance.of(
                                            context,
                                          ).gold.withOpacity(.3),
                                        ),
                                        gradient: RadialGradient(
                                          colors: [
                                            p.homeAccent.withOpacity(.15),
                                            p.homeBackground,
                                          ],
                                        ),
                                      ),
                                      child: Semantics(
                                        liveRegion: true,
                                        label: tr(context, 'السبحة الشخصية'),
                                        child: Text(
                                          '${store.tasbih}',
                                          key: Key('settings-tasbih-value'),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: AppAppearance.of(
                                              context,
                                            ).ink,
                                            fontSize: 46,
                                            height: 1.3,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    );
                                    final buttons = Wrap(
                                      spacing: 10,
                                      runSpacing: 8,
                                      alignment: WrapAlignment.center,
                                      children: [
                                        FilledButton.icon(
                                          key: Key('settings-tasbih-add'),
                                          onPressed: () {
                                            store.setTasbih(store.tasbih + 1);
                                            if (store.haptics)
                                              unawaited(
                                                HapticFeedback.selectionClick(),
                                              );
                                          },
                                          icon: Icon(Icons.add, size: 18),
                                          label: UiText('تسبيح +'),
                                        ),
                                        OutlinedButton.icon(
                                          key: Key('settings-tasbih-reset'),
                                          onPressed: () => store.setTasbih(0),
                                          icon: Icon(
                                            Icons.restart_alt,
                                            size: 18,
                                          ),
                                          label: UiText('إعادة'),
                                        ),
                                      ],
                                    );
                                    if (c.maxWidth < 320 ||
                                        MediaQuery.textScalerOf(
                                              context,
                                            ).scale(1) >
                                            1.3)
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          counter,
                                          SizedBox(height: 12),
                                          buttons,
                                        ],
                                      );
                                    return Row(
                                      children: [
                                        Expanded(flex: 2, child: buttons),
                                        SizedBox(width: 16),
                                        Expanded(child: counter),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                          SettingsPanel(
                            child: Column(
                              children: [
                                _SettingsControl(
                                  icon: Icons.vibration_rounded,
                                  title: 'اهتزاز خفيف عند العد',
                                  control: Semantics(
                                    label: tr(context, 'اهتزاز خفيف عند العد'),
                                    child: Switch(
                                      key: Key('haptics-switch'),
                                      value: store.haptics,
                                      onChanged: (v) =>
                                          store.preferences(feedback: v),
                                    ),
                                  ),
                                ),
                                Divider(
                                  height: 18,
                                  color: appearanceTone(context, 0x335F9D92),
                                ),
                                _SettingsControl(
                                  icon: Icons.skip_next_rounded,
                                  title: 'الانتقال تلقائيًا بعد إكمال الذكر',
                                  control: Semantics(
                                    label: tr(
                                      context,
                                      'الانتقال تلقائيًا بعد إكمال الذكر',
                                    ),
                                    child: Switch(
                                      key: Key('auto-advance-switch'),
                                      value: store.autoAdvance,
                                      onChanged: (v) =>
                                          store.preferences(advance: v),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                          SettingsPanel(
                            highlighted: true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SettingsHeading(
                                  'خصوصيتك ومصادرك',
                                  icon: Icons.verified_user_outlined,
                                ),
                                SizedBox(height: 10),
                                UiText(
                                  'تحفظ المتابعة على جهازك.',
                                  style: TextStyle(
                                    color: AppAppearance.of(context).ink,
                                    height: 1.8,
                                    fontSize: 13,
                                  ),
                                ),
                                ExpansionTile(
                                  key: Key('privacy-details'),
                                  tilePadding: EdgeInsets.zero,
                                  childrenPadding: EdgeInsets.only(bottom: 14),
                                  title: UiText(
                                    'التفاصيل والمصادر',
                                    style: TextStyle(
                                      color: AppAppearance.of(context).gold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  children: [
                                    UiText(
                                      settingsPrivacyCopy,
                                      style: TextStyle(
                                        color: AppAppearance.of(context).ink,
                                        height: 1.9,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                _SettingsAction(
                                  key: Key('settings-erase'),
                                  icon: Icons.delete_outline_rounded,
                                  title: 'مسح بياناتي المحلية',
                                  onTap: () => _erase(context),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  Future<void> _appearance(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: store.palette.homeSurface,
    showDragHandle: true,
    builder: (c) => SettingsStyle(
      palette: store.palette,
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(c).height * .8,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              children: [
                SettingsHeading('المظهر', icon: Icons.palette_outlined),
                SizedBox(height: 12),
                ...themes.indexed.map(
                  (e) => RadioListTile<int>(
                    key: Key('settings-theme-${e.$1}'),
                    value: e.$1,
                    groupValue: store.themeIndex,
                    activeColor: AppAppearance.of(context).gold,
                    secondary: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [e.$2.homeSurface, e.$2.homeBackground],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: e.$1 == store.themeIndex
                              ? AppAppearance.of(context).gold
                              : e.$2.homeOutline,
                        ),
                      ),
                      child: Icon(
                        e.$2.dark
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                        color: e.$2.dark ? homeGold : e.$2.ink,
                        size: 28,
                      ),
                    ),
                    title: UiText(
                      e.$2.name,
                      style: TextStyle(
                        color: AppAppearance.of(context).ink,
                        fontSize: 14,
                      ),
                    ),
                    onChanged: (i) {
                      if (i != null) store.changeTheme(i);
                      Navigator.pop(c);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _erase(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => SettingsStyle(
        palette: store.palette,
        child: AlertDialog(
          backgroundColor: store.palette.homeSurface,
          title: UiText(
            'مسح المتابعة والمفضلة؟',
            style: TextStyle(color: AppAppearance.of(context).ink),
          ),
          content: UiText(
            'سيمسح تقدم القراءة والمفضلة وتتبع الصلاة والسبحة الشخصية. لا يمكن التراجع. تبقى إعدادات المظهر والتذكيرات.',
            style: TextStyle(color: AppAppearance.of(context).ink, height: 1.8),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: UiText('إلغاء'),
            ),
            TextButton(
              key: Key('confirm-local-erase'),
              onPressed: () => Navigator.pop(c, true),
              child: UiText('مسح'),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      try {
        await store.erase();
      } catch (_) {
        if (context.mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: UiText('تعذر مسح البيانات. حاول مجددًا.')),
          );
      }
    }
  }
}

class SettingsStyle extends StatelessWidget {
  const SettingsStyle({super.key, required this.palette, required this.child});
  final WirdPalette palette;
  final Widget child;
  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(
        primary: AppAppearance.of(context).gold,
        onPrimary: appearanceTone(context, 0xFF173A36),
        surface: palette.homeSurface,
        onSurface: AppAppearance.of(context).ink,
        secondary: palette.homeAccent,
      ),
      iconTheme: IconThemeData(color: AppAppearance.of(context).gold),
      textTheme: Theme.of(context).textTheme.apply(
        bodyColor: AppAppearance.of(context).ink,
        displayColor: AppAppearance.of(context).ink,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: palette.dark
            ? WidgetStatePropertyAll(homeCream)
            : WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.selected)
                    ? IvoryContrast.cream
                    : IvoryContrast.ink,
              ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? (palette.dark ? homeGold : IvoryContrast.accent)
              : (palette.dark ? palette.homeBackground : IvoryContrast.sage),
        ),
        trackOutlineColor: WidgetStatePropertyAll(
          palette.dark
              ? AppAppearance.of(context).gold.withOpacity(.4)
              : IvoryContrast.outline,
        ),
      ),
      sliderTheme: SliderTheme.of(context).copyWith(
        activeTrackColor: AppAppearance.of(context).gold,
        thumbColor: AppAppearance.of(context).gold,
        inactiveTrackColor: palette.dark
            ? AppAppearance.of(context).ink.withOpacity(.25)
            : IvoryContrast.outline,
        overlayColor: AppAppearance.of(context).gold.withOpacity(.12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppAppearance.of(context).gold,
          foregroundColor: appearanceTone(context, 0xFF173A36),
          padding: EdgeInsets.symmetric(horizontal: 12),
          minimumSize: Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppAppearance.of(context).gold,
          padding: EdgeInsets.symmetric(horizontal: 12),
          side: BorderSide(
            color: palette.dark
                ? AppAppearance.of(context).gold.withOpacity(.65)
                : IvoryContrast.outline,
          ),
          minimumSize: Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppAppearance.of(context).gold,
          minimumSize: Size(48, 48),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: appearanceTone(context, 0x335F9D92),
      ),
    ),
    child: child,
  );
}

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({
    super.key,
    required this.child,
    this.highlighted = false,
  });
  final Widget child;
  final bool highlighted;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(16),
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: highlighted
            ? AppAppearance.of(context).gold.withOpacity(.6)
            : appearanceTone(context, 0x665F9D92),
      ),
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Theme.of(context).colorScheme.surface,
          appearanceTone(context, 0xFF002C2C),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.15),
          blurRadius: 18,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: CustomPaint(
      painter: highlighted ? _SettingsOrnament() : null,
      child: child,
    ),
  );
}

class SettingsHeading extends StatelessWidget {
  const SettingsHeading(this.title, {super.key, required this.icon});
  final String title;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      _SettingsMedallion(icon),
      SizedBox(width: 12),
      Expanded(
        child: UiText(
          title,
          style: TextStyle(
            color: AppAppearance.of(context).ink,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

class _SettingsMedallion extends StatelessWidget {
  const _SettingsMedallion(this.icon);
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(17),
      border: Border.all(
        color: AppAppearance.of(context).gold.withOpacity(.35),
      ),
      gradient: LinearGradient(
        colors: [
          appearanceTone(context, 0xFF294944),
          appearanceTone(context, 0xFF092D2C),
        ],
      ),
    ),
    child: icon == Icons.grain_rounded
        ? Padding(
            padding: EdgeInsets.all(8),
            child: CustomPaint(
              painter: _BeadsPainter(AppAppearance.of(context).gold),
            ),
          )
        : Icon(icon, color: AppAppearance.of(context).gold, size: 23),
  );
}

class _SettingsControl extends StatelessWidget {
  const _SettingsControl({
    required this.icon,
    required this.title,
    required this.control,
    this.subtitle,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget control;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final label = Row(
        children: [
          _SettingsMedallion(icon),
          SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UiText(
                  title,
                  style: TextStyle(
                    color: AppAppearance.of(context).ink,
                    fontSize: 16,
                    height: 1.7,
                  ),
                ),
                if (subtitle != null)
                  UiText(
                    subtitle!,
                    style: TextStyle(
                      color: AppAppearance.of(context).ink.withOpacity(.72),
                      fontSize: 12,
                      height: 1.7,
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
      if (c.maxWidth < 300 && MediaQuery.textScalerOf(context).scale(1) > 1.3)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            label,
            Align(alignment: AlignmentDirectional.centerEnd, child: control),
          ],
        );
      return Row(
        children: [
          Expanded(child: label),
          SizedBox(width: 8),
          control,
        ],
      );
    },
  );
}

class _SettingsAction extends StatelessWidget {
  const _SettingsAction({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _SettingsMedallion(icon),
          SizedBox(width: 12),
          Expanded(
            child: UiText(
              title,
              style: TextStyle(
                color: AppAppearance.of(context).ink,
                fontSize: 15,
                height: 1.8,
              ),
            ),
          ),
          Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.chevron_left
                : Icons.chevron_right,
            color: AppAppearance.of(context).gold,
            size: 20,
          ),
        ],
      ),
    ),
  );
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.palette});
  final WirdPalette palette;
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: ExcludeSemantics(
          child: Opacity(
            opacity: .28,
            child: Image.asset(
              botanicalAsset(context),
              fit: BoxFit.cover,
              alignment: Alignment.topLeft,
            ),
          ),
        ),
      ),
      Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                palette.homeBackground.withOpacity(.25),
                palette.homeBackground,
              ],
            ),
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(24, 32, 24, 26),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UiText(
                    'الإعدادات',
                    style: TextStyle(
                      color: AppAppearance.of(context).gold,
                      fontSize: 34,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  UiText(
                    'المظهر والقراءة والخصوصية',
                    style: TextStyle(
                      color: AppAppearance.of(context).ink.withOpacity(.85),
                      fontSize: 14,
                      height: 1.8,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            Icon(
              Icons.spa_outlined,
              color: AppAppearance.of(context).gold,
              size: 31,
            ),
          ],
        ),
      ),
    ],
  );
}

// Decorative only: light interlaced squares, clipped inside each card.
class _SettingsOrnament extends CustomPainter {
  const _SettingsOrnament();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = homeGold.withOpacity(.065)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .7;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 3; col++) {
        canvas.save();
        canvas.translate(col * 24.0 - 12, row * 24.0 - 12);
        canvas.drawRect(const Rect.fromLTWH(-14, -14, 28, 28), paint);
        canvas.rotate(.7853981634);
        canvas.drawRect(const Rect.fromLTWH(-14, -14, 28, 28), paint);
        canvas.restore();
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SettingsOrnament oldDelegate) => false;
}

/// The new control panel does not add layout or asset work to cold launch.
/// Once visited it remains mounted in the shell's existing IndexedStack.
class DeferredSettingsPage extends StatefulWidget {
  const DeferredSettingsPage({
    super.key,
    required this.store,
    required this.active,
  });
  final WirdState store;
  final bool active;
  @override
  State<DeferredSettingsPage> createState() => _DeferredSettingsPageState();
}

class _DeferredSettingsPageState extends State<DeferredSettingsPage> {
  bool _opened = false;
  @override
  Widget build(BuildContext context) {
    _opened = _opened || widget.active;
    return _opened ? SettingsPage(store: widget.store) : SizedBox.shrink();
  }
}
