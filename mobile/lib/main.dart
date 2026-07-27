import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  // Flutter servislerinin uygulama başlamadan hazırlanmasını sağlar.
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // Riverpod provider'larının uygulamanın her yerinden
    // kullanılabilmesini sağlar.
    const ProviderScope(
      child: EventTrackerApp(),
    ),
  );
}