import 'package:flutter/material.dart';

const kFont = 'Poppins';

// Surfaces (neutral graphite, no gradients)
const kBg = Color(0xFF0B0D10);
const kSurface = Color(0xFF14171C);
const kSurface2 = Color(0xFF1B1F26);
const kBorder = Color(0xFF262B34);
const kSelected = Color(0xFF2C323D);

// Text
const kText = Color(0xFFF2F4F7);
const kMuted = Color(0xFF9099A8);
const kFaint = Color(0xFF626B7A);

// Brand + semantic
const kAccent = Color(0xFFC4F03F);
const kOnAccent = Color(0xFF0B0D10);
const kDanger = Color(0xFFFF6B6B);
const kBlue = Color(0xFF5B9DFF);

const kMuscleColors = <String, Color>{
  'Chest': Color(0xFFFF7A59),
  'Back': Color(0xFF5B9DFF),
  'Legs': Color(0xFFC4F03F),
  'Shoulders': Color(0xFFB18CFF),
  'Arms': Color(0xFF3DD6C6),
  'Core': Color(0xFFFFD166),
  'Other': Color(0xFF7C8594),
};

Color muscleColor(String m) => kMuscleColors[m] ?? kMuscleColors['Other']!;

/// Text styles used across the app.
class Txt {
  static const h1 = TextStyle(
      fontFamily: kFont, fontSize: 26, fontWeight: FontWeight.w700,
      height: 1.25, letterSpacing: -0.5, color: kText);
  static const h2 = TextStyle(
      fontFamily: kFont, fontSize: 20, fontWeight: FontWeight.w700,
      height: 1.3, letterSpacing: -0.3, color: kText);
  static const title = TextStyle(
      fontFamily: kFont, fontSize: 15, fontWeight: FontWeight.w500,
      height: 1.4, color: kText);
  static const titleBold = TextStyle(
      fontFamily: kFont, fontSize: 15, fontWeight: FontWeight.w700,
      height: 1.4, color: kText);
  static const body = TextStyle(
      fontFamily: kFont, fontSize: 14, fontWeight: FontWeight.w400,
      height: 1.5, color: kText);
  static const caption = TextStyle(
      fontFamily: kFont, fontSize: 12, fontWeight: FontWeight.w400,
      height: 1.45, color: kMuted);
  static const label = TextStyle(
      fontFamily: kFont, fontSize: 11, fontWeight: FontWeight.w500,
      height: 1.3, letterSpacing: 0.9, color: kMuted);
  static const stat = TextStyle(
      fontFamily: kFont, fontSize: 24, fontWeight: FontWeight.w700,
      height: 1.2, letterSpacing: -0.4, color: kText);
  static const statLg = TextStyle(
      fontFamily: kFont, fontSize: 34, fontWeight: FontWeight.w700,
      height: 1.15, letterSpacing: -0.8, color: kText);
  static const axis = TextStyle(
      fontFamily: kFont, fontSize: 10.5, fontWeight: FontWeight.w400,
      color: kFaint);
  static const tooltip = TextStyle(
      fontFamily: kFont, fontSize: 12, fontWeight: FontWeight.w500,
      color: kText);
  static const button = TextStyle(
      fontFamily: kFont, fontSize: 14, fontWeight: FontWeight.w700,
      letterSpacing: 0.2);
}

TextTheme _textTheme() => const TextTheme(
      headlineMedium: Txt.h1,
      headlineSmall: Txt.h2,
      titleLarge: Txt.h2,
      titleMedium: Txt.title,
      titleSmall: Txt.title,
      bodyLarge: Txt.body,
      bodyMedium: Txt.body,
      bodySmall: Txt.caption,
      labelLarge: Txt.button,
      labelMedium: Txt.caption,
      labelSmall: Txt.label,
    );

ThemeData buildTheme() {
  final scheme = ColorScheme.dark(
    primary: kAccent,
    onPrimary: kOnAccent,
    secondary: kBlue,
    onSecondary: kOnAccent,
    surface: kSurface,
    onSurface: kText,
    error: kDanger,
    onError: kOnAccent,
    outline: kBorder,
    outlineVariant: kBorder,
  );

  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c, width: w),
      );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: kFont,
    colorScheme: scheme,
    scaffoldBackgroundColor: kBg,
    canvasColor: kSurface,
    textTheme: _textTheme(),
    dividerTheme: const DividerThemeData(color: kBorder, thickness: 1, space: 1),
    appBarTheme: const AppBarTheme(
      backgroundColor: kBg,
      surfaceTintColor: Colors.transparent,
      foregroundColor: kText,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: Txt.titleBold,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: kAccent),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kAccent,
        foregroundColor: kOnAccent,
        disabledBackgroundColor: kSurface2,
        disabledForegroundColor: kFaint,
        minimumSize: const Size(0, 50),
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: Txt.button,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kText,
        minimumSize: const Size(0, 50),
        side: const BorderSide(color: kBorder),
        textStyle: Txt.button,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kAccent,
        textStyle: Txt.button,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: kMuted),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurface2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      labelStyle: Txt.caption.copyWith(fontSize: 14),
      floatingLabelStyle: Txt.caption.copyWith(color: kAccent),
      hintStyle: Txt.body.copyWith(color: kFaint),
      prefixIconColor: kMuted,
      suffixIconColor: kMuted,
      border: border(kBorder),
      enabledBorder: border(kBorder),
      focusedBorder: border(kAccent, 1.4),
      errorBorder: border(kDanger),
      focusedErrorBorder: border(kDanger, 1.4),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: kSurface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: Txt.h2,
      contentTextStyle: Txt.body.copyWith(color: kMuted),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: kBorder),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: kSurface,
      modalBackgroundColor: kSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: kSelected,
      contentTextStyle: Txt.body,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? kOnAccent : kMuted),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? kAccent : kSurface2),
      trackOutlineColor: WidgetStateProperty.all(kBorder),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: kSurface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: kAccent.withValues(alpha: 0.14),
      elevation: 0,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
            fontFamily: kFont,
            fontSize: 11,
            fontWeight: s.contains(WidgetState.selected)
                ? FontWeight.w500
                : FontWeight.w400,
            color: s.contains(WidgetState.selected) ? kAccent : kMuted,
          )),
      iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
            size: 24,
            color: s.contains(WidgetState.selected) ? kAccent : kMuted,
          )),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: kBg,
      indicatorColor: kAccent.withValues(alpha: 0.14),
      selectedIconTheme: const IconThemeData(color: kAccent),
      unselectedIconTheme: const IconThemeData(color: kMuted),
      selectedLabelTextStyle: const TextStyle(
          fontFamily: kFont, fontSize: 11, fontWeight: FontWeight.w500, color: kAccent),
      unselectedLabelTextStyle:
          const TextStyle(fontFamily: kFont, fontSize: 11, color: kMuted),
    ),
  );
}
