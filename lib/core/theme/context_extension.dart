import 'package:flutter/material.dart';
import 'app_theme.dart';

extension ThemeContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
