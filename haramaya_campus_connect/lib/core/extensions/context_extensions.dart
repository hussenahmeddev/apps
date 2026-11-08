import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  // Theme shortcuts
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // Media query shortcuts
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  double get bottomPadding => MediaQuery.paddingOf(this).bottom;
  double get topPadding => MediaQuery.paddingOf(this).top;

  // Navigation
  void pop<T>([T? result]) => Navigator.of(this).pop(result);
  bool get canPop => Navigator.of(this).canPop();

  // Responsive breakpoints
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;
  bool get isDesktop => screenWidth >= 1200;
}

