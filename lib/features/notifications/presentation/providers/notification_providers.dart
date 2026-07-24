import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/dependency_injection/providers.dart';
import '../../../auth/presentation/view_models/auth_view_model.dart';
import '../../data/services/notification_service.dart';

/// Provider for NotificationService instance.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NotificationService(apiClient);
});

/// Reactive initializer that monitors authentication state.
/// When the user becomes authenticated, it automatically triggers FCM permission
/// request and registers the device token with the Django backend.
final notificationInitializerProvider = Provider<void>((ref) {
  final authState = ref.watch(authViewModelProvider);
  final notificationService = ref.watch(notificationServiceProvider);

  if (authState.isAuthenticated && authState.user != null) {
    // Perform permission request and sync token
    notificationService.requestPermissionsAndRegister();
  }
});
