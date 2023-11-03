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

// Default font list: https://api.flutter.dev/flutter/material/TextTheme-class.html
TextTheme textTheme = GoogleFonts.quicksandTextTheme(const TextTheme(headlineSmall: TextStyle(fontSize: 20)));

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
  side: MaterialStateProperty.all(const BorderSide(color: primaryColor)),
));

TextButtonThemeData textButtonTheme = TextButtonThemeData(
    style: ButtonStyle(
  foregroundColor: MaterialStateProperty.all(primaryColor),
  textStyle: MaterialStateProperty.all(textTheme.bodyMedium),
));

final ThemeData themeData = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    elevatedButtonTheme: elevatedButtonTheme,
    outlinedButtonTheme: outlinedButtonTheme,
    textButtonTheme: textButtonTheme,
    inputDecorationTheme: inputDecorationTheme,
    dividerTheme: const DividerThemeData(thickness: 1),
    textTheme: textTheme,
    textSelectionTheme: textSelectionTheme,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: tertiaryColor,
      error: errorColor,
      onBackground: textColor,
      background: backgroundColor,
      surface: containerColor,
    ));
