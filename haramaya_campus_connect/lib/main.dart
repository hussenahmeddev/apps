import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:haramaya_campus_connect/firebase_options.dart';
import 'package:haramaya_campus_connect/app.dart';
import 'package:haramaya_campus_connect/shared/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase.initializeApp warning: $e');
  }

  // Render the application UI immediately so the splash screen dismisses
  runApp(
    const ProviderScope(
      child: HaramayaCampusConnectApp(),
    ),
  );

  // Initialize background services without blocking the UI
  try {
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('NotificationService warning: $e');
  }
}
