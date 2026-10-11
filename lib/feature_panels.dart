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
              e is StateError
                  ? e.message
                  : 'تعذر ضبط التذكير. حاول مجددًا.',
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
      return const Padding(
        padding: EdgeInsets.all(19),
        child: UiText(
          'تعذر فتح الحفظ المحلي. يمكنك القراءة؛ قد لا تحفظ التغييرات.',
        ),
      );
    if (prefs == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(19),
      child: Surface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const UiText(
              'تذكيراتك',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const UiText(
              'أوقات تختارها أنت. قد يؤخر النظام التنبيه لتوفير البطارية.',
              style: TextStyle(fontSize: 12),
            ),
            ...DhikrSection.values.map((section) {
              final key = 'reminder.${section.name}';
              final enabled = prefs!.getBool('$key.enabled') ?? false;
              final time = TimeOfDay(
                hour: (prefs!.getInt('$key.hour') ?? [7, 18, 22][section.index])
                    .clamp(0, 23),
                minute: (prefs!.getInt('$key.minute') ?? 0).clamp(0, 59),
              );
              return Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: UiText(sectionLabel(section)),
                    value: enabled,
                    onChanged: busy ? null : (v) => update(section, v, time),
                  ),
                  TextButton(
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
                    child: UiText(time.format(context)),
                  ),
                ],
              );
            }),
          ],
        ),
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
      return const Padding(
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
          style: const TextStyle(fontSize: 11),
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
      padding: const EdgeInsets.fromLTRB(19, 0, 19, 18),
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
                  icon: const Icon(Icons.chevron_right),
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
                  icon: const Icon(Icons.chevron_left),
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
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(count + offset, (cell) {
                if (cell < offset) return const SizedBox.shrink();
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
                      margin: const EdgeInsets.all(3),
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
            const UiText(
              'الأيام الملوّنة: أتممت فيها ذكرًا واحدًا أو أكثر',
              style: TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
