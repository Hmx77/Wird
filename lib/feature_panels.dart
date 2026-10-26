import 'ui_strings.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'content.dart';
import 'main.dart';
import 'services/reminders.dart';
import 'services/audio_library.dart';

class ReminderPanel extends StatefulWidget {
  const ReminderPanel({super.key});
  static Future<void> reschedule() async {
    if (!Reminders.instance.ready) return;
    SharedPreferences prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (_) {
      return;
    }
    for (final section in DhikrSection.values) {
      final key = 'reminder.${section.name}';
      if (prefs.getBool('$key.enabled') ?? false) {
        try {
          await Reminders.instance.set(
            section,
            (prefs.getInt('$key.hour') ?? [7, 18, 22][section.index]).clamp(
              0,
              23,
            ),
            (prefs.getInt('$key.minute') ?? 0).clamp(0, 59),
            true,
          );
        } catch (_) {
          /* Retry on next resume. */
        }
      }
    }
  }

  @override
  State<ReminderPanel> createState() => _ReminderPanelState();
}

class _ReminderPanelState extends State<ReminderPanel> {
  SharedPreferences? prefs;
  bool busy = false;
  bool loadFailed = false;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      if (mounted) setState(() => prefs = p);
    } catch (_) {
      if (mounted) setState(() => loadFailed = true);
    }
  }

  Future<void> update(
    DhikrSection section,
    bool enabled,
    TimeOfDay time,
  ) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      if (!Reminders.instance.ready) {
        throw StateError(Reminders.instance.error ?? 'التذكيرات غير متاحة');
      }
      if (enabled && !await Reminders.instance.requestPermission()) {
        throw StateError('يرجى السماح بالإشعارات من إعدادات الجهاز.');
      }
      await Reminders.instance.set(section, time.hour, time.minute, enabled);
      final key = 'reminder.${section.name}';
      final results = await Future.wait([
        prefs!.setInt('$key.hour', time.hour),
        prefs!.setInt('$key.minute', time.minute),
        prefs!.setBool('$key.enabled', enabled),
      ]);
      if (results.contains(false))
        throw StateError('تعذر حفظ إعدادات التذكير.');
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: UiText(
              e is StateError ? e.message : 'تعذر ضبط التذكير. حاول مجددًا.',
            ),
          ),
        );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loadFailed)
      return Padding(
        padding: EdgeInsets.all(19),
        child: UiText(
          'تعذر فتح الحفظ المحلي. يمكنك القراءة؛ قد لا تحفظ التغييرات.',
        ),
      );
    if (prefs == null) return SizedBox.shrink();
    return SettingsPanel(
      highlighted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsHeading('تذكيراتك', icon: Icons.notifications_none_rounded),
          SizedBox(height: 9),
          UiText(
            'أوقات تختارها أنت. قد يؤخر النظام التنبيه لتوفير البطارية.',
            style: TextStyle(
              color: AppAppearance.of(context).ink,
              fontSize: 14,
              height: 1.8,
            ),
          ),
          SizedBox(height: 12),
          ...DhikrSection.values.map((section) {
            final key = 'reminder.${section.name}';
            final enabled = prefs!.getBool('$key.enabled') ?? false;
            final time = TimeOfDay(
              hour: (prefs!.getInt('$key.hour') ?? [7, 18, 22][section.index])
                  .clamp(0, 23),
              minute: (prefs!.getInt('$key.minute') ?? 0).clamp(0, 59),
            );
            final title = Row(
              children: [
                Icon(
                  [
                    Icons.wb_sunny_outlined,
                    Icons.wb_twilight_rounded,
                    Icons.nightlight_round,
                  ][section.index],
                  color: AppAppearance.of(context).gold,
                  size: 22,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: UiText(
                    sectionLabel(section),
                    style: TextStyle(
                      color: AppAppearance.of(
                        context,
                      ).ink.withOpacity(enabled ? 1 : .72),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.7,
                    ),
                  ),
                ),
              ],
            );
            final controls = Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.end,
              spacing: 4,
              runSpacing: 4,
              children: [
                OutlinedButton(
                  key: Key('reminder-time-${section.name}'),
                  onPressed: busy
                      ? null
                      : () async {
                          final selected = await showTimePicker(
                            context: context,
                            initialTime: time,
                          );
                          if (selected != null)
                            await update(section, enabled, selected);
                        },
                  child: Text(
                    time.format(context),
                    style: TextStyle(
                      color: AppAppearance.of(
                        context,
                      ).ink.withOpacity(enabled ? 1 : .7),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Semantics(
                  label:
                      '${tr(context, 'تذكير')} ${tr(context, sectionLabel(section))}',
                  child: Switch(
                    key: Key('reminder-switch-${section.name}'),
                    value: enabled,
                    onChanged: busy ? null : (v) => update(section, v, time),
                  ),
                ),
              ],
            );
            return Container(
              margin: EdgeInsets.only(top: 7),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppAppearance.of(
                    context,
                  ).gold.withOpacity(enabled ? .3 : .12),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, c) {
                  if (c.maxWidth < 300 ||
                      MediaQuery.textScalerOf(context).scale(1) > 1.3)
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        title,
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: controls,
                        ),
                      ],
                    );
                  return Row(
                    children: [
                      Expanded(child: title),
                      SizedBox(width: 8),
                      controls,
                    ],
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class AudioPanel extends StatefulWidget {
  const AudioPanel({super.key, required this.entry});
  final DhikrEntry entry;
  @override
  State<AudioPanel> createState() => _AudioPanelState();
}

class _AudioPanelState extends State<AudioPanel> with WidgetsBindingObserver {
  AudioPlayer? player;
  StreamSubscription<PlayerState>? listener;
  StreamSubscription<PlayerException>? errors;
  bool busy = false, playing = false;
  String? error;
  LicensedTrack? get track => AudioLibrary.instance.tracks[widget.entry.id];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) player?.pause();
  }

  Future<void> toggle() async {
    if (track == null || busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (player == null) {
        player = AudioPlayer();
        listener = player!.playerStateStream.listen((s) {
          if (mounted)
            setState(
              () => playing =
                  s.playing && s.processingState != ProcessingState.completed,
            );
        });
        errors = player!.errorStream.listen((_) {
          if (mounted)
            setState(() {
              error = 'تعذر تشغيل التسجيل.';
              playing = false;
            });
        });
        await player!.setAsset(track!.asset);
        if (!mounted) return;
      }
      if (playing) {
        await player!.pause();
      } else {
        if (player!.processingState == ProcessingState.completed)
          await player!.seek(Duration.zero);
        unawaited(
          player!.play().catchError((Object _) {
            if (mounted)
              setState(() {
                error = 'تعذر تشغيل التسجيل.';
                playing = false;
              });
          }),
        );
      }
    } catch (_) {
      if (mounted) setState(() => error = 'تعذر تشغيل التسجيل.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    listener?.cancel();
    errors?.cancel();
    player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (track == null)
      return Padding(
        padding: EdgeInsets.only(bottom: 14),
        child: UiText(
          'التسجيل الصوتي بانتظار ترخيص ومراجعة',
          style: TextStyle(fontSize: 12),
        ),
      );
    return Column(
      children: [
        FilledButton.tonalIcon(
          onPressed: busy ? null : toggle,
          icon: Icon(playing ? Icons.pause : Icons.play_arrow),
          label: UiText(playing ? 'إيقاف مؤقت' : 'استماع'),
        ),
        if (player != null)
          StreamBuilder<Duration>(
            stream: player!.positionStream,
            builder: (context, snapshot) {
              final duration = player!.duration?.inMilliseconds ?? 0;
              final value = (snapshot.data?.inMilliseconds ?? 0)
                  .clamp(0, duration)
                  .toDouble();
              return Slider(
                value: value,
                max: duration > 0 ? duration.toDouble() : 1,
                onChanged: duration == 0
                    ? null
                    : (v) => player!.seek(Duration(milliseconds: v.round())),
              );
            },
          ),
        UiText(
          '${track!.reciter} • ${track!.license}',
          style: TextStyle(fontSize: 11),
        ),
        if (error != null) UiText(error!),
      ],
    );
  }
}

class ProgressCalendar extends StatefulWidget {
  const ProgressCalendar({super.key, required this.store});
  final WirdState store;
  @override
  State<ProgressCalendar> createState() => _ProgressCalendarState();
}

class _ProgressCalendarState extends State<ProgressCalendar> {
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  @override
  Widget build(BuildContext context) {
    final p = widget.store.palette;
    final count = DateTime(month.year, month.month + 1, 0).day;
    final localizations = MaterialLocalizations.of(context);
    final firstWeekday = localizations.firstDayOfWeekIndex;
    final offset = (month.weekday % 7 - firstWeekday + 7) % 7;
    return Padding(
      padding: EdgeInsets.fromLTRB(19, 0, 19, 18),
      child: Surface(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: tr(context, 'الشهر السابق'),
                  onPressed: () => setState(
                    () => month = DateTime(month.year, month.month - 1),
                  ),
                  icon: Icon(Icons.chevron_right),
                ),
                UiText(
                  MaterialLocalizations.of(context).formatMonthYear(month),
                ),
                IconButton(
                  tooltip: tr(context, 'الشهر التالي'),
                  onPressed:
                      month.year == DateTime.now().year &&
                          month.month == DateTime.now().month
                      ? null
                      : () => setState(
                          () => month = DateTime(month.year, month.month + 1),
                        ),
                  icon: Icon(Icons.chevron_left),
                ),
              ],
            ),
            Row(
              children: List.generate(
                7,
                (i) => Expanded(
                  child: Text(
                    localizations.narrowWeekdays[(firstWeekday + i) % 7],
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: List.generate(count + offset, (cell) {
                if (cell < offset) return SizedBox.shrink();
                final i = cell - offset;
                final date = DateTime(month.year, month.month, i + 1);
                final done = entries
                    .where((e) => widget.store.isDone(e, dayKey(date)))
                    .length;
                return Semantics(
                  label:
                      '${localizations.formatFullDate(date)}: $done / ${entries.length}',
                  child: Tooltip(
                    message: '$done / ${entries.length}',
                    child: Container(
                      margin: EdgeInsets.all(3),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: done == 0 ? p.background : p.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: UiText(
                        '${i + 1}',
                        style: TextStyle(
                          color: done == 0 ? p.ink : Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            UiText(
              'الأيام الملوّنة: أتممت فيها ذكرًا واحدًا أو أكثر',
              style: TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
