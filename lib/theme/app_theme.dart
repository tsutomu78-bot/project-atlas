import 'package:flutter/material.dart';

/// Minimal MVP theme. No custom brand colors yet — app name/brand
/// is deferred until after wireframes (see BRAND.md in the vault).
class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.blue,
      brightness: Brightness.light,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.blue,
      brightness: Brightness.dark,
    );
  }
}
