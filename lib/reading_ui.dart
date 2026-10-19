part of 'main.dart';

/// Shared local, non-interactive atmosphere; all reading text remains real text.
class DevotionBackdrop extends StatelessWidget {
  const DevotionBackdrop({super.key,required this.palette,required this.child});
  final WirdPalette palette;
  final Widget child;
  @override
  Widget build(BuildContext context)=>ColoredBox(color:palette.homeBackground,child:Stack(children:[
    Positioned(top:0,left:0,right:0,height:240,child:IgnorePointer(child:Opacity(opacity:.14,child:Image.asset('assets/home/botanical-serenity.webp',fit:BoxFit.cover,excludeFromSemantics:true)))),
    Positioned.fill(child:DecoratedBox(decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[palette.homeBackground.withOpacity(.1),palette.homeBackground.withOpacity(.95)])))),
    child,
  ]));
}

class DevotionCard extends StatelessWidget {
  const DevotionCard({super.key,required this.child,this.padding=const EdgeInsets.all(18),this.color});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  @override
  Widget build(BuildContext context)=>Container(decoration:BoxDecoration(borderRadius:BorderRadius.circular(25),border:Border.all(color:homeGold.withOpacity(.6)),gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[color??Theme.of(context).colorScheme.surface,const Color(0xFF002B2B)]),boxShadow:const[BoxShadow(color:Color(0x20000000),blurRadius:16,offset:Offset(0,7))]),child:ClipRRect(borderRadius:BorderRadius.circular(24),child:CustomPaint(painter:const _DevotionCorners(),child:Padding(padding:padding,child:child))));
}

class _DevotionCorners extends CustomPainter {
  const _DevotionCorners();
  @override
  void paint(Canvas canvas,Size size){
    final paint=Paint()..color=homeGold.withOpacity(.12)..style=PaintingStyle.stroke..strokeWidth=.65;
    for(final right in [false,true]){
      canvas.save();if(right){canvas.translate(size.width,size.height);canvas.rotate(3.141592653589793);}
      for(var i=0;i<3;i++){final d=10.0+i*9;canvas.drawRect(Rect.fromLTWH(d,d,28,28),paint);canvas.save();canvas.translate(d+14,d+14);canvas.rotate(.7853981633974483);canvas.drawRect(const Rect.fromLTWH(-14,-14,28,28),paint);canvas.restore();}
      canvas.restore();
    }
  }
  @override
  bool shouldRepaint(covariant _DevotionCorners oldDelegate)=>false;
}

