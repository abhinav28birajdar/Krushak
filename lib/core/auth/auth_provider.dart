import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

// User state model
class UserState {
  final User? user;
  final Map<String, dynamic>? profile;
  final bool isLoading;
  final String? error;

  const UserState({
    this.user,
    this.profile,
    this.isLoading = false,
    this.error,
  });

  UserState copyWith({
    User? user,
    Map<String, dynamic>? profile,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      user: user ?? this.user,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get isAuthenticated => user != null;
}

// Auth provider
class AuthNotifier extends StateNotifier<UserState> {
  AuthNotifier() : super(const UserState()) {
    _initializeWhenReady();
  }

  Future<void> _initializeWhenReady() async {
    // Wait for Supabase to be initialized
    int attempts = 0;
    while (!SupabaseService.isInitialized && attempts < 50) {
      await Future.delayed(const Duration(milliseconds: 200));
      attempts++;
    }

    if (SupabaseService.isInitialized) {
      _initialize();
    } else {
      state = state.copyWith(error: 'Failed to initialize Supabase');
    }
  }

  void _initialize() {
    try {
      // Listen to auth state changes
      SupabaseService.client.auth.onAuthStateChange.listen((data) {
        final user = data.session?.user;
        if (user != null) {
          _loadUserProfile(user);
        } else {
          state = const UserState();
        }
      });

      // Check current session
      final currentUser = SupabaseService.client.auth.currentUser;
      if (currentUser != null) {
        _loadUserProfile(currentUser);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to initialize auth: $e');
    }
  }

  Future<void> _loadUserProfile(User user) async {
    try {
      state = state.copyWith(user: user, isLoading: true);
      final profile = await SupabaseService.getCurrentUser();
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      if (!SupabaseService.isInitialized) {
        throw Exception('Authentication service not ready. Please try again.');
      }

      state = state.copyWith(isLoading: true, error: null);

      final response = await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserProfile(response.user!);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> signUp(
    String email,
    String password,
    Map<String, dynamic> profileData,
  ) async {
    try {
      if (!SupabaseService.isInitialized) {
        throw Exception('Authentication service not ready. Please try again.');
      }

      state = state.copyWith(isLoading: true, error: null);

      final response = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create user profile
        await SupabaseService.updateUserProfile(profileData);
        await _loadUserProfile(response.user!);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> signOut() async {
    try {
      if (!SupabaseService.isInitialized) {
        state = const UserState();
        return;
      }

      await SupabaseService.client.auth.signOut();
      state = const UserState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    try {
      state = state.copyWith(isLoading: true);
      await SupabaseService.updateUserProfile(profileData);
      await _loadUserProfile(state.user!);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, UserState>((ref) {
  return AuthNotifier();
});

// Helper providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final userProfileProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(authProvider).profile;
});
