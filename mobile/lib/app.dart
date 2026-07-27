import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/screens/auth_gate.dart';


class EventTrackerApp extends StatelessWidget {
  const EventTrackerApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Event Tracker',
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}