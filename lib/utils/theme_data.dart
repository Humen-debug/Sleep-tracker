import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sleep_tracker/utils/style.dart';

const primaryColor = Color(0xff47c6cB);
const secondaryColor = Color(0xff05647a);
const tertiaryColor = Color(0xff10375d);
const backgroundColor = Color(0xff05182B);
const textColor = Color(0xffe0e2d5);
const errorColor = Color(0xffcf3c0e);
const containerColor = Color(0xff082847);
const cursorColor = Style.grey1;

const _defaultTextTheme = TextTheme(
  bodySmall: TextStyle(fontSize: 12, height: 16 / 12),
  bodyMedium: TextStyle(fontSize: 14, height: 20 / 14),
  bodyLarge: TextStyle(fontSize: 16, height: 24 / 16),
  labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 16 / 11),
  labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 16 / 12),
  labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 20 / 14),
  titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 20 / 14),
  titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 24 / 16),
  titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, height: 28 / 22),
  headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 32 / 20),
  headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, height: 36 / 24),
  headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, height: 40 / 32),
  displaySmall: TextStyle(fontSize: 36, height: 44 / 36),
  displayMedium: TextStyle(fontSize: 45, height: 52 / 45),
  displayLarge: TextStyle(fontSize: 57, height: 64 / 57),
);

// Default font list: https://api.flutter.dev/flutter/material/TextTheme-class.html
TextTheme textTheme = GoogleFonts.quicksandTextTheme(_defaultTextTheme);
TextTheme dataTextTheme = GoogleFonts.robotoTextTheme(_defaultTextTheme);

TextSelectionThemeData textSelectionTheme = const TextSelectionThemeData(cursorColor: cursorColor);

InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
  isDense: true,
  suffixIconColor: primaryColor,
  filled: true,
  fillColor: tertiaryColor,
  enabledBorder: InputBorder.none,
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(Style.radiusXs), borderSide: BorderSide.none),
  focusedBorder: InputBorder.none,
);

AppBarTheme appBarTheme = AppBarTheme(
  elevation: 0,
  centerTitle: false,
  titleTextStyle: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
  backgroundColor: backgroundColor,
);

ButtonStyle buttonStyle = ButtonStyle(
  elevation: MaterialStateProperty.all(0),
  textStyle: MaterialStateProperty.all(textTheme.bodyMedium),
  padding:
      MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: Style.spacingMd, horizontal: Style.spacingLg)),
  shape: MaterialStateProperty.all((RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)))),
);

const minButtonSize = Size(130, 42);

ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
    style: buttonStyle.copyWith(
  minimumSize: MaterialStateProperty.all<Size>(minButtonSize),
  textStyle: MaterialStateProperty.all(GoogleFonts.quicksand().copyWith(fontWeight: FontWeight.w700)),
  backgroundColor: MaterialStateProperty.resolveWith<Color>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return primaryColor.withOpacity(.5);
      }
      return primaryColor;
    },
  ),
  foregroundColor: MaterialStateProperty.all(tertiaryColor),
));

OutlinedButtonThemeData outlinedButtonTheme = OutlinedButtonThemeData(
    style: buttonStyle.copyWith(
  foregroundColor: MaterialStateProperty.all(primaryColor),
  minimumSize: MaterialStateProperty.all<Size>(minButtonSize),
  backgroundColor: MaterialStateProperty.all(Colors.transparent),
  side: MaterialStateProperty.all(const BorderSide(color: primaryColor, width: 2)),
  textStyle: MaterialStateProperty.all(textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
));

TextButtonThemeData textButtonTheme = TextButtonThemeData(
    style: ButtonStyle(
  foregroundColor: MaterialStateProperty.all(primaryColor),
  textStyle: MaterialStateProperty.all(textTheme.bodyMedium),
));

SwitchThemeData switchTheme = SwitchThemeData(thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
  if (states.contains(MaterialState.selected)) {
    return Style.grey1;
  } else {
    return Style.grey4;
  }
}), trackColor: MaterialStateProperty.resolveWith<Color>((states) {
  if (states.contains(MaterialState.selected)) {
    return primaryColor;
  }
  return Style.grey3;
}));

SliderThemeData sliderTheme = SliderThemeData(
  showValueIndicator: ShowValueIndicator.always,
  inactiveTickMarkColor: tertiaryColor,
  activeTrackColor: primaryColor,
  thumbColor: Colors.white,
  valueIndicatorColor: tertiaryColor,
  valueIndicatorTextStyle: textTheme.bodySmall?.copyWith(color: Style.grey1),
);

DialogTheme dialogTheme = DialogTheme(
    backgroundColor: Style.grey4,
    elevation: 0.4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Style.radiusSm)));

CupertinoThemeData cupertinoTheme = const CupertinoThemeData(
  brightness: Brightness.dark,
  primaryColor: primaryColor,
  scaffoldBackgroundColor: backgroundColor,
);

ListTileThemeData listTitleTheme = ListTileThemeData(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Style.radiusSm)),
  titleTextStyle: textTheme.bodyMedium,
  tileColor: tertiaryColor,
  horizontalTitleGap: Style.spacingSm,
  iconColor: primaryColor,
  subtitleTextStyle: textTheme.labelSmall?.apply(color: primaryColor),
  minLeadingWidth: 20,
  contentPadding: const EdgeInsets.symmetric(vertical: Style.spacingSm, horizontal: Style.spacingMd),
  dense: true,
  visualDensity: VisualDensity.compact,
);

final ThemeData themeData = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: false,
    primaryColor: primaryColor,
    appBarTheme: appBarTheme,
    scaffoldBackgroundColor: backgroundColor,
    elevatedButtonTheme: elevatedButtonTheme,
    outlinedButtonTheme: outlinedButtonTheme,
    textButtonTheme: textButtonTheme,
    inputDecorationTheme: inputDecorationTheme,
    switchTheme: switchTheme,
    sliderTheme: sliderTheme,
    dialogTheme: dialogTheme,
    cupertinoOverrideTheme: cupertinoTheme,
    listTileTheme: listTitleTheme,
    dividerTheme: const DividerThemeData(thickness: 1),
    textTheme: textTheme,
    textSelectionTheme: textSelectionTheme,
    highlightColor: primaryColor.withOpacity(0.2),
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: tertiaryColor,
      error: errorColor,
      onBackground: textColor,
      background: backgroundColor,
      surface: containerColor,
    ));
