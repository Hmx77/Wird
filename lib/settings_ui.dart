part of 'main.dart';

const settingsPrivacyCopy = 'لا حسابات ولا إعلانات ولا تحليلات ولا قاعدة بيانات خارجية. تحفظ المتابعة على جهازك. أضف ودجت ورد من الشاشة الرئيسية. الصوت لا يتاح إلا بعد اعتماد التسجيل وترخيصه. أوقات التذكير اختيار شخصي وليست تحديدًا شرعيًا.';

/// Uses the existing preference setters; no data migration or new storage keys.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.store});
  final WirdState store;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: store, builder: (context, _) {
    final p = store.palette;
    return SettingsStyle(palette: p, child: ColoredBox(color: p.homeBackground,
      child: SingleChildScrollView(key: const PageStorageKey('settings-scroll'), child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _SettingsHeader(palette: p),
          Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 28), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if(store.storageError != null) Padding(padding: const EdgeInsets.all(12), child: UiText(store.storageError!)),
            SettingsPanel(child: _SettingsControl(icon: Icons.language_rounded, title: 'اللغة', subtitle: 'اختر لغة التطبيق', control: DropdownButtonHideUnderline(child: DropdownButton<String>(
              key: const Key('language-picker'), value: store.languageCode, dropdownColor: p.homeSurface,
              style: const TextStyle(color: homeCream, fontFamily: 'NotoSansArabic', fontSize: 15),
              items: const [DropdownMenuItem(value:'ar',child: Text('العربية')),DropdownMenuItem(value:'en',child:Text('English'))],
              onChanged: (v) {if(v!=null) store.changeLanguage(v);},
            )))),
            if(store.languageCode=='en') const Padding(padding: EdgeInsets.symmetric(vertical:8),child:UiText('النص الديني بالعربية؛ الترجمة الإنجليزية قيد المراجعة.',style:TextStyle(color:homeCream,fontSize:12))),
            const SizedBox(height:10),
            SettingsPanel(highlighted:true, child: InkWell(key:const Key('appearance-picker'),borderRadius:BorderRadius.circular(22), onTap:()=>_appearance(context),child:_SettingsControl(icon:Icons.palette_outlined,title:'المظهر',subtitle:themes[store.themeIndex].name,
              control: Row(mainAxisSize:MainAxisSize.min,children:[...{store.themeIndex,5,9}.take(3).map((i)=>Padding(padding:const EdgeInsets.all(3),child:Container(width:28,height:28,decoration:BoxDecoration(shape:BoxShape.circle,color:themes[i].primary,border:Border.all(color:i==store.themeIndex?homeGold:homeCream.withOpacity(.3),width:i==store.themeIndex?2:1))))),Icon(Directionality.of(context)==TextDirection.rtl?Icons.chevron_left:Icons.chevron_right,size:18)])))),
            const SizedBox(height:12),
            const ReminderPanel(),
            const SizedBox(height:12),
            SettingsPanel(highlighted:true, child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
              const SettingsHeading('حجم الخط',icon:Icons.text_fields_rounded),
              Row(children:[const Text('Aa',style:TextStyle(color:homeGold,fontSize:14)),Expanded(child:Slider(key:const Key('reading-font-slider'),value:store.fontSize,min:19,max:38,divisions:19,label:'${store.fontSize.round()}',onChanged:store.changeFont)),Text('${store.fontSize.round()}',style:const TextStyle(color:homeGold,fontSize:18))]),
              Container(key:const Key('reading-font-preview'),padding:const EdgeInsets.all(14),decoration:BoxDecoration(borderRadius:BorderRadius.circular(18),border:Border.all(color:homeGold.withOpacity(.32)),color:p.homeBackground.withOpacity(.55)),child:UiText('هذا مثال على حجم القراءة',style:TextStyle(fontSize:store.fontSize,color:homeCream,height:1.7),textAlign:TextAlign.center)),
            ])),
            const SizedBox(height:12),
            SettingsPanel(highlighted:true,child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
              const SettingsHeading('السبحة الشخصية',icon:Icons.grain_rounded),
              const SizedBox(height:8),
              const UiText('هدف شخصي، وليس عددًا تعبديًا منصوصًا.',style:TextStyle(color:homeCream,fontSize:12,height:1.8)),
              const SizedBox(height:12),
              LayoutBuilder(builder:(context,c){
                final counter=Container(padding:const EdgeInsets.symmetric(vertical:16,horizontal:24),decoration:BoxDecoration(borderRadius:BorderRadius.circular(22),border:Border.all(color:homeGold.withOpacity(.3)),gradient:RadialGradient(colors:[p.homeAccent.withOpacity(.15),p.homeBackground])),child:Semantics(liveRegion:true,label:tr(context,'السبحة الشخصية'),child:Text('${store.tasbih}',key:const Key('settings-tasbih-value'),textAlign:TextAlign.center,style:const TextStyle(color:homeCream,fontSize:46,height:1.3,fontWeight:FontWeight.w500))));
                final buttons=Wrap(spacing:10,runSpacing:8,alignment:WrapAlignment.center,children:[
                  FilledButton.icon(key:const Key('settings-tasbih-add'),onPressed:(){store.setTasbih(store.tasbih+1);if(store.haptics) unawaited(HapticFeedback.selectionClick());},icon:const Icon(Icons.add,size:18),label:const UiText('تسبيح +')),
                  OutlinedButton.icon(key:const Key('settings-tasbih-reset'),onPressed:()=>store.setTasbih(0),icon:const Icon(Icons.restart_alt,size:18),label:const UiText('إعادة'))]);
                if(c.maxWidth<320 || MediaQuery.textScalerOf(context).scale(1)>1.3) return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[counter,const SizedBox(height:12),buttons]);
                return Row(children:[Expanded(flex:2,child:buttons),const SizedBox(width:16),Expanded(child:counter)]);
              }),
            ])),
            const SizedBox(height:12),
            SettingsPanel(child:Column(children:[
              _SettingsControl(icon:Icons.vibration_rounded,title:'اهتزاز خفيف عند العد',control:Semantics(label:tr(context,'اهتزاز خفيف عند العد'),child:Switch(key:const Key('haptics-switch'),value:store.haptics,onChanged:(v)=>store.preferences(feedback:v)))),
              const Divider(height:18,color:Color(0x335F9D92)),
              _SettingsControl(icon:Icons.skip_next_rounded,title:'الانتقال تلقائيًا بعد إكمال الذكر',control:Semantics(label:tr(context,'الانتقال تلقائيًا بعد إكمال الذكر'),child:Switch(key:const Key('auto-advance-switch'),value:store.autoAdvance,onChanged:(v)=>store.preferences(advance:v)))),
            ])),
            const SizedBox(height:12),
            SettingsPanel(highlighted:true,child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
              const SettingsHeading('خصوصيتك ومصادرك',icon:Icons.verified_user_outlined),
              const SizedBox(height:10),
              const UiText('تحفظ المتابعة على جهازك.',style:TextStyle(color:homeCream,height:1.8,fontSize:13)),
              ExpansionTile(key:const Key('privacy-details'),tilePadding:EdgeInsets.zero,childrenPadding:const EdgeInsets.only(bottom:14),title:const UiText('التفاصيل والمصادر',style:TextStyle(color:homeGold,fontSize:14)),children:const[UiText(settingsPrivacyCopy,style:TextStyle(color:homeCream,height:1.9,fontSize:13))]),
              _SettingsAction(key:const Key('settings-licenses'),icon:Icons.description_outlined,title:'تراخيص البرمجيات',onTap:()=>showLicensePage(context:context,applicationName:'ورد — Wird')),
              const Divider(color:Color(0x335F9D92)),
              _SettingsAction(key:const Key('settings-erase'),icon:Icons.delete_outline_rounded,title:'مسح بياناتي المحلية',onTap:()=>_erase(context)),
            ])),
          ])),
        ]),
      ))),
    ));
  });

  Future<void> _appearance(BuildContext context) => showModalBottomSheet<void>(context:context,isScrollControlled:true,backgroundColor:store.palette.homeSurface,showDragHandle:true,builder:(c)=>SettingsStyle(palette:store.palette,child:SafeArea(child:ConstrainedBox(constraints:BoxConstraints(maxHeight:MediaQuery.sizeOf(c).height*.8),child:SingleChildScrollView(padding:const EdgeInsets.fromLTRB(20,0,20,24),child:Column(children:[
    const SettingsHeading('المظهر',icon:Icons.palette_outlined),const SizedBox(height:12),
    ...themes.indexed.map((e)=>RadioListTile<int>(key:Key('settings-theme-${e.$1}'),value:e.$1,groupValue:store.themeIndex,activeColor:homeGold,secondary:Container(width:36,height:36,decoration:BoxDecoration(color:e.$2.primary,borderRadius:BorderRadius.circular(12),border:Border.all(color:homeGold.withOpacity(.5)))),title:UiText(e.$2.name,style:const TextStyle(color:homeCream,fontSize:14)),onChanged:(i){if(i!=null)store.changeTheme(i);Navigator.pop(c);})),
  ]))))));

  Future<void> _erase(BuildContext context) async {
    final confirmed=await showDialog<bool>(context:context,builder:(c)=>SettingsStyle(palette:store.palette,child:AlertDialog(
      backgroundColor:store.palette.homeSurface,title:const UiText('مسح المتابعة والمفضلة؟',style:TextStyle(color:homeCream)),
      content:const UiText('سيمسح تقدم القراءة والمفضلة وتتبع الصلاة والسبحة الشخصية. لا يمكن التراجع. تبقى إعدادات المظهر والتذكيرات.',style:TextStyle(color:homeCream,height:1.8)),
      actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const UiText('إلغاء')),TextButton(key:const Key('confirm-local-erase'),onPressed:()=>Navigator.pop(c,true),child:const UiText('مسح'))],
    )));
    if(confirmed==true) {try{await store.erase();}catch(_){if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:UiText('تعذر مسح البيانات. حاول مجددًا.')));}}
  }
}

