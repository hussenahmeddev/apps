import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haramaya_campus_connect/core/theme/app_theme.dart';
import 'package:haramaya_campus_connect/core/routing/app_router.dart';

class HaramayaCampusConnectApp extends ConsumerWidget {
  const HaramayaCampusConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Haramaya Campus Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}

