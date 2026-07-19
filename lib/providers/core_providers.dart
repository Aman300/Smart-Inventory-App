import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/dio_client.dart';
import '../core/services/storage_service.dart';
import '../repositories/auth_repository.dart';
import '../repositories/product_repository.dart';

// Provider for SharedPreferences to be overridden at main launch
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main');
});

// Storage Service Provider
final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageService(prefs);
});

// Dio Client Provider
final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return DioClient(storage);
});

// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(dioClientProvider);
  return AuthRepository(client);
});

// Product Repository Provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final client = ref.watch(dioClientProvider);
  return ProductRepository(client);
});