class SettingsStyle extends StatelessWidget {
  const SettingsStyle({super.key,required this.palette,required this.child});
  final WirdPalette palette;
  final Widget child;
  @override
  Widget build(BuildContext context) => Theme(data:Theme.of(context).copyWith(
    colorScheme:ColorScheme.dark(primary:homeGold,onPrimary:const Color(0xFF173A36),surface:palette.homeSurface,onSurface:homeCream,secondary:palette.homeAccent),
    iconTheme:const IconThemeData(color:homeGold),
    textTheme:Theme.of(context).textTheme.apply(bodyColor:homeCream,displayColor:homeCream),
    switchTheme:SwitchThemeData(thumbColor:const WidgetStatePropertyAll(homeCream),trackColor:WidgetStateProperty.resolveWith((s)=>s.contains(WidgetState.selected)?const Color(0xFFB99A54):palette.homeBackground),trackOutlineColor:WidgetStatePropertyAll(homeGold.withOpacity(.4))),
    sliderTheme:SliderTheme.of(context).copyWith(activeTrackColor:homeGold,thumbColor:homeGold,inactiveTrackColor:homeCream.withOpacity(.25),overlayColor:homeGold.withOpacity(.12)),
    filledButtonTheme:FilledButtonThemeData(style:FilledButton.styleFrom(backgroundColor:homeGold,foregroundColor:const Color(0xFF173A36),padding:const EdgeInsets.symmetric(horizontal:12),minimumSize:const Size(48,48),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(17)))),
    outlinedButtonTheme:OutlinedButtonThemeData(style:OutlinedButton.styleFrom(foregroundColor:homeGold,padding:const EdgeInsets.symmetric(horizontal:12),side:BorderSide(color:homeGold.withOpacity(.65)),minimumSize:const Size(48,48),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(17)))),
    textButtonTheme:TextButtonThemeData(style:TextButton.styleFrom(foregroundColor:homeGold,minimumSize:const Size(48,48))),
    dividerTheme:const DividerThemeData(color:Color(0x335F9D92)),
  ),child:child);
}

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key,required this.child,this.highlighted=false});
  final Widget child;
  final bool highlighted;
  @override
  Widget build(BuildContext context) => Container(padding:const EdgeInsets.all(16),clipBehavior:Clip.antiAlias,decoration:BoxDecoration(
    borderRadius:BorderRadius.circular(24),border:Border.all(color:highlighted?homeGold.withOpacity(.6):const Color(0x665F9D92)),
    gradient:LinearGradient(begin:Alignment.topRight,end:Alignment.bottomLeft,colors:[Theme.of(context).colorScheme.surface, const Color(0xFF002C2C)]),
    boxShadow:[BoxShadow(color:Colors.black.withOpacity(.15),blurRadius:18,offset:const Offset(0,6))],
  ),child:CustomPaint(painter:highlighted?const _SettingsOrnament():null,child:child));
}

