import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import '../features/notifications/presentation/providers/notification_providers.dart';

class KingWinApp extends ConsumerWidget {
  const KingWinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Activate FCM token sync reactive initializer
    ref.watch(notificationInitializerProvider);

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'King Win',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
