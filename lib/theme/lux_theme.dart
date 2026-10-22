// lib/theme/lux_theme.dart
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

/// Design tokens that sit alongside Material's ColorScheme.
/// Read them with `context.lux`.
@immutable
class LuxColors extends ThemeExtension<LuxColors> {
  final Color bg;
  final Color panel;
  final Color panel2;
  final Color line;
  final Color text;
  final Color mute;
  final Color accent;
  final Color onAccent;
  final Color ok;
  final Color warn;
  final Color bad;
  final Color stageInner;
  final Color stageOuter;

  const LuxColors({
    required this.bg,
    required this.panel,
    required this.panel2,
    required this.line,
    required this.text,
    required this.mute,
    required this.accent,
    required this.onAccent,
    required this.ok,
    required this.warn,
    required this.bad,
    required this.stageInner,
    required this.stageOuter,
  });

  static const light = LuxColors(
    bg: Color(0xFFF5F3EF),
    panel: Color(0xFFFFFFFF),
    panel2: Color(0xFFF0EDE6),
    line: Color(0xFFDCD8CE),
    text: Color(0xFF121315),
    mute: Color(0xFF66625A),
    accent: Color(0xFF7A5C28),
    onAccent: Color(0xFFFFFFFF),
    ok: Color(0xFF2B7553),
    warn: Color(0xFF8F6410),
    bad: Color(0xFFAE3F35),
    stageInner: Color(0xFFFFFFFF),
    stageOuter: Color(0xFFECE9E1),
  );

  static const dark = LuxColors(
    bg: Color(0xFF0B0C0D),
    panel: Color(0xFF131416),
    panel2: Color(0xFF1A1B1E),
    line: Color(0xFF2A2B2F),
    text: Color(0xFFEEEAE2),
    mute: Color(0xFFA09C93),
    accent: Color(0xFFC8AE7B),
    onAccent: Color(0xFF0B0C0D),
    ok: Color(0xFF8FC7AB),
    warn: Color(0xFFE0B572),
    bad: Color(0xFFE79C90),
    stageInner: Color(0xFF2A2B31),
    stageOuter: Color(0xFF0F1012),
  );

  /// Soft studio backdrop used behind watch photography.
  Gradient get stage => RadialGradient(
        center: const Alignment(0, -0.2),
        radius: 0.95,
        colors: [stageInner, stageOuter],
      );

  @override
  LuxColors copyWith({
    Color? bg,
    Color? panel,
    Color? panel2,
    Color? line,
    Color? text,
    Color? mute,
    Color? accent,
    Color? onAccent,
    Color? ok,
    Color? warn,
    Color? bad,
    Color? stageInner,
    Color? stageOuter,
  }) {
    return LuxColors(
      bg: bg ?? this.bg,
      panel: panel ?? this.panel,
      panel2: panel2 ?? this.panel2,
      line: line ?? this.line,
      text: text ?? this.text,
      mute: mute ?? this.mute,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      ok: ok ?? this.ok,
      warn: warn ?? this.warn,
      bad: bad ?? this.bad,
      stageInner: stageInner ?? this.stageInner,
      stageOuter: stageOuter ?? this.stageOuter,
    );
  }

  @override
  LuxColors lerp(ThemeExtension<LuxColors>? other, double t) {
    if (other is! LuxColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return LuxColors(
      bg: l(bg, other.bg),
      panel: l(panel, other.panel),
      panel2: l(panel2, other.panel2),
      line: l(line, other.line),
      text: l(text, other.text),
      mute: l(mute, other.mute),
      accent: l(accent, other.accent),
      onAccent: l(onAccent, other.onAccent),
      ok: l(ok, other.ok),
      warn: l(warn, other.warn),
      bad: l(bad, other.bad),
      stageInner: l(stageInner, other.stageInner),
      stageOuter: l(stageOuter, other.stageOuter),
    );
  }
}

extension LuxContext on BuildContext {
  /// Falls back to the matching palette when a plain Material theme is in use
  /// (previews, tests), so widgets never depend on LuxTheme being installed.
  LuxColors get lux {
    final theme = Theme.of(this);
    return theme.extension<LuxColors>() ??
        (theme.brightness == Brightness.dark
            ? LuxColors.dark
            : LuxColors.light);
  }
}

/// Font families bundled in assets/fonts.
class LuxFonts {
  static const display = 'Cormorant Garamond';
  static const sans = 'Hanken Grotesk';
  static const mono = 'DM Mono';
}

class LuxTheme {
  static ThemeData light() => _build(LuxColors.light, Brightness.light);
  static ThemeData dark() => _build(LuxColors.dark, Brightness.dark);