class DevotionCounter extends StatelessWidget {
  const DevotionCounter({super.key,required this.progress,required this.target,required this.palette});
  final int progress,target;
  final WirdPalette palette;
  @override
  Widget build(BuildContext context){
    final diameter=MediaQuery.textScalerOf(context).scale(1)>1.3?208.0:156.0;
    return Semantics(button:true,label:tr(context,'اضغط للعدّ'),value:'$progress / $target',child:Container(width:diameter,height:diameter,decoration:BoxDecoration(shape:BoxShape.circle,border:Border.all(color:homeGold.withOpacity(.4)),gradient:RadialGradient(center:const Alignment(-.4,-.5),colors:[homeGold.withOpacity(.2),palette.homeBackground],radius:1.1)),child:Stack(alignment:Alignment.center,children:[
      Positioned.fill(child:TweenAnimationBuilder<double>(tween:Tween(end:progress/target),duration:MediaQuery.disableAnimationsOf(context)?Duration.zero:const Duration(milliseconds:180),builder:(context,value,_)=>CircularProgressIndicator(value:value,strokeWidth:2,color:homeGold,backgroundColor:homeGold.withOpacity(.18)))),
      Padding(padding:const EdgeInsets.all(12),child:Column(mainAxisSize:MainAxisSize.min,children:[Icon(progress>=target?Icons.check_rounded:Icons.touch_app_outlined,color:homeGold,size:23),const SizedBox(height:5),Text('$progress / $target',textDirection:TextDirection.ltr,style:const TextStyle(color:homeCream,fontSize:24,fontWeight:FontWeight.w600)),const UiText('اضغط للعدّ',style:TextStyle(color:homeCream,fontSize:12))])),
    ])));
  }
}

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key,required this.store,this.initialFavorites=false});
  final WirdState store;
  final bool initialFavorites;
  @override State<LibraryPage> createState()=>_LibraryPageState();
}
class _LibraryPageState extends State<LibraryPage>{
  final search=TextEditingController();
  String query='';
  late bool favoriteOnly=widget.initialFavorites;
  @override void dispose(){search.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>AnimatedBuilder(animation:widget.store,builder:(context,_){
    final store=widget.store;final p=store.palette;
    final filtered=entries.where((e)=>(!favoriteOnly||store.favorites.contains(e.id))&&normalizeArabic('${e.title} ${e.arabic} ${sectionLabel(e.section)} ${uiString(sectionLabel(e.section),'en')} ${e.source}').contains(normalizeArabic(query))).toList();
    return SettingsStyle(palette:p,child:DevotionBackdrop(palette:p,child:CustomScrollView(key:const PageStorageKey('premium-library-scroll'),keyboardDismissBehavior:ScrollViewKeyboardDismissBehavior.onDrag,slivers:[
      SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.fromLTRB(20,24,20,20),child:Column(children:[
        const Icon(Icons.spa_outlined,color:homeGold,size:24),const SizedBox(height:10),
        const UiText('الأذكار',style:TextStyle(color:homeGold,fontSize:32,fontWeight:FontWeight.w600)),const SizedBox(height:6),
        const UiText('ابحث واقرأ واحفظ أذكارك المفضلة',textAlign:TextAlign.center,style:TextStyle(color:homeCream,fontSize:14,height:1.7)),const SizedBox(height:20),
        TextField(key:const Key('library-search'),controller:search,textDirection:Directionality.of(context),style:const TextStyle(color:homeCream,fontFamily:'NotoSansArabic'),onChanged:(value)=>setState(()=>query=value.trim()),decoration:InputDecoration(prefixIcon:const Icon(Icons.search_rounded,color:homeGold),suffixIcon:query.isEmpty?null:IconButton(tooltip:tr(context,'مسح البحث'),onPressed:(){search.clear();setState(()=>query='');},icon:const Icon(Icons.close,color:homeGold)),hintText:tr(context,'ابحث عن ذكر'),hintStyle:TextStyle(color:homeCream.withOpacity(.7)),filled:true,fillColor:p.homeSurface.withOpacity(.8),contentPadding:const EdgeInsets.symmetric(horizontal:20,vertical:16),enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(24),borderSide:BorderSide(color:homeGold.withOpacity(.55))),focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(24),borderSide:const BorderSide(color:homeGold,width:1.5)))),
        const SizedBox(height:16),Wrap(spacing:14,runSpacing:10,crossAxisAlignment:WrapCrossAlignment.center,children:[
          FilterChip(key:const Key('library-favorites'),avatar:Icon(favoriteOnly?Icons.favorite:Icons.favorite_border,color:homeGold,size:20),label:const UiText('المفضلة',style:TextStyle(color:homeCream)),selected:favoriteOnly,selectedColor:homeGold.withOpacity(.22),backgroundColor:p.homeBackground,side:BorderSide(color:homeGold.withOpacity(.65)),showCheckmark:false,onSelected:(v)=>setState(()=>favoriteOnly=v)),
          UiText('${filtered.length} ذكر',key:const Key('library-count'),style:TextStyle(color:homeCream.withOpacity(.85),fontSize:14)),
        ]),
      ]))),
      if(filtered.isEmpty)const SliverToBoxAdapter(child:Padding(padding:EdgeInsets.all(32),child:Column(children:[Icon(Icons.search_off_rounded,color:homeGold,size:34),SizedBox(height:12),UiText('لا توجد نتائج',style:TextStyle(color:homeCream,fontSize:18))]))),
      SliverPadding(padding:const EdgeInsets.fromLTRB(16,0,16,20),sliver:SliverList(delegate:SliverChildBuilderDelegate((context,index){
        final e=filtered[index];
        return Padding(padding:const EdgeInsets.only(bottom:12),child:DevotionCard(padding:EdgeInsets.zero,child:Material(color:Colors.transparent,child:InkWell(key:Key('library-entry-${e.id}'),borderRadius:BorderRadius.circular(25),onTap:()=>openReader(context,store,e.section,initial:inSection(e.section).indexWhere((x)=>x.id==e.id)),child:Padding(padding:const EdgeInsets.fromLTRB(12,18,8,18),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Container(width:44,height:44,decoration:BoxDecoration(shape:BoxShape.circle,color:homeGold.withOpacity(.08),border:Border.all(color:homeGold.withOpacity(.45))),child:Icon(e.isQuran?Icons.menu_book_outlined:Icons.auto_stories_outlined,color:homeGold,size:22)),const SizedBox(width:12),
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[UiText(e.title,style:const TextStyle(color:homeCream,fontSize:18,fontWeight:FontWeight.w600,height:1.7)),const SizedBox(height:5),UiText('${sectionLabel(e.section)} • ${e.source}',style:TextStyle(color:homeCream.withOpacity(.8),fontSize:12,height:1.85))])),
          IconButton(key:Key('library-bookmark-${e.id}'),tooltip:'${tr(context,'حفظ في المفضلة')} ${e.title}',onPressed:()=>store.toggleFavorite(e.id),icon:Icon(store.favorites.contains(e.id)?Icons.bookmark_rounded:Icons.bookmark_border_rounded,color:homeGold)),
        ]))))));
      },childCount:filtered.length))),
    ])));
  });
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
    return SettingsStyle(palette:p,child: AnnotatedRegion<SystemUiOverlayStyle>(value:SystemUiOverlayStyle.light,child: Scaffold(
      backgroundColor:p.homeBackground,
      appBar: AppBar(
        backgroundColor:p.homeBackground,foregroundColor:homeGold,surfaceTintColor:Colors.transparent,
        toolbarHeight:MediaQuery.textScalerOf(context).scale(1)>1.3?100:68,
        titleTextStyle:const TextStyle(fontFamily:"NotoSansArabic",fontSize:18,color:homeCream),
        title: UiText(sectionLabel(widget.section)),
        actions: [
          IconButton(
            tooltip: tr(context, 'مشاركة بطاقة'),
            onPressed: () async {
              try {
                await shareDhikrCard(
                  context,
                  e,
                  p.homeBackground,
                  homeCream,
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
      body: DevotionBackdrop(palette:p,child: SafeArea(top:false,child: Column(
        children: [
          if (!focus)
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 5, 22, 8),
              child: Row(
                children: [
                  UiText(
                    '${index + 1} / ${sectionEntries.length}',
                    textDirection: TextDirection.ltr,
                    style: TextStyle(color: homeCream),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (index + 1) / sectionEntries.length,
                      color: homeGold,
                      backgroundColor: p.homeSurface,
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView(
              key:ValueKey('reader-scroll-${e.id}'),
              padding: const EdgeInsets.fromLTRB(18, 13, 18, 18),
              children: [
                DevotionCard(
                  
                  padding: const EdgeInsets.all(23),
                  child: Column(
                    children: [
                      UiText(
                        e.title,
                        style: TextStyle(
                          color: homeGold,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SelectableText(
                        e.arabic,key:const Key('reader-arabic'),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: homeCream,
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
                          color: homeCream.withOpacity(.65),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!focus) ...[
                  const SizedBox(height: 12),
                  InkWell(
                    key:const Key('reader-evidence-toggle'),
                    onTap: () => setState(() => expanded = !expanded),
                    borderRadius: BorderRadius.circular(19),
                    child: DevotionCard(
                      child: Row(
                        children: [
                          Icon(Icons.menu_book_outlined, color: homeGold),
                          const SizedBox(width: 10),
                          Expanded(
                            child: UiText(
                              'الفضل والدليل والمعنى',
                              style: TextStyle(
                                color: homeCream,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(
                            expanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: homeGold,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (expanded)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: DevotionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            UiText(
                              'المعنى',
                              style: TextStyle(
                                color: homeGold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 7),
                            UiText(
                              e.meaning,
                              style: TextStyle(color: homeCream, height: 1.7),
                            ),
                            const SizedBox(height: 14),
                            UiText(
                              'الفضل',
                              style: TextStyle(
                                color: homeGold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 7),
                            UiText(
                              e.benefit,
                              style: TextStyle(color: homeCream, height: 1.7),
                            ),
                            const SizedBox(height: 14),
                            UiText(
                              'الدليل',
                              style: TextStyle(
                                color: homeGold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 7),
                            UiText(
                              e.evidence,
                              style: TextStyle(color: homeCream, height: 1.7),
                            ),
                            const SizedBox(height: 12),
                            UiText(e.timing, style: TextStyle(color: homeCream)),
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
                                color: homeGold,
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
                        key:const Key('reader-font-increase'),
                        tooltip: tr(context, 'تكبير الخط'),
                        onPressed: () =>
                            widget.store.changeFont(widget.store.fontSize + 2),
                        icon: Icon(Icons.text_increase, color: homeCream),
                      ),
                      IconButton(
                        key:const Key('reader-font-decrease'),
                        tooltip: tr(context, 'تصغير الخط'),
                        onPressed: () =>
                            widget.store.changeFont(widget.store.fontSize - 2),
                        icon: Icon(Icons.text_decrease, color: homeCream),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                if (e.countAlternatives.isNotEmpty)
                  Center(
                    child: Semantics(
                      label: tr(context, 'عدد التكرار'),
                      child: DropdownButton<int>(key:const Key('reader-count-choice'),dropdownColor:p.homeSurface,style:const TextStyle(color:homeCream,fontFamily:'NotoSansArabic'),
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
                    key:const Key('reader-counter'),
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
                    child: DevotionCounter(progress:progress,target:target,palette:p),
                  ),
                ),
                TextButton.icon(
                  key:const Key('reader-undo'),
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
                        color: homeCream.withOpacity(.7),
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 18),
                Wrap(
                  alignment:WrapAlignment.spaceBetween,spacing:12,runSpacing:12,
                  children: [
                    OutlinedButton.icon(
                      key:const Key('reader-previous'),
                      onPressed: index > 0
                          ? () => setState(() {
                              index--;
                              expanded = false;
                            })
                          : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: const UiText('السابق'),
                    ),
                    FilledButton.icon(
                      key:const Key('reader-next'),
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
    )))));
  }
}

