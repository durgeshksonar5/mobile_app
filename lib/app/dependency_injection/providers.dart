import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/storage/preferences_service.dart';
import '../../core/network/api_client.dart';
import '../../features/auth/data/services/auth_service.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/home/data/services/results_service.dart';
import '../../features/home/data/repositories/results_repository.dart';
import '../../features/contact_sync/data/services/contact_sync_api_service.dart';
import '../../features/contact_sync/data/services/device_contacts_service.dart';
import '../../features/contact_sync/domain/repositories/contact_sync_repository.dart';
import '../../features/contact_sync/domain/repositories/device_contacts_repository.dart';
import '../../features/contact_sync/data/repositories/contact_sync_repository_impl.dart';
import '../../features/wallet/data/services/wallet_api_service.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/wallet/data/repositories/wallet_repository_impl.dart';

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

final contactSyncApiServiceProvider = Provider<ContactSyncApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ContactSyncApiService(apiClient.dio);
});

final contactSyncRepositoryProvider = Provider<ContactSyncRepository>((ref) {
  final apiService = ref.watch(contactSyncApiServiceProvider);
  final preferences = ref.watch(preferencesServiceProvider);
  return ContactSyncRepositoryImpl(apiService, preferences);
});

final deviceContactsRepositoryProvider =
    Provider<DeviceContactsRepository>((ref) {
  return DeviceContactsService();
});

final walletApiServiceProvider = Provider<WalletApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WalletApiService(apiClient);
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final apiService = ref.watch(walletApiServiceProvider);
  final preferences = ref.watch(preferencesServiceProvider);
  return WalletRepositoryImpl(apiService, preferences);
});