  static ThemeData _build(LuxColors c, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.accent,
      onPrimary: c.onAccent,
      secondary: c.accent,
      onSecondary: c.onAccent,
      error: c.bad,
      onError: c.onAccent,
      surface: c.panel,
      onSurface: c.text,
      surfaceContainerHighest: c.panel2,
      outline: c.line,
      outlineVariant: c.line,
    );

    const radius = BorderRadius.all(Radius.circular(2));
    final border = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: c.line),
    );

    TextStyle display(double size, FontWeight w) => TextStyle(
          fontFamily: LuxFonts.display,
          fontSize: size,
          fontWeight: w,
          color: c.text,
          height: 1.05,
        );
    TextStyle sans(double size, FontWeight w, {Color? color, double? ls}) =>
        TextStyle(
          fontFamily: LuxFonts.sans,
          fontSize: size,
          fontWeight: w,
          color: color ?? c.text,
          letterSpacing: ls,
        );

    final textTheme = TextTheme(
      displayLarge: display(64, FontWeight.w300),
      displayMedium: display(52, FontWeight.w300),
      displaySmall: display(42, FontWeight.w300),
      headlineLarge: display(40, FontWeight.w300),
      headlineMedium: display(34, FontWeight.w400),
      headlineSmall: display(28, FontWeight.w400),
      titleLarge: display(24, FontWeight.w500),
      titleMedium: sans(16, FontWeight.w600),
      titleSmall: sans(14, FontWeight.w600),
      bodyLarge: sans(16, FontWeight.w400),
      bodyMedium: sans(14, FontWeight.w400),
      bodySmall: sans(12, FontWeight.w400, color: c.mute),
      labelLarge: sans(13, FontWeight.w600, ls: 1.6),
      labelMedium: sans(12, FontWeight.w500),
      labelSmall: sans(10.5, FontWeight.w500, color: c.mute, ls: 2.2),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
      canvasColor: c.bg,
      fontFamily: LuxFonts.sans,
      textTheme: textTheme,
      dividerColor: c.line,
      dividerTheme: DividerThemeData(color: c.line, space: 1, thickness: 1),
      extensions: [c],
      appBarTheme: AppBarTheme(
        backgroundColor: c.bg,
        foregroundColor: c.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: display(26, FontWeight.w400),
        shape: Border(bottom: BorderSide(color: c.line)),
      ),
      cardTheme: CardThemeData(
        color: c.panel,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: c.line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.accent,
          foregroundColor: c.onAccent,
          minimumSize: const Size(0, 52),
          shape: const RoundedRectangleBorder(borderRadius: radius),
          textStyle: sans(13, FontWeight.w600, ls: 1.8),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.text,
          minimumSize: const Size(0, 52),
          side: BorderSide(color: c.line),
          shape: const RoundedRectangleBorder(borderRadius: radius),
          textStyle: sans(13, FontWeight.w600, ls: 1.8),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accent,
          textStyle: sans(13, FontWeight.w600, ls: 1.2),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: c.text),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.panel,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: c.accent, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: c.bad),
        ),
        labelStyle: sans(14, FontWeight.w400, color: c.mute),
        hintStyle: sans(14, FontWeight.w400, color: c.mute),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.bg,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        elevation: 0,
        height: 72,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? c.accent : c.mute, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return sans(11, FontWeight.w500,
              color: selected ? c.accent : c.mute, ls: 0.6);
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.bg,
        selectedColor: c.text,
        side: BorderSide(color: c.line),
        shape: const StadiumBorder(),
        labelStyle: sans(13, FontWeight.w500),
        secondaryLabelStyle: sans(13, FontWeight.w600, color: c.bg),
        showCheckmark: false,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.text,
        contentTextStyle: sans(14, FontWeight.w500, color: c.bg),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: radius),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.panel,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: radius),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.accent),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
