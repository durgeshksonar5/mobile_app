import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/storage/preferences_service.dart';
import '../../core/network/api_client.dart';
import '../../features/auth/data/services/auth_service.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/home/data/services/results_service.dart';
import '../../features/home/data/repositories/results_repository.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return ApiClient(secureStorage: secureStorage);
});

final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  final preferences = ref.watch(preferencesServiceProvider);
  return AuthRepository(authService, secureStorage, preferences);
});

final resultsServiceProvider = Provider<ResultsService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ResultsService(apiClient);
});

final resultsRepositoryProvider = Provider<ResultsRepository>((ref) {
  final resultsService = ref.watch(resultsServiceProvider);
  final preferences = ref.watch(preferencesServiceProvider);
  return ResultsRepository(resultsService, preferences);
});