class SettingsHeading extends StatelessWidget {
  const SettingsHeading(this.title,{super.key,required this.icon});
  final String title;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Row(children:[_SettingsMedallion(icon),const SizedBox(width:12),Expanded(child:UiText(title,style:const TextStyle(color:homeCream,fontSize:20,fontWeight:FontWeight.w600)))]);
}
class _SettingsMedallion extends StatelessWidget {
  const _SettingsMedallion(this.icon);
  final IconData icon;
  @override
  Widget build(BuildContext context)=>Container(width:44,height:44,decoration:BoxDecoration(borderRadius:BorderRadius.circular(17),border:Border.all(color:homeGold.withOpacity(.35)),gradient:const LinearGradient(colors:[Color(0xFF294944),Color(0xFF092D2C)])),child:Icon(icon,color:homeGold,size:23));
}
class _SettingsControl extends StatelessWidget {
  const _SettingsControl({required this.icon,required this.title,required this.control,this.subtitle});
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget control;
  @override
  Widget build(BuildContext context)=>LayoutBuilder(builder:(context,c){
    final label=Row(children:[_SettingsMedallion(icon),const SizedBox(width:11),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[UiText(title,style:const TextStyle(color:homeCream,fontSize:16,height:1.7)),if(subtitle!=null)UiText(subtitle!,style:TextStyle(color:homeCream.withOpacity(.72),fontSize:12,height:1.7))]))]);
    if(c.maxWidth<300 && MediaQuery.textScalerOf(context).scale(1)>1.3) return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[label,Align(alignment:AlignmentDirectional.centerEnd,child:control)]);
    return Row(children:[Expanded(child:label),const SizedBox(width:8),control]);
  });
}
class _SettingsAction extends StatelessWidget {
  const _SettingsAction({super.key,required this.title,required this.icon,required this.onTap});
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context)=>InkWell(onTap:onTap,borderRadius:BorderRadius.circular(16),child:Padding(padding:const EdgeInsets.symmetric(vertical:8),child:Row(children:[_SettingsMedallion(icon),const SizedBox(width:12),Expanded(child:UiText(title,style:const TextStyle(color:homeCream,fontSize:15,height:1.8))),Icon(Directionality.of(context)==TextDirection.rtl?Icons.chevron_left:Icons.chevron_right,color:homeGold,size:20)])));
}
class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.palette});
  final WirdPalette palette;
  @override
  Widget build(BuildContext context)=>Stack(children:[
    Positioned.fill(child:ExcludeSemantics(child:Opacity(opacity:.28,child:Image.asset('assets/home/botanical-serenity.webp',fit:BoxFit.cover,alignment:Alignment.topLeft)))),
    Positioned.fill(child:DecoratedBox(decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[palette.homeBackground.withOpacity(.25),palette.homeBackground])))),
    Padding(padding:const EdgeInsets.fromLTRB(24,32,24,26),child:Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const UiText('الإعدادات',style:TextStyle(color:homeGold,fontSize:34,height:1.5,fontWeight:FontWeight.w500)),const SizedBox(height:4),UiText('المظهر والقراءة والخصوصية',style:TextStyle(color:homeCream.withOpacity(.85),fontSize:14,height:1.8))])),const SizedBox(width:12),const Icon(Icons.spa_outlined,color:homeGold,size:31)])),
  ]);
}

// Decorative only: light interlaced squares, clipped inside each card.
class _SettingsOrnament extends CustomPainter {
  const _SettingsOrnament();
  @override
  void paint(Canvas canvas, Size size) {
    final paint=Paint()..color=homeGold.withOpacity(.065)..style=PaintingStyle.stroke..strokeWidth=.7;
    canvas.save();canvas.clipRect(Offset.zero & size);
    for(var row=0;row<3;row++) {
      for(var col=0;col<3;col++) {
        canvas.save();canvas.translate(col*24.0-12,row*24.0-12);
        canvas.drawRect(const Rect.fromLTWH(-14,-14,28,28),paint);
        canvas.rotate(.7853981634);canvas.drawRect(const Rect.fromLTWH(-14,-14,28,28),paint);canvas.restore();
      }
    }
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant _SettingsOrnament oldDelegate)=>false;
}
