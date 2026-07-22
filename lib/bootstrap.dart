import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/config/app_config.dart';

void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.initialize();

  runApp(
    const ProviderScope(
      child: KingWinApp(),
    ),
  );
}
