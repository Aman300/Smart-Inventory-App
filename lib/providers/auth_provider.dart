import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/storage_service.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import 'core_providers.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final UserModel? user;
  final AuthStatus status;
  final String? errorMessage;

  AuthState({
    this.user,
    this.status = AuthStatus.initial,
    this.errorMessage,
  });

  AuthState copyWith({
    UserModel? user,
    AuthStatus? status,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final StorageService _storageService;

  AuthNotifier(this._authRepository, this._storageService) : super(AuthState()) {
    checkAuth();
  }

  // Check if session token exists and validate it against profile endpoint
  Future<void> checkAuth() async {
    final token = _storageService.getToken();
    if (token == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _authRepository.getProfile();
      state = state.copyWith(user: user, status: AuthStatus.authenticated);
    } catch (e) {
      final checkToken = _storageService.getToken();
      if (checkToken == null) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: e.toString(),
        );
      }
    }
  }

  // Handle Login
  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _authRepository.login(email, password);
      if (user.token != null) {
        await _storageService.saveToken(user.token!);
      }
      state = state.copyWith(user: user, status: AuthStatus.authenticated);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Handle Sign-Up
  Future<void> register(
    String name,
    String email,
    String password, {
    String? imagePath,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _authRepository.register(
        name,
        email,
        password,
        profileImagePath: imagePath,
      );
      if (user.token != null) {
        await _storageService.saveToken(user.token!);
      }
      state = state.copyWith(user: user, status: AuthStatus.authenticated);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Update Profile details
  Future<void> updateProfile(
    String name, {
    String? imagePath,
    String? password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _authRepository.updateProfile(
        name,
        profileImagePath: imagePath,
        password: password,
      );
      state = state.copyWith(user: user, status: AuthStatus.authenticated);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Clear session
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    await _storageService.removeToken();
    state = AuthState(status: AuthStatus.unauthenticated);
  }
}

// Global Auth State Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthNotifier(authRepository, storageService);
});
