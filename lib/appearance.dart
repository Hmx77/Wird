part of 'main.dart';

/// Stable persisted IDs are independent of the retired ten-item index list.
const appearancePreference = 'appearance.v2';
const appearanceIds = ['midnight-teal', 'ivory-serenity'];
int migratedAppearance(int? legacy) => switch (legacy) {
  0 || 1 || 2 || 3 || 4 || 7 || 9 => 1,
  _ => 0, // Previous signature Stone & Teal, dark variants, invalid/new users.
};

/// Opaque reading/control roles. Decorative artwork never supplies text contrast.
abstract final class IvoryContrast {
  static const ink = Color(0xFF103B2C);
  static const muted = Color(0xFF465A45);
  static const gold = Color(0xFF77551E);
  static const accent = Color(0xFF2F6548);
  static const outline = Color(0xFF88713E);
  static const border = Color(0xFFB7A778);
  static const cream = Color(0xFFFFF8E8);
  static const sage = Color(0xFFE5ECD9);
  static const selected = Color(0xFFF2E6C9);
  static const progressTrack = Color(0xFFC5CFB7);
  // Over the darkest possible image pixel this still yields a light backing.
  static Color get readingBacking => cream.withValues(alpha: .96);
}

class AppAppearance extends ThemeExtension<AppAppearance> {
  const AppAppearance(this.palette);
  final WirdPalette palette;
  bool get dark => palette.dark;
  Color get ink => dark ? homeCream : IvoryContrast.ink;
  Color get muted => dark ? const Color(0xFFCAD9D3) : IvoryContrast.muted;
  Color get gold => dark ? homeGold : IvoryContrast.gold;
  Color get accent => dark ? const Color(0xFF86D8C8) : IvoryContrast.accent;
  Color get surface => palette.homeSurface;
  Color get background => palette.homeBackground;
  static AppAppearance of(BuildContext context) =>
      Theme.of(context).extension<AppAppearance>() ?? AppAppearance(themes.first);
  @override
  AppAppearance copyWith({WirdPalette? palette}) => AppAppearance(palette ?? this.palette);
  @override
  AppAppearance lerp(covariant AppAppearance? other, double t) =>
      t < .5 || other == null ? this : other;
}

/// Coordinated presentation roles for the approved legacy gradient stops.
/// The dark value stays exact. Ivory uses parchment/sage, never an RGB inverse.
Color appearanceTone(BuildContext context, int argb) {
  final a = AppAppearance.of(context);
  final original = Color(argb);
  if (a.dark) return original;
  final rgb = argb & 0xffffff;
  final alpha = (argb >> 24) & 255;
  final role = switch (rgb) {
    0x000000 => const Color(0xFF433A22),
    0xF5EAD0 || 0xF3EEDF || 0xE3E0D5 => a.ink,
    0xCAD9D3 || 0xB5CBC3 => a.muted,
    0xE4C47E || 0xB99A54 || 0xB49352 => a.gold,
    0x86D8C8 || 0x7DDBCA || 0x85BCB2 || 0x6DB9AF => a.accent,
    0x002128 || 0x002B2B || 0x00262B || 0x002C32 || 0x031C1B ||
    0x082924 || 0x092724 || 0x073035 || 0x07373D || 0x083035 => a.background,
    0x173A36 || 0x143D3D || 0x122D27 || 0x123C31 || 0x31565A => const Color(0xFFE6DFC8),
    0x3F6651 => const Color(0xFFF9F1DB),
    0xFFE7AC || 0xFFE5A1 => const Color(0xFFEBD69F),
    0xA1824C || 0xDEC38D => const Color(0xFFAD9158),
    _ => original.computeLuminance() < .16
        ? a.surface
        : original.computeLuminance() > .60
            ? a.ink
            : a.accent,
  };
  return role.withAlpha(alpha);
}

const ivorySanctuary = AssetImage('assets/appearance/ivory-sanctuary.webp');
AssetImage appearanceArt(BuildContext context, AssetImage darkArt) =>
    AppAppearance.of(context).dark ? darkArt : ivorySanctuary;
String botanicalAsset(BuildContext context) => AppAppearance.of(context).dark
    ? 'assets/home/botanical-serenity.webp'
    : 'assets/appearance/ivory-sanctuary.webp';

/// Owned original lettering is preserved; only its alpha silhouette is colored.
class AppearanceWordmark extends StatelessWidget {
  const AppearanceWordmark({super.key, this.width = 146, this.height = 96});
  final double width, height;
  @override
  Widget build(BuildContext context) {
    final original = Image(image: wirdWordmark, width: width, height: height,
      fit: BoxFit.contain, gaplessPlayback: true);
    if (AppAppearance.of(context).dark) return original;
    return ShaderMask(blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF2F6548), Color(0xFF194A34), Color(0xFF103B2C)],
        stops: [0, .35, 1],
      ).createShader(bounds), child: original);
  }
}


/// Preserve reading geometry; Ivory contrast is painted by the full card's
/// integrated gradient, never by a separate rectangular text panel.
class IvoryReadingBacking extends StatelessWidget {
  const IvoryReadingBacking({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => AppAppearance.of(context).dark ? child :
    Padding(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), child: child);
}
