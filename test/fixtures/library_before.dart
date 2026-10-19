// Original Library implementation from b961252; test-only before capture.
import 'package:flutter/material.dart';
import 'package:wird/main.dart';
import 'package:wird/content.dart';
import 'package:wird/ui_strings.dart';

class BaselineLibraryPage extends StatefulWidget {
  const BaselineLibraryPage({
    super.key,
    required this.store,
    this.initialFavorites = false,
  });
  final bool initialFavorites;
  final WirdState store;
  @override
  State<BaselineLibraryPage> createState() => _BaselineLibraryPageState();
}

class _BaselineLibraryPageState extends State<BaselineLibraryPage> {
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

