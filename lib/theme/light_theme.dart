import 'package:flutter/material.dart';
import 'package:sixam_mart/util/app_constants.dart';

// ThemeData light({Color color = const Color(0xFF007058)}) => ThemeData(
//   useMaterial3: false,
//
//   fontFamily: AppConstants.fontFamily,
//   primaryColor: color,
//   secondaryHeaderColor: const Color(0xFFE7DB10),
//   disabledColor: const Color(0xFFBABFC4),
//   brightness: Brightness.light,
//   hintColor: const Color(0xFF9F9F9F),
//   cardColor: Colors.white,
//   textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: color)),
//   colorScheme: ColorScheme.light(primary: color, secondary: color).copyWith(background: const Color(0xFFFCFCFC)).copyWith(error: const Color(0xFFE84D4F)),
// );
ThemeData light({Color color = const Color(0xFF007058)}) => ThemeData(
  useMaterial3: false,  // حدد إذا كنت تريد استخدام Material 3 أو لا
  fontFamily: AppConstants.fontFamily,  // استبدلها باسم عائلة الخطوط التي تريد استخدامها
  primaryColor: color,  // اللون الأساسي
  secondaryHeaderColor: const Color(0xFFE7DB10),  // اللون الثانوي
  disabledColor: const Color(0xFFBABFC4),  // لون العناصر المعطلة
  brightness: Brightness.light,  // تحديد نوع السطوع (مضيء)
  hintColor: const Color(0xFF9F9F9F),  // لون التلميحات
  cardColor: Colors.white,  // لون البطاقات
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: color,  // لون النص لأزرار النص
    ),
  ),
  colorScheme: ColorScheme.light(
    primary: color,  // اللون الأساسي
    secondary: color,  // اللون الثانوي
  ).copyWith(
    background: const Color(0xFFFCFCFC),  // لون الخلفية
    error: const Color(0xFFE84D4F),  // لون الخطأ
  ),
);